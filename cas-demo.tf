/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


## NOTE: This provides PoC demo environment for various use cases ##
##  This is not built for production workload ##




# Random id for naming
resource "random_string" "id" {
  length = 4
  upper   = false
  lower   = true
  number  = true
  special = false
 }

 # Create Folder in GCP Organization
resource "google_folder" "terraform_solution" {
  display_name =  "${var.folder_name}${random_string.id.result}"
  parent = "organizations/${var.organization_id}"
  }
  

# Create the Project
resource "google_project" "demo_project" {
  project_id      = "${var.demo_project_id}${random_string.id.result}"
  name            = "CA Service Demo"
  billing_account = var.billing_account
  folder_id = google_folder.terraform_solution.name
  depends_on = [
      google_folder.terraform_solution
  ]
}

# Enable the necessary API services
resource "google_project_service" "api_service" {
  for_each = toset([
    "privateca.googleapis.com",
    "storage.googleapis.com",
    "cloudkms.googleapis.com",

  ])

  service = each.key

  project            = google_project.demo_project.project_id
  disable_on_destroy = true
  disable_dependent_services = true
  depends_on = [google_project.demo_project]
}

resource "time_sleep" "wait_enable_service" {
  depends_on = [google_project_service.api_service]
  create_duration = "120s"
  destroy_duration = "120s"
}



# Create a kms key ring and key
  resource "google_kms_key_ring" "keyring" {
  project            = google_project.demo_project.project_id
    name     = var.keyring_name
    location = var.network_region
    depends_on = [time_sleep.wait_enable_service]
  } 
  

  resource "google_kms_crypto_key" "kms_key" {
  #project            = google_project.demo_project.project_id
    name            = var.crypto_key_name
    key_ring        = google_kms_key_ring.keyring.id
  #  rotation_period = "100000s"
    purpose  = var.kmsKeyPurpose

  version_template {
    algorithm        = var.kmsKeyAlgo
    protection_level = "HSM"
  }

    lifecycle {
      prevent_destroy = false
    }
    depends_on = [
      google_kms_key_ring.keyring,
      time_sleep.wait_enable_service,
      ]
  }  


data "google_kms_crypto_key_version" "keyVersion" {
  crypto_key = google_kms_crypto_key.kms_key.id
#  project            = google_project.demo_project.project_id
    depends_on = [
      google_kms_key_ring.keyring,
      time_sleep.wait_enable_service,
      google_kms_crypto_key.kms_key
      ]
}


## KMS Permissions for the CA
resource "google_project_service_identity" "privateca_sa" {
  provider = google-beta
  service  = "privateca.googleapis.com"
  project  = google_project.demo_project.project_id
  depends_on = [time_sleep.wait_enable_service]
}

resource "google_kms_crypto_key_iam_binding" "privateca_sa_keyuser_signerverifier" {
  crypto_key_id = google_kms_crypto_key.kms_key.id
  role          = "roles/cloudkms.signerVerifier"

  members = [
    "serviceAccount:${google_project_service_identity.privateca_sa.email}",
  ]
#  project            = google_project.demo_project.project_id
depends_on = [google_project_service_identity.privateca_sa]
}

resource "google_kms_crypto_key_iam_binding" "privateca_sa_keyuser_viewer" {
  crypto_key_id = google_kms_crypto_key.kms_key.id
  role          = "roles/viewer"
  members = [
    "serviceAccount:${google_project_service_identity.privateca_sa.email}",
  ]
#  project            = google_project.demo_project.project_id
depends_on = [google_project_service_identity.privateca_sa]
}


## Root CA pool
resource "google_privateca_ca_pool" "ca_pool" {
  name     = var.caPoolName
  location = var.network_region
  tier     = var.caTier
  publishing_options {
    publish_ca_cert = true
    publish_crl     = true
  }
  project            = google_project.demo_project.project_id
  depends_on = [time_sleep.wait_enable_service]
}


## Subordinate CA pool
resource "google_privateca_ca_pool" "subca_pool" {
  name     = var.subcaPoolName
  location = var.network_region
  tier     = var.caTier
  publishing_options {
    publish_ca_cert = true
    publish_crl     = true
  }
  project            = google_project.demo_project.project_id
  depends_on = [time_sleep.wait_enable_service]
}


## rootCA 
resource "google_privateca_certificate_authority" "rootca" {
  location                 = var.network_region
  project            = google_project.demo_project.project_id
  certificate_authority_id = var.caId
  deletion_protection = false
  skip_grace_period = true
  ignore_active_certificates_on_deletion = true
  pool                     = google_privateca_ca_pool.ca_pool.name
  config {
    x509_config {
      ca_options {
        is_ca                  = true
        max_issuer_path_length = 10
      }
      key_usage {
        base_key_usage {
          crl_sign  = true
          cert_sign = true
        }
        extended_key_usage {
          server_auth      = true
          client_auth      = true
          code_signing     = true
          email_protection = false
        }
      }
    }
    subject_config {
      subject {
        organization        = var.subject_organization
        common_name         = var.subject_common_name
        country_code        = var.subject_country_code
        organizational_unit = var.subject_organizational_unit
        province            = var.subject_province
        locality            = var.subject_locality
      }
    }
  }
  key_spec {
    cloud_kms_key_version = trimprefix(data.google_kms_crypto_key_version.keyVersion.id, "//cloudkms.googleapis.com/v1/")
  #  algorithm = var.ca_algo
  }
  depends_on = [
    data.google_kms_crypto_key_version.keyVersion,
    google_kms_key_ring.keyring,
    google_kms_crypto_key.kms_key,
    google_kms_crypto_key_iam_binding.privateca_sa_keyuser_signerverifier,
    google_kms_crypto_key_iam_binding.privateca_sa_keyuser_viewer,
    google_privateca_ca_pool.ca_pool,
    ]
}


## sub CA
resource "google_privateca_certificate_authority" "subca" {
  location                 = var.network_region
  project            = google_project.demo_project.project_id
  certificate_authority_id = var.subCaId
  deletion_protection = false
  skip_grace_period = true
  ignore_active_certificates_on_deletion = true
  pool                     = google_privateca_ca_pool.subca_pool.name
  type                     = var.caType
  lifetime = "86400s"
  config {
    x509_config {
      ca_options {
        is_ca                  = true
        max_issuer_path_length = 0
      }
      key_usage {
        base_key_usage {
          crl_sign  = true
          cert_sign = true
        }
        extended_key_usage {
          server_auth      = true
          client_auth      = true
          code_signing     = true
          email_protection = false
        }
      }
    }
    subject_config {
      subject {
        organization        = var.subject_organization
        common_name         = var.subject_common_name
        country_code        = var.subject_country_code
        organizational_unit = var.subject_organizational_unit
        province            = var.subject_province
        locality            = var.subject_locality
      }
    }
  }
  key_spec {
    cloud_kms_key_version = trimprefix(data.google_kms_crypto_key_version.keyVersion.id, "//cloudkms.googleapis.com/v1/")
  }
  depends_on = [
    data.google_kms_crypto_key_version.keyVersion,
    google_kms_key_ring.keyring,
    google_kms_crypto_key.kms_key,
    google_kms_crypto_key_iam_binding.privateca_sa_keyuser_signerverifier,
    google_kms_crypto_key_iam_binding.privateca_sa_keyuser_viewer,
    google_privateca_ca_pool.subca_pool,
    google_privateca_certificate_authority.rootca,
    ]
}




