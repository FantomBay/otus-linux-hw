yum install -y redhat-lsb-core wget rpmdevtools rpm-build createrepo yum-utils
wget https://nginx.org/packages/centos/7/SRPMS/nginx-1.14.1-1.el7_4.ngx.src.rpm

rpm -i nginx-1.14.1-1.el7_4.ngx.src.rpm
wget https://www.openssl.org/source/latest.tar.gz

tar -xvf latest.tar.gz
yum-builddep -y rpmbuild/SPECS/nginx.spec
#yum-builddep nginx -y
yum install -y epel-release.noarch 
yum-builddep -y nginx

wget -O /root/rpmbuild/SPECS/nginx.spec https://raw.githubusercontent.com/FantomBay/homework6/master/mod_spec_file.txt

rpmbuild -ba rpmbuild/SPECS/nginx.spec
#локальная установка
yum localinstall -y rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm 
systemctl start nginx
systemctl status ngin
curl -a http://localhost

#создаем свой репозиторий
mkdir -p /usr/share/nginx/html/repo

cp /root/rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm /usr/share/nginx/html/repo
#add percona in my repo
#wget http://www.percona.com/downloads/percona-release/redhat/0.1-6/percona-release-0.1-6.noarch.rpm -O /usr/share/nginx/html/repo/percona-release-0.1-6.noarch.rpm

createrepo /usr/share/nginx/html/repo/


#vi rpmbuild/BUILD/nginx-1.14.1/src/http/modules/ngx_http_autoindex_module.c
cat >/etc/nginx/conf.d/default.conf<<__EOF
server {
    listen       80;
    server_name  localhost;
    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
        autoindex on;
    }
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
__EOF

nginx -t
nginx -s reload

curl -a http://localhost/repo/




##############   REPO   #################


#start main script
#install utils
sudo -i
sudo yum install -y redhat-lsb-core wget rpmdevtools rpm-build createrepo yum-utils

sudo wget -O /root/nginx-1.14.1-1.el7_4.ngx.src.rpm https://nginx.org/packages/centos/7/SRPMS/nginx-1.14.1-1.el7_4.ngx.src.rpm
sudo rpm -i /root/nginx-1.14.1-1.el7_4.ngx.src.rpm

sudo wget -O /root/latest.tar.gz https://www.openssl.org/source/latest.tar.gz
sudo tar -xvf /root/latest.tar.gz
#download dependencies
sudo yum-builddep -y /root/rpmbuild/SPECS/nginx.spec

yum install -y epel-release.noarch 
yum-builddep nginx -y

sudo wget -O /root/rpmbuild/SPECS/nginx.spec https://raw.githubusercontent.com/FantomBay/homework6/master/mod_spec_file.txt

sudo rpmbuild -ba /root/rpmbuild/SPECS/nginx.spec
#локальная установка
sudo yum localinstall -y /root/rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm 
sudo systemctl start nginx
systemctl status nginx
#curl -a http://localhost

#создаем свой репозиторий
sudo mkdir -p /usr/share/nginx/html/repo

sudo cp /root/rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm /usr/share/nginx/html/repo
#add percona in my repo
#wget http://www.percona.com/downloads/percona-release/redhat/0.1-6/percona-release-0.1-6.noarch.rpm -O /usr/share/nginx/html/repo/percona-release-0.1-6.noarch.rpm

sudo createrepo /usr/share/nginx/html/repo/

sudo cat >/etc/nginx/conf.d/default.conf<<__EOF
server {
    listen       80;
    server_name  localhost;
    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
        autoindex on;
    }
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
__EOF

sudo nginx -t
sudo nginx -s reload

curl -a http://localhost/repo/








###############   SERVER   #################

#add new repo otus-linux
cat >> /etc/yum.repos.d/otus.repo << EOF
[otus]
name=otus-linux
baseurl=http://10.0.0.41/repo
gpgcheck=0
enabled=1
EOF