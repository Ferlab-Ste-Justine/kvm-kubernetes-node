variable "name" {
  description = "Name to give to the vm."
  type        = string
}

variable "vcpus" {
  description = "Number of vcpus to assign to the vm"
  type        = number
  default     = 2
}

variable "memory" {
  description = "Amount of memory in MiB"
  type        = number
  default     = 8192
}

variable "volume_id" {
  description = "Id of the disk volume to attach to the vm"
  type        = string
}

variable "libvirt_network" {
  description = "Parameters of the libvirt network connection if a libvirt network is used. Has the following parameters: network_id, network_name, ip, mac"
  type = object({
    network_name = string
    network_id = string
    ip = string
    mac = string
  })
  default = {
    network_name = ""
    network_id = ""
    ip = ""
    mac = ""
  }
}

variable "macvtap_interfaces" {
  description = "List of macvtap interfaces. Mutually exclusive with the network_id, ip and mac fields. Each entry has the following keys: interface, prefix_length, ip, mac, gateway and dns_servers"
  type        = list(object({
    interface = string,
    prefix_length = number,
    ip = string,
    mac = string,
    gateway = string,
    dns_servers = list(string),
  }))
  default = []
}

variable "cloud_init_volume_pool" {
  description = "Name of the volume pool that will contain the cloud init volume"
  type        = string
}

variable "cloud_init_volume_name" {
  description = "Name of the cloud init volume"
  type        = string
  default = ""
}

variable "ssh_admin_user" { 
  description = "Pre-existing ssh admin user of the image"
  type        = string
  default     = "ubuntu"
}

variable "admin_user_password" { 
  description = "Optional password for admin user"
  type        = string
  sensitive   = true
  default     = ""
}

variable "ssh_admin_public_key" {
  description = "Public ssh part of the ssh key the admin will be able to login as"
  type        = string
}

variable "nfs_tunnel" {
  description = "Configuration for an optional nfs tunnel over tls"
  type        = object({
    enabled            = bool,
    server_domain      = string,
    server_port        = string,
    client_key         = string,
    client_certificate = string,
    ca_certificate     = string,
    nameserver_ips     = list(string), 
    max_connections    = number,
    idle_timeout       = string
  })
  default = {
    enabled            = false
    server_domain      = ""
    server_port        = ""
    client_key         = ""
    client_certificate = ""
    ca_certificate     = ""
    nameserver_ips     = []
    max_connections    = 0
    idle_timeout       = ""
  }
}

variable "fluentd" {
  description = "Fluentd configurations"
  sensitive   = true
  type = object({
    enabled = bool,
    nfs_tunnel_client_tag = string,
    node_exporter_tag = string,
    forward = object({
      domain = string,
      port = number,
      hostname = string,
      shared_key = string,
      ca_cert = string,
    }),
    buffer = object({
      customized = bool,
      custom_value = string,
    })
  })
  default = {
    enabled = false
    nfs_tunnel_client_tag = ""
    node_exporter_tag = ""
    forward = {
      domain = ""
      port = 0
      hostname = ""
      shared_key = ""
      ca_cert = ""
    }
    buffer = {
      customized = false
      custom_value = ""
    }
  }
}

variable "chrony" {
  description = "Chrony configuration for ntp. If enabled, chrony is installed and configured, else the default image ntp settings are kept"
  type        = object({
    enabled = bool,
    //https://chrony.tuxfamily.org/doc/4.2/chrony.conf.html#server
    servers = list(object({
      url = string,
      options = list(string)
    })),
    //https://chrony.tuxfamily.org/doc/4.2/chrony.conf.html#pool
    pools = list(object({
      url = string,
      options = list(string)
    })),
    //https://chrony.tuxfamily.org/doc/4.2/chrony.conf.html#makestep
    makestep = object({
      threshold = number,
      limit = number
    })
  })
  default = {
    enabled = false
    servers = []
    pools = []
    makestep = {
      threshold = 0,
      limit = 0
    }
  }
}

variable "install_dependencies" {
  description = "Whether to install all dependencies in cloud-init"
  type = bool
  default = true
}