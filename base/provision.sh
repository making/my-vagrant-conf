#!/bin/bash

VAGRANT_PROVISION=/var/vagrant/provison

if [ ! -d $VAGRANT_PROVISION ];then
    echo "==== Create $VAGRANT_PROVISION ===="
    mkdir -p $VAGRANT_PROVISION
fi

## JDK8
if [ ! -f $VAGRANT_PROVISION/jdk8 ];then
    echo "==== Install JDK8 ===="
    pushd /tmp > /dev/null
    wget -q --no-check-certificate --no-cookies - --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u51-b16/jdk-8u51-linux-x64.rpm
    rpm -ivh jdk*.rpm*
    cat <<'EOF' > /etc/profile.d/java.sh
export JAVA_HOME=/usr/java/jdk1.8.0_51
export PATH=$PATH:$JAVA_HOME/bin
EOF
    popd > /dev/null
    touch $VAGRANT_PROVISION/jdk8
fi

## Maven
if [ ! -f $VAGRANT_PROVISION/maven ];then
    echo "==== Install Maven ===="
    MAVEN_VERSION=3.3.3
    mkdir -p /opt/maven
    pushd /opt/maven > /dev/null
    wget -q http://ftp.yz.yamagata-u.ac.jp/pub/network/apache/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz
    tar xzf apache-maven-$MAVEN_VERSION-bin.tar.gz
    ln -s /opt/maven/apache-maven-$MAVEN_VERSION /opt/maven/maven3
    rm -f apache-maven-$MAVEN_VERSION-bin.tar.gz
    cat <<'EOF' > /etc/profile.d/maven.sh
export MAVEN_HOME=/opt/maven/maven3
export PATH=$PATH:$MAVEN_HOME/bin
EOF
    popd > /dev/null
    touch $VAGRANT_PROVISION/maven
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
