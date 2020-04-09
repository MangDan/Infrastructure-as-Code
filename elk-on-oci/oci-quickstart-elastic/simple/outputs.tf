output "ELK_VM_public_IP" {
  value = data.oci_core_vnic.elk_vnic.public_ip_address
}
