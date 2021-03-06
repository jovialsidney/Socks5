#!/bin/sh
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

#Check OS
if [ -n "$(grep 'Aliyun Linux release' /etc/issue)" -o -e /etc/redhat-release ];then
    OS=CentOS
    [ -n "$(grep ' 7\.' /etc/redhat-release)" ] && CentOS_RHEL_version=7
    [ -n "$(grep ' 6\.' /etc/redhat-release)" -o -n "$(grep 'Aliyun Linux release6 15' /etc/issue)" ] && CentOS_RHEL_version=6
    [ -n "$(grep ' 5\.' /etc/redhat-release)" -o -n "$(grep 'Aliyun Linux release5' /etc/issue)" ] && CentOS_RHEL_version=5
elif [ -n "$(grep 'Amazon Linux AMI release' /etc/issue)" -o -e /etc/system-release ];then
    OS=CentOS
    CentOS_RHEL_version=6
elif [ -n "$(grep bian /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == 'Debian' ];then
    OS=Debian
    [ ! -e "$(which lsb_release)" ] && { apt-get -y update; apt-get -y install lsb-release; clear; }
    Debian_version=$(lsb_release -sr | awk -F. '{print $1}')
elif [ -n "$(grep Deepin /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == 'Deepin' ];then
    OS=Debian
    [ ! -e "$(which lsb_release)" ] && { apt-get -y update; apt-get -y install lsb-release; clear; }
    Debian_version=$(lsb_release -sr | awk -F. '{print $1}')
elif [ -n "$(grep Ubuntu /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == 'Ubuntu' -o -n "$(grep 'Linux Mint' /etc/issue)" ];then
    OS=Ubuntu
    [ ! -e "$(which lsb_release)" ] && { apt-get -y update; apt-get -y install lsb-release; clear; }
    Ubuntu_version=$(lsb_release -sr | awk -F. '{print $1}')
    [ -n "$(grep 'Linux Mint 18' /etc/issue)" ] && Ubuntu_version=16
else
    echo "Does not support this OS, Please contact the author! "
    kill -9 $$
fi

#Install Basic Tools
if [[ ${OS} == Ubuntu ]];then
	echo ""
	echo "***********************"
	echo "*目前不支持Ubuntu系统！*"
	echo "*请使用CentOS搭建     *"
	echo "**********************"
	exit 0
	apt-get install git unzip wget -y
	
fi
if [[ ${OS} == CentOS ]];then
	
	yum install git unzip wget -y
   
fi
if [[ ${OS} == Debian ]];then
	echo "***********************"
	echo "*目前不支持Debian系统！*"
	echo "*请使用CentOS搭建     *"
	echo "**********************"
	apt-get install git unzip wget -y
    
fi

service ss5 stop
rm -rf ss5-3.8.9
rm -rf /etc/opt/ss5
rm -f /usr/local/bin/s5
clear
echo "旧环境清理完毕！"
echo ""
echo "安装Socks5所依赖的组件,请稍等..."
yum -y install gcc gcc-c++ automake make pam-devel openldap-devel cyrus-sasl-devel openssl-devel

check(){
if [ ! -f "/usr/local/bin/s5" ] || [ ! -f "/etc/opt/ss5/service.sh" ]; then
  echo ""
  echo "缺失文件，安装失败！！！"
  echo "发送邮件反馈bug ：wyx176@gmail.com"
  echo "或者添加Telegram群反馈"
  echo "Telegram群：t.me/Socks55555"
  exit 0

else
echo ""
service ss5 start
echo ""
echo "Socks5安装成功！"
echo ""
echo "输入"s5"启动Socks5控制面板"
echo ""
echo "Socks5服务可能不会随系统开机启动"
echo ""
echo "默认用户名: 123456"
echo "默认密码  : 654321"
echo "默认端口  : 5555"
echo ""
echo "添加Telegram群组@Socks55555及时获取更新"
echo ""
fi
}

echo ""
echo "下载Socks5服务中..."
#wget https://sourceforge.net/projects/ss5/files/ss5/3.8.9-8/ss5-3.8.9-8.tar.gz

wget -q -N --no-check-certificate https://raw.githubusercontent.com/wyx176/Socks5/master/ss5-3.8.9-8.tar.gz
wget -q -N --no-check-certificate https://raw.githubusercontent.com/wyx176/Socks5/master/ss5.tar.gz



echo ""
echo "解压文件中..."
tar zxvf ./ss5-3.8.9-8.tar.gz

echo ""
rm ss5-3.8.9-8.tar.gz
echo "安装中..."

cd ss5-3.8.9
ls
./configure
make
make install

echo "安装中2..."
cd /root
mv ss5.tar.gz /etc/opt/ss5/
cd /etc/opt/ss5/
tar -xzvf ss5.tar.gz
rm ss5.tar.gz

cd /etc/opt/ss5/
git clone https://github.com/wyx176/Socks5
chmod -R 777 /etc/opt/ss5/Socks5
cd /etc/opt/ss5/Socks5

mv s5 /usr/local/bin/
mv service.sh /etc/opt/ss5/
mv user.sh /etc/opt/ss5/
mv uss5.tar.gz /etc/opt/ss5/
mv ss5 /etc/sysconfig/

cd /etc/opt/ss5/
tar -xzvf uss5.tar.gz
rm -rf /etc/opt/ss5/Socks5
chmod +x /usr/local/bin/s5

if [ ! -d "/var/run/ss5/" ];then
mkdir /var/run/ss5/
echo "create ss5 success!"
else
echo "/ss5/ is OK!"
fi

chmod +x /etc/init.d/ss5
chkconfig --add ss5
chkconfig --level 345 ss5 on

cd /root
rm install.sh

check
