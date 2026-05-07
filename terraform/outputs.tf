output "ansible_inventory" {
  value = {
    webservers = {
      hosts = {
        for name, instance in aws_instance.servers : name => {
          ansible_host                 = instance.public_ip
          ansible_user                 = "ubuntu"
          ansible_ssh_private_key_file = "~/.ssh/${instance.key_name}.pem"
        }
      }
    }
  }
}

output "instance_public_ip" {
  description = "The public IP address of the EC2 instance"
  value = {
    for name, instance in aws_instance.servers :
    name => instance.public_ip
  }
}

output "instance_dns_name" {
  description = "The public IP address of the EC2 instance"
  value = {
    for name, instance in aws_instance.servers :
    name => instance.public_dns
  }
}
