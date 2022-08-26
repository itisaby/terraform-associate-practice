

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDCytvGH/9FwYRnib3auR9+8t4DCvt6ZsDNtPl5bIPEDxBIIdX1whoJJgY8M2OIisTKIFGDM227JVSDD+VZ7mi8tp6mLVBsR/5qXkLKeJ3Q2t69MHqdBI5vyHuB4tlUc54ssTmWLf6j/MR5qMxpPAmigugwQt05LFRawq9QkIp0lX27rMNlBOgrJvneCqyCCX/cn+IT2UkeCW/B6Hq87j9OaAkDviPTlcq43DO546WDNOS2vZ+MkEmTWCIapMEXRVnGYoUpaEJPE5FXm+EJZvZonWe5vj1g/i1q8Pjyox09UTwjbS2sdE2VcHobPZLO0NeOAuzt5j5hTaeXZDhjg6pwrf5DBFtCe10zagRWOhhOJj5nXlIPyR2daL7v7A037kAQItRbExcsa3d6bvWESSRecdaoFGgtu5J9u5gW22Ij9i5q5kqjoRsU3DkqXjbfEMFwpVJLVGg2Lv7TaBjq7JFbY31XPZpRF5bQqWwGbGLWfPjbRjZiEi2ql/HssKA11Gk= arnab@arnab-HP-Pavilion-x360-Convertible-14-dh1xxx"
}

data "template_file" "user_data" {
  template = file("./userdata.yml")
}

resource "aws_instance" "app_server" {
  ami                    = "ami-090fa75af13c156b4"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.sg_server.id]
  user_data              = data.template_file.user_data.rendered
  # Local Exec
  # provisioner "local-exec" {
  #   command = "echo ${self.private_ip} >> private_ips.txt"
  # }
  # Remote Exec
  # Doubt1
  # provisioner "remote-exec" {
  #   inline = [
  #     "echo ${self.private_ip} >> home/ec2-user/private_ips.txt",
  #     # "puppet apply",
  #     # "consul join ${aws_instance.web.private_ip}",
  #   ]
  #   connection {
  #     type     = "ssh"
  #     user     = "ec2-user"
  #     host     = "${self.public_ip}"
  #     private_key = "${file("/home/arnab/.ssh/id_rsa")}"
  #   }
  # }
  # File Provisioner
  # provisioner "file" {
  #   content    = "ami used: ${self.ami}"
  #   destination = "/home/ec2-user/ami_used.txt"
  #   connection {
  #     type     = "ssh"
  #     user     = "ec2-user"
  #     host     = "${self.public_ip}"
  #     private_key = "${file("/home/arnab/.ssh/id_rsa")}"
  #   }
  # }

  tags = {
    Name = "MyServer2"
  }
}
# NULL RESOURCE 
resource "null_resource" "status" {
  provisioner "local-exec" {
    command = "aws ec2 wait instance-status-ok --instance-ids ${aws_instance.app_server.id}"
  }
  depends_on = [
    aws_instance.app_server
  ]
}

output "public_ip" {
  value = aws_instance.app_server.public_ip
}
