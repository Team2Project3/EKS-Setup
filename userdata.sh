#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras install epel -y
sudo yum install https://dev.mysql.com/get/mysql180-community-release-e17-5.noarch.rpm -y
sudo yum install mysql-community-server -y
sudo amazon-linux-extras enable php8.0
sudo yum clean metadata
sudo yum install php-cli php-pdo php-fpm php-mysqlnd
sudo yum install -y httpd
sudo systemctl start httpd
sudo chkconfig httpd on
sudo systemctl start mysqld
sudo systemctl status mysqld
wget https://wordpress.org/latest.tar.gz
tar -xzvf latest.tar.gz
sudo mv wordpress /var/www/html/
cd /var/www/html/wordpress
sudo cp /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php
sudo nano wp-config.php
sed -i 's/database_name_here/wordpress/' /var/www/html/wordpress/wp-config.php
sed -i 's/username_here/wordpress/' /var/www/html/wordpress/wp-config.php
sed -i 's/password_name_here/password/' /var/www/html/wordpress/wp-config.php
sed -i 's/localhost/team1.ccozhjrzeaj6.us-east-1.rds.amazonaws.com/' /var/www/html/wordpress/wp-config.php
