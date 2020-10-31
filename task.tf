provider "aws"{
region="ap-south-1"
access_key="******"
secret_key="**********"
}

resource "aws_security_group" "sg"{
name="security_group"
description="Allow HTTP and SSH traffic"
vpc_id="vpc-f9073d91"

ingress{
description="HTTP"
from_port=80
to_port=80
protocol="tcp"
cidr_blocks=["0.0.0.0/0"]
}
ingress{
description="HTTPS"
from_port=443
to_port=443
protocol="tcp"
cidr_blocks=["0.0.0.0/0"]
}

ingress{
description="SSH"
from_port=22
to_port=22
protocol="tcp"
cidr_blocks=["0.0.0.0/0"]
}
egress {
from_port   = 0
to_port     = 0
protocol    = "-1"
cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami           = "ami-005956c5f0f757d37"
  instance_type = "t2.micro"
  key_name = "key1"
  security_groups = [ "${aws_security_group.sg.name}" ]


  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/KIIT/Downloads/key1.pem")
    host     = aws_instance.web.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd 	git -y",
      "sudo sudo service httpd start",
    ]
  }
}


resource "aws_ebs_volume" "ebs1" {
  availability_zone = aws_instance.web.availability_zone
  size              = 1
}


resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.ebs1.id}"
  instance_id = "${aws_instance.web.id}"
  force_detach = true
}

resource "null_resource" "nullremote3"  {

depends_on = [
    aws_volume_attachment.ebs_att,
  ]


  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/KIIT/Downloads/key1.pem")
    host     = aws_instance.web.public_ip
  }

provisioner "remote-exec" {
    inline = [
      "sudo mkfs.ext4  /dev/xvdh",
      "sudo mount  /dev/xvdh  /var/www/html",
      "sudo rm -rf /var/www/html/*",
      "sudo git clone https://github.com/********/taskpage.git /var/www/html/",
	"sudo mv index.html /var/www/html",
	"sudo service httpd restart"
	
    ]
  }
}


