#!/bin/bash

VAGRANT_PROVISION=/var/vagrant/provison

if [ ! -d $VAGRANT_PROVISION ];then
    echo "==== Create $VAGRANT_PROVISION ===="
    mkdir -p $VAGRANT_PROVISION
fi

yum update

if [ ! -f $VAGRANT_PROVISION/git ];then
    echo "==== Install Git ===="
    yum -y -q install git
    touch $VAGRANT_PROVISION/git
fi

if [ ! -f $VAGRANT_PROVISION/ja ];then
    echo "==== Configure ja settings ===="
    localectl set-locale LANG=ja_JP.UTF-8
    mv /etc/localtime /etc/localtime.org
    ln -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
    touch $VAGRANT_PROVISION/ja
fi

if [ ! -f $VAGRANT_PROVISION/emacs ];then
    echo "==== Install Emacs ===="
    yum -y -q install emacs
    touch $VAGRANT_PROVISION/emacs
fi

if [ ! -f $VAGRANT_PROVISION/docker ];then
    # Thanks to http://qiita.com/jpshadowapps/items/a68173b4c044cfea2ab6
    echo "==== Install Docker ===="
    pushd /usr/bin
    wget https://get.docker.io/builds/Linux/x86_64/docker-latest -O docker
    chmod +x docker
    pushd /etc/systemd/system
    wget https://raw.githubusercontent.com/docker/docker/master/contrib/init/systemd/docker.service
    wget https://raw.githubusercontent.com/docker/docker/master/contrib/init/systemd/docker.socket
    sed -i -e "s/\-H fd:\/\//-H fd:\/\/ -H tcp:\/\/0.0.0.0:2375/g" docker.service
    groupadd docker
    systemctl daemon-reload
    systemctl start docker
    systemctl status docker
    systemctl enable docker.service
    cat <<'EOF' > /etc/profile.d/docker.sh
export DOCKER_HOST="tcp://0.0.0.0:2375"
EOF
#    firewall-cmd --permanent --zone=public --add-port=2375/tcp
#    firewall-cmd --reload
    touch $VAGRANT_PROVISION/docker
fi

if [ ! -f $VAGRANT_PROVISION/docker-compose ];then
    echo "==== Install Docker Compose ===="
    pushd /usr/bin
    wget https://github.com/docker/compose/releases/download/1.2.0/docker-compose-Linux-x86_64 -O docker-compose
    chmod +x docker-compose
    touch $VAGRANT_PROVISION/docker-compose
fi