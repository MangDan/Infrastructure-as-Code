variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "compartment_ocid" {}
#variable "ssh_public_key" {}
variable "region" {}

variable "availability_domain" {
  default = 1
}

variable "InstanceImageOCID" {
    type = "map"
    default = {
        // See https://docs.cloud.oracle.com/images/
        // Oracle-provided image "Oracle-Linux-7.5-2018.10.16-0"
        ap-seoul-1 = "ocid1.image.oc1.ap-seoul-1.aaaaaaaavwjewurl3nvcyq6bgpbrapk4wfwu6qz2ljlrj2yk3cfqexeq64na"
    }
}

variable "ssh_public_key" {
	default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDnV1Flgu2pg4Uwn3b+eonrAvJBLeQV1lSwkrUa2TEnH9KNajvJ/HJsGme96zSlCzA28VN5HX1EAdM3FS5ik7w2QQLtWzZ40qYmsFn+lvQw1+Dy0usTuHSOoTVb732xiMZkSYu+gV45xhbZOlWGuwQqn7hb4mH2jXjMclrh0vRKoZZgzws+2OFVQ/J+WjHCVxtX1sEQTNRYtNlE/ADfhlh7ODGcl1U7zFU0JDtPhf0Vy731fqL9+hLH96YcUag7lrAM9XmQGyiZZbDvwWklM+M15yUWjJ41KsimQ0vI9cgRvFvxnwkGKKKTlZoMKcLvOmcTXKWzIfC091aXmt895FVn DonghuKim@MacBook-Pro.local"
}

# Defines the number of instances to deploy
variable "NumInstances" {
    default = "1"
}

variable "InstanceShape" {
    default = "VM.Standard2.1"
}

# Specifies the Availability Domain
variable "localAD" {
    default = "sAyj:AP-SEOUL-1-AD-1"
}
