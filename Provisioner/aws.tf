

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQChSsbugq2zCyah1PHYoGieu/ACBNtw5pWirCQXDet8OhxzxcaBx9T/8U0Egt801OqjSJtScFwd9FkUT30jKlOmHS5y2QCF0MU0kenSZHCJQ9+yjpXKoHmH8ocfcj1/JLpdjqtjoZkdzc8InkxiEo4QH3CeBs8JWU/eSfaEGsrzcm+45cIUwHimGe6Y/MBJcGJp2AJgtdhtEK3arswbQLm0mSlDqwPbqy7xAFuIYAr5WqRLFzNs3vIGlx1wVNzHeIKaJUaaq+1WMHa0G/HGtPRPNa0x/OLGhczcFdhpLRO5fcMaxmXAtt358BMyk4K8PugZ801+Nk//59qu8cozYzuIRYUDRrMGMSIefm9ksf99BmX+oPwWbetPCevP5vXzwMz6wzawXscbQyj9K1cj5pZ2uPOf1ChYF6V+1pJmskSZ23U8KBQPb7afNGkqB6KV5xDMoNeD0xJGkgf7TIAH9n4BWXeO3qyoK5MtaCVovJwOQaI1mX+cP+GV4XgeHVj3yI8= arnab@arnab-HP-Pavilion-x360-Convertible-14-dh1xxx"
}

data "template_file" "user_data" {
  template = file("./userdata.yml")
}
# data "template_file" "private_key" {
#   template = file("/home/arnab/.ssh/terraform")
# }

resource "aws_instance" "app_server" {
  ami                    = "ami-090fa75af13c156b4"
  instance_type          = "t2.micro"
  key_name               = "${aws_key_pair.deployer.key_name}"
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
  #     "echo ${self.private_ip} >> /home/ec2-user/private_ips.txt",
  #     # "puppet apply",
  #     # "consul join ${aws_instance.web.private_ip}",
  #   ]
  #   connection {
  #     type     = "ssh"
  #     user     = "ec2-user"
  #     host     = "${self.public_ip}"
  #     private_key = data.template_file.private_key.rendered
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
