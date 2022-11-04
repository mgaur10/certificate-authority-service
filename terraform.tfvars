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




organization_id = "XXXXXXXXXXXX"
billing_account = "XXXXX-XXXXX-XXXXXX"
folder_name = "CA Service Demo  "
demo_project_id = "cas-demo-" 



network_region = "us-east1"


keyring_name = "example_key_ring"
crypto_key_name = "crypto_key"
kmsKeyAlgo = "EC_SIGN_P256_SHA256" #EC_SIGN_P384_SHA384; RSA_SIGN_PSS_2048_SHA256; RSA_SIGN_PKCS1_2048_SHA256; 
kmsKeyPurpose = "ASYMMETRIC_SIGN" #ENCRYPT_DECRYPT, ASYMMETRIC_SIGN, ASYMMETRIC_DECRYPT, and MAC

ca_algo = "EC_P256_SHA256" # SIGN_HASH_ALGORITHM_UNSPECIFIED, RSA_PSS_2048_SHA256, RSA_PSS_3072_SHA256, RSA_PSS_4096_SHA256, RSA_PKCS1_2048_SHA256, RSA_PKCS1_3072_SHA256, RSA_PKCS1_4096_SHA256, EC_P256_SHA256, and EC_P384_SHA384


caPoolName = "my-pool"
subcaPoolName = "my-sub-pool"
caTier = "ENTERPRISE"
caId = "my-certificate-authority"
subCaId = "my-certificate-authority-sub"
caType = "SUBORDINATE" #SELF_SIGNED

subject_organization = "my-org"
subject_common_name = "my-certificate-authority"
subject_country_code = "US"
subject_organizational_unit = "NA"
subject_province = "NA"
subject_locality = "NA"


