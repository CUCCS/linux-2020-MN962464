#!/usr/bin/env bash

apt-get update
if [[ $? -ne 0 ]]; then
	echo "apt-get update failed!"
	exit
fi

#判断系统是否已安装vsftpd
command -v vsftpd > /dev/null
if [[ $? -ne 0 ]]; then
	apt-get install -y vsftpd
	if [[ $? -ne 0 ]]; then
		echo "failed to install vsftpd!"
		exit
	fi
else
	echo "vsftpd is already installed."
fi

#判断文件是否已有备份
if [[ ! -f /etc/vsftpd.conf.bak ]]; then
	#备份文件
	cp /etc/vsftpd.conf /etc/vsftpd.conf.bak
else
	echo "/etc/vsftpd.conf.bak already exits."
fi

#匿名用户访问FTP设置
#创建匿名用户可访问的文件夹
anony_path="/var/ftp/pub"
if [[ ! -d "$anony_path" ]];
then
	mkdir -p "$anony_path"
fi

#设置pub文件夹访问权限
chown nobody:nogroup "$anony_path"
echo "vsftpd test file for anonymous user" | tee "${anony_path}/test_a.txt"

#修改配置文件vsftpd.conf
#允许匿名下载
sed -i -e "/anonymous_enable=/s/NO/YES/g;/anonymous_enable=/s/#//g" /etc/vsftpd.conf
#允许本地登录
sed -i -e "/local_enable=/s/NO/YES/g;/local_enable=/s/#//g" /etc/vsftpd.conf
# 允许更改文件系统
sed -i -e "/write_enable=/s/NO/YES/g;/write_enable=/s/#//g" /etc/vsftpd.conf
#将用户限制在其主目录中
sed -i -e "/chroot_local_user=/s/NO/YES/g;/chroot_local_user=/s/#//g" /etc/vsftpd.conf
#不允许匿名用户上传文件
sed -i -e "/anon_upload_enable=/s/YES/NO/g;/anon_upload_enable=/s/#//g" /etc/vsftpd.conf
#允许匿名用户在某些条件下创建新目录
sed -i -e "/anon_mkdir_write_enable=/s/YES/NO/g" /etc/vsftpd.conf
#默认传输日志/var/log/xferlog
sed -i -e "/xferlog_file=/s/#//g" /etc/vsftpd.conf

#设置用户名和密码方式访问的账号
user="poggio"
# 添加用户
if [[ $(grep -c "^$user:" /etc/passwd) -eq 0 ]];then
		useradd "$user"
		echo "$user:poggio" | chpasswd
else
		echo "User ${user} is already exits~"
fi

#创建用户目录
user_path="/home/${user}/ftp"
if [[ ! -d "$user_path" ]];
then
		mkdir -p "$user_path"
else
		echo "${user_path} is already exited!"
fi

# 设置所有权
chown nobody:nogroup "$user_path"
# 删除写权限
chmod a-w "$user_path"
# 验证权限
ls -la "$user_path"
# 为用户创建upload目录
writeable_path="${user_path}/files"
if [[ ! -d "$writeable_path" ]];
then
		mkdir -p "$writeable_path"
else
		echo "${writeable_path} is already exited!"
fi

#修改文件夹属主
chown "$user":"$user" "$writeable_path"
ls -la "$writeable_path"
echo "vsftpd test file for the login user" | tee "${writeable_path}/test_u.txt"

echo poggio > /etc/vsftpd.userlist
echo anonymous >> /etc/vsftpd.userlist

if [[ -z $(cat /etc/vsftpd.conf | grep "userlist_file=/etc/vsftpd.userlist") ]]; then
	cat<<EOT >>/etc/vsftpd.conf
local_root=/home/%LOCAL_ROOT%/ftp
userlist_file=/etc/vsftpd.userlist
userlist_enable=YES
userlist_deny=NO
anon_root=/var/ftp/
no_anon_password=YES
hide_ids=YES
pasv_min_port=40000
pasv_max_port=50000
tcp_wrappers=YES
EOT
fi

#完成模板变量动态赋值，并保持幂等性
sed -i -e "s#%LOCAL_ROOT%#/home/$user/ftp#g" /etc/vsftpd.conf

#只允许白名单用户访问ftp
grep -q "vsftpd: ALL"  /etc/hosts.deny || echo "vsftpd: ALL" >> /etc/hosts.deny
grep -q "vsftpd:127.0.0.1"  /etc/hosts.deny || echo "vsftpd:127.0.0.1" >> /etc/hosts.allow

service vsftpd restart

