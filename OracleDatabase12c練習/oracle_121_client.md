# Oracle 12c クライアントインストール #

[Oracle® Database Clientインストレーション・ガイド 12c リリース1 (12.1) for Linux](https://docs.oracle.com/cd/E57425_01/121/LACLI/toc.htm)

~~~bash
# インストール確認
binutils-2.23.52.0.1-12.el7.x86_64
compat-libcap1-1.10-3.el7.x86_64
compat-libstdc++-33-3.2.3-71.el7.x86_64
gcc-4.8.2-3.el7.x86_64
gcc-c++-4.8.2-3.el7.x86_64
glibc-2.17-36.el7.x86_64
glibc-devel-2.17-36.el7.x86_64
ksh
libaio-0.3.109-9.el7.x86_64
libaio-devel-0.3.109-9.el7.x86_64
libgcc-4.8.2-3.el7.x86_64
libstdc++-4.8.2-3.el7.x86_64
libstdc++-devel-4.8.2-3.el7.x86_64
libXi-1.7.2-1.el7.x86_64
libXtst-1.2.2-1.el7.x86_64
make-3.82-19.el7.x86_64
sysstat-10.1.5-1.el7.x86_64
~~~

~~~bash
cat /etc/redhat-release # CentOS Linux release 7.7.1908 (core)
groupadd -g 54321 oinstall
groupadd -g 54322 dba
useradd -g oinstall -G dba oracle
passwd oracle # test1234
mkdir -p /u01/app
chown -R oracle:oinstall /u01/app
chmod -R 775 /u01/app/
export DISPLAY=:0
xhost +
su - oracle
umask
env | more # ORACLE_HOME,ORACLE_BASE,ORACLE_SID,TNS_ADMINが空文字確認、PATHに$ORACLE_HOME/binがないこと
export ORACLE_BASE = /u01/app/oracle
export DISPLAY=:0
mkdir /tmp/OraCl12c
# /tmp/linuxamd64_12102_client.zip
unzip -d /tmp/OraCl12c /tmp/linuxamd64_12102_client.zip
cd /tmp/OraCl12c/client
./runInstaller # 文字化けの場合、日本語JRE指定
# ./runInstaller -jreLoc `dirname $(dirname $(readlink $(readlink $(which java))))`
~~~

~~~bash


~~~
