# About

This package provisions a node (master or worker) that you can install kubernetes on (validated with Kubespray)

The implementation is currently quite minimalistic and beyond enable ipv4 forwarding, don't really do any kubernetes-specific setup.

# Usage

## Input

The module takes the following variables as input:

- **name**: Name of the load balancer vm
- **vcpus**: Number of vcpus to assign to the load balancer. Defaults to 2.
- **memory**: Amount of memory to assign to the bastion in MiB. Defaults to 8192 (8 GiB).
- **volume_id**: Id of the disk volume to attach to the vm
- **libvirt_network**: Parameters to connect to libvirt networks. Each entry has the following keys:
  - **network_id**: Id (ie, uuid) of the libvirt network to connect to (in which case **network_name** should be an empty string).
  - **network_name**: Name of the libvirt network to connect to (in which case **network_id** should be an empty string).
  - **ip**: Ip of interface connecting to the libvirt network.
  - **mac**: Mac address of interface connecting to the libvirt network.
  - **prefix_length**:  Length of the network prefix for the network the interface will be connected to. For a **192.168.1.0/24** for example, this would be **24**.
  - **gateway**: Ip of the network's gateway. Usually the gateway the first assignable address of a libvirt's network.
  - **dns_servers**: Dns servers to use. Usually the dns server is first assignable address of a libvirt's network.
- **macvtap_interfaces**: List of macvtap interfaces to connect the vm to if you opt for macvtap interfaces. Each entry in the list is a map with the following keys:
  - **interface**: Host network interface that you plan to connect your macvtap interface with.
  - **prefix_length**: Length of the network prefix for the network the interface will be connected to. For a **192.168.1.0/24** for example, this would be 24.
  - **ip**: Ip associated with the macvtap interface. 
  - **mac**: Mac address associated with the macvtap interface
  - **gateway**: Ip of the network's gateway for the network the interface will be connected to.
  - **dns_servers**: Dns servers for the network the interface will be connected to. If there aren't dns servers setup for the network your vm will connect to, the ip of external dns servers accessible accessible from the network will work as well.
- **cloud_init_volume_pool**: Name of the volume pool that will contain the cloud-init volume of the vm.
- **cloud_init_volume_name**: Name of the cloud-init volume that will be generated by the module for your vm. If left empty, it will default to ``<vm name>-cloud-init.iso``.
- **ssh_admin_user**: Username of the default sudo user in the image. Defaults to **ubuntu**.
- **admin_user_password**: Optional password for the default sudo user of the image. Note that this will not enable ssh password connections, but it will allow you to log into the vm from the host using the **virsh console** command.
- **ssh_admin_public_key**: Public part of the ssh key that will be used to login as the admin on the vm
- **docker_registry_auth**: Optional docker registry authentication settings to have access to private repositories or to avoid reaching the rate limit for anonymous users.
  - **enabled**: If set to false (the default), no docker config file will be created.
  - **url**: Url of the registry you want to authenticate to.
  - **username**: Username for the authentication.
  - **password**: Password for the authentication.
- **nfs_tunnel**: Configuration for an optional forwarder to an nfs server using a tls tunnel to be placed on kubernetes workers. It takes the following properties:
  - **enabled**: Whether to enable the tunnel setup. It is disabled by default
  - **server_domain**: The domain of the nfs server
  - **server_port**: Port that the other side of the tunnel on the server will listen on.
  - **client_key**: Tls private key to authentify the client
  - **client_certificate**: Tls certificate to authentify the client
  - **ca_certificate**: Ca certificate to authentify the server
  - **nameserver_ips**: Optional ips of nameservers used to resolve the nfs server domain.
- **fluentbit**: Optional fluend configuration to securely route logs to a fluend/fluent-bit node using the forward plugin. Alternatively, configuration can be 100% dynamic by specifying the parameters of an etcd store to fetch the configuration from. It has the following keys:
  - **enabled**: If set the false (the default), fluent-bit will not be installed.
  - **nfs_tunnel_client_tag**: Tag to assign to logs coming from the nfs tunnel client
  - **node_exporter_tag** Tag to assign to logs coming from the prometheus node exporter
  - **forward**: Configuration for the forward plugin that will talk to the external fluend/fluent-bit node. It has the following keys:
    - **domain**: Ip or domain name of the remote fluend node.
    - **port**: Port the remote fluend node listens on
    - **hostname**: Unique hostname identifier for the vm
    - **shared_key**: Secret shared key with the remote fluentd node to authentify the client
    - **ca_cert**: CA certificate that signed the remote fluentd node's server certificate (used to authentify it)
  - **etcd**: Parameters to fetch fluent-bit configurations dynamically from an etcd cluster. It has the following keys:
    - **enabled**: If set to true, configurations will be set dynamically. The default configurations can still be referenced as needed by the dynamic configuration. They are at the following paths:
      - **Global Service Configs**: /etc/fluent-bit-customization/default-config/fluent-bit-service.conf
      - **Systemd Inputs**: /etc/fluent-bit-customization/default-config/fluent-bit-inputs.conf
      - **Forward Output**: /etc/fluent-bit-customization/default-config/fluent-bit-output.conf
    - **key_prefix**: Etcd key prefix to search for fluent-bit configuration
    - **endpoints**: Endpoints of the etcd cluster. Endpoints should have the format `<ip>:<port>`
    - **ca_certificate**: CA certificate against which the server certificates of the etcd cluster will be verified for authenticity
    - **client**: Client authentication. It takes the following keys:
      - **certificate**: Client tls certificate to authentify with. To be used for certificate authentication.
      - **key**: Client private tls key to authentify with. To be used for certificate authentication.
      - **username**: Client's username. To be used for username/password authentication.
      - **password**: Client's password. To be used for username/password authentication.
- **chrony**: Optional chrony configuration for when you need a more fine-grained ntp setup on your vm. It is an object with the following fields:
  - **enabled**: If set to false (the default), chrony will not be installed and the vm ntp settings will be left to default.
  - **servers**: List of ntp servers to sync from with each entry containing two properties, **url** and **options** (see: https://chrony.tuxfamily.org/doc/4.2/chrony.conf.html#server)
  - **pools**: A list of ntp server pools to sync from with each entry containing two properties, **url** and **options** (see: https://chrony.tuxfamily.org/doc/4.2/chrony.conf.html#pool)
  - **makestep**: An object containing remedial instructions if the clock of the vm is significantly out of sync at startup. It is an object containing two properties, **threshold** and **limit** (see: https://chrony.tuxfamily.org/doc/4.2/chrony.conf.html#makestep)
- **install_dependencies**: Whether cloud-init should install external dependencies (should be set to false if you already provide an image with the external dependencies built-in).