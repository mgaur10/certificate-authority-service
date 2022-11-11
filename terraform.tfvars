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
## author@manishgaur




organization_id = "XXXXXXXXXXXX"
billing_account = "XXXXX-XXXXX-XXXXXX"
folder_name = "CA Service Demo  "
demo_project_id = "cas-demo-" 



network_region = "us-central1"
network_region2 = "us-east1"




ca_algo = "RSA_PKCS1_2048_SHA256"   #"EC_P256_SHA256"  SIGN_HASH_ALGORITHM_UNSPECIFIED, RSA_PSS_2048_SHA256, RSA_PSS_3072_SHA256, RSA_PSS_4096_SHA256, RSA_PKCS1_2048_SHA256, RSA_PKCS1_3072_SHA256, RSA_PKCS1_4096_SHA256, EC_P256_SHA256, and EC_P384_SHA384


caPoolName = "Demo-Root-Pool"
subcaPoolName = "Demo-Sub-Pool-Central"
subcaPoolName2 = "Demo-Sub-Pool-East"
caTier = "ENTERPRISE"
caId = "Demo-Root-CA"
subCaId = "Demo-Sub-CA-Central"
subCaId2 = "Demo-Sub-CA-East"
caType = "SUBORDINATE" #SELF_SIGNED

cert_name = "Demo_Leaf_Cert"

subject_organization = "Demo"
subject_common_name = "Demo"
subject_country_code = "US"
subject_organizational_unit = "NA"
subject_province = "NA"
subject_locality = "NA"
