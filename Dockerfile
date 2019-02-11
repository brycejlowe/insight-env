FROM centos:7

# add the necessary yum repos
RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    rpm -Uvh https://centos7.iuscommunity.org/ius-release.rpm

# install the required binaries via yum
RUN yum install -y \
    httpd24u httpd24u-mod_ssl \
    php72u php72u-pdo php72u-mysqlnd php72u-gd php72u-intl php72u-ldap \
    pear1u php72u-devel php72u-soap php72u-cli php72u-mbstring php72u-json \
    gcc gcc-c++ make unixODBC unixODBC-devel \
    subversion && \
    yum clean all

# install required pecl packages
RUN pecl install sqlsrv pdo_sqlsrv xdebug-2.6.1

# overwrite the main apache configuration
COPY ./httpd/httpd.conf /etc/httpd/conf/
COPY ./httpd/ssl.conf /etc/httpd/conf.d/

# remove un-used configurations
RUN rm -rf /etc/httpd/conf.d/autoindex.conf \
     /etc/httpd/conf.d/userdir.conf \
     /etc/httpd/conf.d/welcome.conf

# remove un-used modules
RUN rm -rf /etc/httpd/conf.modules.d/00-dav.conf \
    /etc/httpd/conf.modules.d/00-lua.conf \
    /etc/httpd/conf.modules.d/00-optional.conf \
    /etc/httpd/conf.modules.d/00-proxy.conf \
    /etc/httpd/conf.modules.d/00-systemd.conf

# add our custom configs
RUN mkdir -pv /etc/httpd.custom
COPY ./httpd/options/* /etc/httpd.custom/

# add the DEFAULT ssl certificates
RUN mkdir -pv /etc/httpd.certs/ && \
     cp /etc/pki/tls/certs/localhost.crt /etc/httpd.certs/server.crt && \
     cp /etc/pki/tls/private/localhost.key /etc/httpd.certs/server.key && \
     cp /etc/pki/tls/certs/localhost.crt /etc/httpd.certs/ca.crt

RUN ln -s /dev/stdout /var/log/httpd/access_log && \
     ln -s /dev/stderr /var/log/httpd/error_log

# overwrite the php configuration
COPY ./php/php.ini /etc/php.ini

# add custom php ini files
RUN mkdir -pv /etc/php.custom
COPY ./php/options/* /etc/php.custom/

# setup environment variables
ENV APACHE_SERVER_NAME=localhost
ENV APP_ENV=development

ENV XDEBUG_REMOTE_ENABLE=0
ENV XDEBUG_REMOTE_HANDLER=dbgp
ENV XDEBUG_REMOTE_IP=127.0.0.1
ENV XDEBUG_REMOTE_PORT=9000
ENV XDEBUG_IDE_KEY=IDE_KEY

ENV XDEBUG_PROFILE_ENABLE_TRIGGER=0
ENV XDEBUG_PROFILE_TRIGGER_VALUE=DO_PROFILE
ENV XDEBUG_PROFILE_OUTPUT_DIR=/tmp
ENV XDEBUG_PROFILE_OUTPUT_NAME=cachegrind.out.%t%s

COPY ./entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 80 443
CMD [ "/usr/sbin/httpd", "-DFOREGROUND" ]
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
