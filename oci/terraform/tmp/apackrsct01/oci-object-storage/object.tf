resource "oci_objectstorage_bucket" "mcdorm-bucket" {
  compartment_id = "${var.compartment_ocid}"
  name           = "mcdorm-bucket"
  namespace      = "${data.oci_objectstorage_namespace.user_namespace.namespace}"
  freeform_tags  = "${local.common_tags}"
}

resource "oci_objectstorage_object" "application-pkg" {
  #Required
  bucket    = "${oci_objectstorage_bucket.mcdorm-bucket.name}"
  #content   = "${file("application.tar.gz")}"
  content   = "${filebase64sha256("application.tar.gz")}"
  namespace = "${data.oci_objectstorage_namespace.user_namespace.namespace}"
  object    = "application"
}

locals  {
  common_tags = {
    Reference = "Created by OCI QuickStart for Free Tier"
  }
}
