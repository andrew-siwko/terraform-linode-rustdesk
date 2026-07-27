resource "linode_volume" "rustdesk_data" {
  label     = "rustdesk-data"
  region    = var.instance_region
  size      = 10
  linode_id = linode_instance.asiwko-rustdesk-01.id
}
