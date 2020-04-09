variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}

variable "compartment_ocid" {}
variable "ssh_public_key" {}

# Defines the number of instances to deploy
variable "NumInstances" {
  default = "1"
}

# Choose an Availability Domain
variable "availability_domain" {
  default = "1"
}

variable "instance_shape" {
  default = "VM.Standard2.2"
}

// https://docs.cloud.oracle.com/en-us/iaas/images/image/54f930a3-0bf3-4f5d-b573-10eeeb7c7b03/
// Oracle-Linux-7.7-2020.03.23-0
variable "images" {
  type = map(string)

  default = {
    ap-seoul-1     = "ocid1.image.oc1.ap-seoul-1.aaaaaaaautl44ij44xudvnu3boasvuvucowuz4avdigc2csahzqmtb37sfwa"
    us-ashburn-1     = "ocid1.image.oc1.iad.aaaaaaaa6tp7lhyrcokdtf7vrbmxyp2pctgg4uxvt4jz4vc47qoc2ec4anha"
  }
}
