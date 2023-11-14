provider "aws" {
  region = "us-east-1" 
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}
variable "port_numbers" {
  type = list(number)
  default = [ 111,2049 ]
}


#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "shared_ddc_sg" {
  vpc_id = var.vpc_id
  description = "Security group for Unreal Shared Derived Data Cache Server"

  ingress {
    from_port = 111
    to_port = 111
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 111
    to_port = 111
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 2049
    to_port = 2049
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 2049
    to_port = 2049
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 20001
    to_port = 20003
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 20001
    to_port = 20003
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/fsx_openzfs_file_system

resource "aws_fsx_openzfs_file_system" "shared_ddc_file_system" {
    storage_capacity    = 1000
    storage_type = "SSD"
    deployment_type     = "SINGLE_AZ_2"
    #when `deployment_type` is "SINGLE_AZ_2". Valid values: [160 320 640 1280 2560 3840 5120 7680 10240]
    throughput_capacity = 2560
    subnet_ids = [var.subnet_id]
    security_group_ids = [aws_security_group.shared_ddc_sg.id]
    automatic_backup_retention_days = 0
    copy_tags_to_backups = false
    copy_tags_to_volumes = false
     root_volume_configuration {
        data_compression_type = "ZSTD"
        nfs_exports {
        client_configurations {
        clients = "*"
        options = ["rw", "crossmnt", "all_squash"]
        }
    }
}
}

output "fsx_dns_address" {
  value = aws_fsx_openzfs_file_system.shared_ddc_file_system.dns_name
}

output "fsx_arn" {
  value = aws_fsx_openzfs_file_system.shared_ddc_file_system.arn
}

output "fsx_id" {
  value = aws_fsx_openzfs_file_system.shared_ddc_file_system.id
}

output "security_group_id" {
  value = aws_security_group.shared_ddc_sg.id
}