#!/bin/bash
sudo yum update -y
sudo yum upgrade -y
sudo yum install git -y
git clone https://github.com/dustinreed-info/dr-info-website-flask /tmp/dr-info
sudo yum install python37 -y
sudo pip3 install flask python-dotenv flask-wtf gunicorn
sudo cp /tmp/dr-info/drinfo.service /etc/systemd/system/drinfo.service
sudo systemctl daemon-reload
sudo systemctl start drinfo