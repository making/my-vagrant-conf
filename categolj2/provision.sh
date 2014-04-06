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
    wget -q --no-check-certificate --no-cookies - --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8-b132/jdk-8-linux-x64.rpm
    rpm -ivh --quiet jdk-8-linux-x64.rpm*
    cat <<'EOF' > /etc/profile.d/java.sh
export JAVA_HOME=/usr/java/jdk1.8.0
export PATH=$PATH:$JAVA_HOME/bin
EOF
    popd > /dev/null
    touch $VAGRANT_PROVISION/jdk8
fi

## Maven
if [ ! -f $VAGRANT_PROVISION/maven ];then
    echo "==== Install Maven ===="
    MAVEN_VERSION=3.2.1
    mkdir -p /opt/maven
    pushd /opt/maven > /dev/null
    wget -q http://archive.apache.org/dist/maven/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz
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

if [ ! -f $VAGRANT_PROVISION/categolj2 ];then
    echo "==== Install CategoLJ2 ===="
    git clone https://github.com/making/categolj2-backend.git
    pushd categolj2-backend > /dev/null
    bash -c "mvn -q -Dmaven.test.skip=true clean package"
    cp scripts/categolj2.sh /etc/init.d/categolj2
    chmod +x /etc/init.d/categolj2
    mkdir -p /usr/lib/categolj2
    cp target/categolj2-backend.jar /usr/lib/categolj2/
    chmod +x /usr/lib/categolj2/categolj2-backend.jar
    cat <<'EOF' > /etc/sysconfig/categolj2
CATEGOLJ2_JAVA_OPTIONS="-Xms1g -Xmx1g -Xloggc:gc.log -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=5 -XX:GCLogFileSize=10M -XX:+HeapDumpOnOutOfMemoryError"
EOF
    chkconfig --add categolj2
    chkconfig categolj2 on
    /etc/init.d/categolj2 start
    popd > /dev/null
    chown -R vagrant:vagrant categolj2-backend
    touch $VAGRANT_PROVISION/categolj2
fi