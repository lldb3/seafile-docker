    # set platform as amd64, since some qemu libs work with x86-64
FROM --platform=linux/amd64 ubuntu:22.04

ENV LANG=C.UTF-8 \
    DEBIAN_FRONTEND=noninteractive

RUN \
    apt-get update && apt-get upgrade -y &&\
    apt-get install --no-install-recommends -y \
    wget supervisor nginx crudini ffmpeg mysql-client libmysqlclient-dev \
    python3 python3-setuptools python3-pip \
    memcached libmemcached-dev

RUN \
    apt-get install gcc libffi-dev python3-dev -y && \
    pip3 install --upgrade pip && \
    pip3 install --timeout=3600 django==3.2.* Pillow pylibmc captcha jinja2 sqlalchemy==1.4.3 \
    django-pylibmc django-simple-captcha python3-ldap mysqlclient pycryptodome==3.12.0 cffi==1.14.0 && \
    apt-get remove -y --purge --autoremove gcc libffi-dev python3-dev && \
    rm -rf /var/lib/apt/lists/* && \
    rm -f /etc/nginx/sites-enabled/*

ENV SEAFILE_VERSION 9.0.4
ENV SEAFILE_PATH "/opt/seafile/$SEAFILE_VERSION"

RUN \
    mkdir -p /seafile "${SEAFILE_PATH}" && \
    wget --progress=dot:mega --no-check-certificate -O /tmp/seafile-server.tar.gz \
        "https://download.seadrive.org/seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz" && \
    tar -xzf /tmp/seafile-server.tar.gz --strip-components=1 -C "${SEAFILE_PATH}" && \
    sed -ie '/^daemon/d' "${SEAFILE_PATH}/runtime/seahub.conf" && \
    rm /tmp/seafile-server.tar.gz

COPY etc/ /etc/
COPY scripts/ /scripts/

RUN \
    chmod +x /scripts/*.sh && \
    mkdir -p /run/seafile && \
    ln -s /run/seafile /opt/seafile/pids && \
    ln -s "${SEAFILE_PATH}" /opt/seafile/latest && \
    ln -s /etc/nginx/sites-available/seafile.conf /etc/nginx/sites-enabled/seafile.conf && \
    ln -s /scripts/setup.sh /bin/setup && \
    ln -s /usr/local/bin/python3 /usr/local/bin/python && \
    mkdir -p /seafile/ccnet && \
    mkdir -p /seafile/seafile-data && \
    mkdir -p /seafile/seahub-data && \
    mkdir -p /seafile/logs && \
    mkdir -p /seafile/conf 

# Patch setup-seafile-mysql.py to support existing directories on setup
# This will also generate ccnet configuration inside a tmp directory as it doesn't support generation inside existing directory
RUN sed -i -r "s/seafile_config\.validate_seafile_dir\(seafile_dir\)/seafile_dir/" ${SEAFILE_PATH}/setup-seafile-mysql.py &&\
sed -i -r "s/Utils\.error\('Ccnet config dir.*/pass/" ${SEAFILE_PATH}/setup-seafile-mysql.py &&\
sed -i -r "s/self\.ccnet_dir = os.path.join\(env_mgr\.top_dir, 'ccnet'\)/self.ccnet_dir = os.path.join(env_mgr.top_dir, 'ccnet.tmp')/" ${SEAFILE_PATH}/setup-seafile-mysql.py

WORKDIR "/seafile"

VOLUME "/seafile/ccnet" "/seafile/seafile-data" "/seafile/seahub-data" "/seafile/conf"

EXPOSE 80

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
