# OpenSSH #

## OpenSSHのsftpログ取得 ##

~~~bash
# ログ出力設定
vi /etc/ssh/sshd_config
# Subsystem sftp internal-sftp -f AUTH -l INFO

# SSH再起動
systemctl restart sshd

# CentOS7ログ
tail -f /var/log/messages
# 日時、ユーザ、操作などが記録できる

# chrootの場合、ログディレクトリにアクセスできないので、ログファイルのアクセスや設定に注意
~~~
