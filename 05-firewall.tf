resource "linode_firewall" "rustdesk_firewall" {
  label = "rustdesk_firewall"

  inbound {
    label    = "allow-icmp"
    action   = "ACCEPT"
    protocol = "ICMP"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }
  inbound {
    label    = "allow-ssh"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "22"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  # RustDesk hbbs/hbbr: ID/rendezvous + relay + web client support
  inbound {
    label    = "allow-rustdesk-tcp"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "21115-21119"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound {
    label    = "allow-rustdesk-udp"
    action   = "ACCEPT"
    protocol = "UDP"
    ports    = "21116"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound_policy = "DROP"

  outbound_policy = "ACCEPT"

  linodes = [linode_instance.asiwko-rustdesk-01.id]
}