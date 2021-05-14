provider "aws" {

region = "ap-south-1"
access_key = ""
secret_key = ""
}


resource "aws_instance" "webos1" {
 
  ami = "ami-010aff33ed5991201"
  instance_type = "t2.micro"
  security_groups =  ["launch-wizard-1"]
  key_name = "terraform-key"

  tags = {
    Name = "Web Server by TF"
  }



}


resource "null_resource"  "nullremote1" {

connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/AS/Desktop/Terraform LW/terraform-key.pem")
    host     = aws_instance.webos1.public_ip
  }

provisioner "remote-exec" {
    inline = [
      "sudo yum  install httpd  -y",
      "sudo  yum  install php  -y",
      "sudo systemctl start httpd",
      "sudo systemctl enable httpd"
    ]
  }

}

resource "aws_ebs_volume" "example" {
  availability_zone = aws_instance.webos1.availability_zone
  size              = 1

  tags = {
    Name = "Web Server HD by TF"
  }
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdc"
  volume_id   = aws_ebs_volume.example.id
  instance_id = aws_instance.webos1.id
  force_detach = true
}



resource "null_resource"  "nullremote2" {



connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/AS/Desktop/Terraform LW/terraform-key.pem")
    host     = aws_instance.webos1.public_ip
  }

provisioner "remote-exec" {
    inline = [
      "sudo mkfs.ext4 /dev/xvdc",
      "sudo  mount /dev/xvdc  /var/www/html",
    ]
  }

}



resource "null_resource"  "nullremote4" {



connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/AS/Desktop/Terraform LW/terraform-key.pem")
    host     = aws_instance.webos1.public_ip
  }

provisioner "remote-exec" {
    inline = [
      "sudo yum install git -y",
      "sudo git clone https://github.com/aarati0122/sample-webpage.git   /var/www/html/web"
    ]
  }

}


resource "null_resource"  "nullremote5" {



provisioner "local-exec" {
   command = "start chrome http://65.2.73.247/web/index.php"
  }

}
