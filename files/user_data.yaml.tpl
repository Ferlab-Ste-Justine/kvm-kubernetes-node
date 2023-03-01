#cloud-config
merge_how:
 - name: list
   settings: [append, no_replace]
 - name: dict
   settings: [no_replace, recurse_list]

%{ if admin_user_password != "" ~}
ssh_pwauth: false
chpasswd:
  expire: False
  users:
    - name: ${ssh_admin_user}
      password: "${admin_user_password}"
      type: text
%{ endif ~}
preserve_hostname: false
hostname: ${hostname}
users:
  - default
  - name: ${ssh_admin_user}
    ssh_authorized_keys:
      - "${ssh_admin_public_key}"

%{ if docker_registry_auth.enabled ~}
write_files:
  - path: /root/.docker/config.json
    owner: root:root
    permissions: "0600"
    content: |
      {
        "auths": {
          "${docker_registry_auth.url}": {
            "auth": "${base64encode("${docker_registry_auth.username}:${docker_registry_auth.password}")}"
          }
        }
      }
%{ endif ~}

runcmd:
  #Kubernetes Adjustment
  - /sbin/sysctl -w net.ipv4.conf.all.forwarding=1