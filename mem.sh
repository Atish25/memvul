#!/bin/sh
#!/bin/bash
echo -e "\e[31;43m**Disable Memcache (SERVER SUPPORT TEAM - CISPL) *****\e[0m"
#
if [ -e '/usr/bin/memcached' ]; then
service memcached restart && chkconfig memcached on;
  else
yum install memcached -y && service memcached restart && chkconfig memcached on;
 fi
if [ -e '/usr/bin/memcached' ]; then
ex -sc '%s/OPTIONS=""/OPTIONS="-l 127.0.0.1 -U 0"/g|x' /etc/sysconfig/memcached && service memcached restart;
else
yum install memcached -y && ex -sc '%s/OPTIONS=""/OPTIONS="-l 127.0.0.1 -U 0"/g|x' /etc/sysconfig/memcached && service memcached restart;
fi
if [ -e '/usr/bin/netstat' ]; then
netstat -an | grep ":11211"
else
yum install net-tools -y && yum install curl -y;
fi
echo -e "\e[31;43m*****DISABLE IPV6 *****\e[0m"
sysctl -w net.ipv6.conf.all.disable_ipv6=1
sleep 10s
#publicip=curl icanhazip.com
publicip=$(curl icanhazip.com)
if [ -e '/usr/bin/nmap' ]; then
echo -e "\e[31;43m*****CHECK MEMCACHED PORT STATUS *****\e[0m" && nmap -p 11211 $publicip
 else
yum install nmap -y && echo -e "\e[31;43m*****CHECK MEMCACHED PORT STATUS *****\e[0m" && nmap -p 11211 $publicip
sleep 10s
fi
if [ -e '/etc/csf/csf.conf' ]; then
service csf status >> /tmp/csf.txt
grep -q "inactive" /tmp/csf.txt
if [ $? -ne 0 ]; then
echo -e "\e[31;43m*****CSF FIREWALL IS RUNNING *****\e[0m"
sleep 5s
service csf stop
cp -R /etc/csf /etc/csf_bak
cd /etc/csf/ && sh uninstall.sh
cd /usr/src && wget https://download.configserver.com/csf.tgz && tar -xzf csf.tgz && cd csf && sh install.sh
ex -sc '%s/RESTRICT_SYSLOG = "0"/RESTRICT_SYSLOG = "2"/g|x' /etc/csf/csf.conf
ex -sc '%s/AUTO_UPDATES = "1"/AUTO_UPDATES = "0"/g|x' /etc/csf/csf.conf
ex -sc '%s/TCP_IN = "20,21,22,25,53,80,110,143,443,465,587,993,995,2077,2078,2079,2080,2082,2083,2086,2087,2095,2096"/TCP_IN = "20,21,22,25,53,80,110,143,443,465,587,993,995,2077,2078,2079,2080,2083,2087,49152:65534,2096"/g|x' /etc/csf/csf.conf
ex -sc '%s/TCP_OUT = "20,21,22,25,37,43,53,80,110,113,443,587,873,993,995,2086,2087,2089,2703"/TCP_OUT = "20,21,22,25,37,43,53,80,110,113,443,587,873,993,995,2086,2087,2089,2703,49152:65534,2096"/g|x' /etc/csf/csf.conf
cat <<EOT >> /etc/csf/csf.allow
180.87.240.74/29
111.93.172.122/29
103.250.86.42/29
118.185.76.18/29
203.171.33.10
api.konnektive.com
80.248.30.132
EOT
ex -sc '%s/TESTING = "1"/"TESTING = "0"/g|x' /etc/csf/csf.conf && service csf start
service csf start
service csf restart
rm -rf /tmp/csf.txt
if [ -e '/usr/bin/nmap' ]; then
echo -e "\e[31;43m*****CHECK MEMCACHED PORT STATUS *****\e[0m" && nmap -p 11211 $publicip
sleep 5s 
else
yum install nmap -y && echo -e "\e[31;43m*****CHECK MEMCACHED PORT STATUS *****\e[0m" && nmap -p 11211 $publicip
fi
else
echo -e "\e[31;43m*** CSF IS NOT RUNNING ****\e[0m"
fi
else
echo -e "\e[31;43m*** ITS A CLI SERVER ****\e[0m"
rm -rf /tmp/csf.txt && memcache.sh
rm -f memcache.sh
if [ -e '/usr/bin/nmap' ]; then
echo -e "\e[31;43m*****CHECK MEMCACHED PORT STATUS *****\e[0m" && nmap -p 11211 $publicip
 else
yum install nmap -y && echo -e "\e[31;43m*****CHECK MEMCACHED PORT STATUS *****\e[0m" && nmap -p 11211 $publicip
fi
exit 1
fi
