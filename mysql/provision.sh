#!/bin/bash

VAGRANT_PROVISION=/var/vagrant/provison

if [ ! -d $VAGRANT_PROVISION ];then
    echo "==== Create $VAGRANT_PROVISION ===="
    mkdir -p $VAGRANT_PROVISION
fi

if [ ! -f $VAGRANT_PROVISION/git ];then
    echo "==== Install Git ===="
    yum -y -q install git
    touch $VAGRANT_PROVISION/git
fi

if [ ! -f $VAGRANT_PROVISION/ja ];then
    echo "==== Configure ja settings ===="
    sed -i -e 's/en_US/ja_JP/' /etc/sysconfig/i18n 
    mv /etc/localtime /etc/localtime.org
    ln -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
    touch $VAGRANT_PROVISION/ja
fi

if [ ! -f $VAGRANT_PROVISION/emacs ];then
    echo "==== Install Emacs ===="
    yum -y -q install emacs
    touch $VAGRANT_PROVISION/emacs
fi

if [ ! -f $VAGRANT_PROVISION/mysql ];then
    echo "==== Install MySQL ===="
    yum -y install http://dev.mysql.com/get/mysql-community-release-el6-5.noarch.rpm
    yum -y -q install mysql-community-server
    usermod -G vagrant mysql
    chkconfig mysqld on
    /etc/init.d/mysqld stop
    mkdir -p /vagrant/var/lib/mysql
    cp -f /vagrant/my.cnf /etc/my.cnf
    /etc/init.d/mysqld start
    mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO app@localhost IDENTIFIED BY 'paSsw0rd';"
    mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO app@'%' IDENTIFIED BY 'paSsw0rd';"
    mysql -u root -e 'FLUSH PRIVILEGES;'
    touch $VAGRANT_PROVISION/mysql
fi