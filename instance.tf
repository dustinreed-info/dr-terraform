# resource "aws_instance" "dr-info-test-1" {
#   ami                    = "ami-0b69ea66ff7391e80"
#   instance_type          = "t2.micro"
#   vpc_security_group_ids = ["${aws_security_group.dr-tf-sg-dmz.id}"]
#   subnet_id              = "${aws_subnet.dr-tf-sub-dmz-a.id}"
#   key_name               = "${aws_key_pair.auth.id}"

#   connection {
#     user        = "ec2-user"
#     host        = "${self.public_ip}"
#     type        = "ssh"
#     private_key = "${file("~/.ssh/terraform.pem")}"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "sudo yum update -y",
#       "sudo yum upgrade -y",
#       "sudo yum install git -y",
#       "git clone https://github.com/dustinreed-info/dr-info-website-flask",
#       "sudo yum install python37 -y",
#       "pip3 install flask python-dotenv flask-wtf gunicorn --user",
#     ]
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "cd ~/dr-info-website-flask",
#       "git checkout dev",
#       "sudo cp ./drinfo.service /etc/systemd/system/drinfo.service",
#       "sudo systemctl daemon-reload",
#       "sudo systemctl start drinfo",
#     ]
#   }
# }

# resource "aws_instance" "dr-info-test-2" {
#   ami                    = "ami-0b69ea66ff7391e80"
#   instance_type          = "t2.micro"
#   vpc_security_group_ids = ["${aws_security_group.dr-tf-sg-dmz.id}"]
#   subnet_id              = "${aws_subnet.dr-tf-sub-dmz-b.id}"
#   key_name               = "${aws_key_pair.auth.id}"

#   connection {
#     user        = "ec2-user"
#     host        = "${self.public_ip}"
#     type        = "ssh"
#     private_key = "${file("~/.ssh/terraform.pem")}"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "sudo yum update -y",
#       "sudo yum upgrade -y",
#       "sudo yum install git -y",
#       "git clone https://github.com/dustinreed-info/dr-info-website-flask",
#       "sudo yum install python37 -y",
#       "pip3 install flask python-dotenv flask-wtf gunicorn --user",
#     ]
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "cd ~/dr-info-website-flask",
#       "git checkout dev",
#       "sudo cp ./drinfo.service /etc/systemd/system/drinfo.service",
#       "sudo systemctl daemon-reload",
#       "sudo systemctl start drinfo",
#     ]
#   }
# }