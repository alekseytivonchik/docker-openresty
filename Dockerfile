FROM openresty/openresty:1.19.3.2-alpine-apk
ARG RESTY_VERSION 
ENV VERSION=$RESTY_VERSION

# Download sources
RUN wget "http://openresty.org/download/openresty-${VERSION}.tar.gz" -O openresty-${VERSION}.tar.gz
RUN apk add --no-cache --virtual .build-deps \
  gcc \
  libc-dev \
  make \
  openssl-dev \
  pcre-dev \
  zlib-dev \
  linux-headers \
  curl \
  gnupg \
  libxslt-dev \
  gd-dev \
  geoip-dev

ENV CONFARGS="-j2 --with-http_ssl_module --with-http_realip_module --with-ngx_http_v2_module --with-http_addition_module --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_random_index_module --with-http_secure_link_module --with-http_stub_status_module --with-http_auth_request_module --with-http_xslt_module=dynamic --with-http_image_filter_module=dynamic --with-http_geoip_module=dynamic --with-threads --with-stream --with-stream_ssl_module --with-http_slice_module --with-mail --with-mail_ssl_module --with-file-aio --with-ipv6 --with-http_v2_module --with-cc-opt='-g -O2 -fstack-protector --param=ssp-buffer-size=4 -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2' --with-ld-opt='-Wl,-z,relro -Wl,--as-needed'"
RUN tar -zxC /opt/ -f openresty-${RESTY_VERSION}.tar.gz && \
    cd /opt/openresty-${RESTY_VERSION} && \
    ./configure "$CONFARGS" && \
    make && \
    make install && \
    rm -rf /etc/nginx/conf.d && \
    rm -f /usr/local/openresty/nginx/conf/nginx.conf

COPY nginx/conf.d /etc/nginx/conf.d
COPY nginx/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
# COPY nginx/common /usr/local/openresty/nginx/conf/common
# COPY nginx/certs /usr/local/openresty/nginx/conf/certs

EXPOSE 80
EXPOSE 443
# STOPSIGNAL SIGTERM
# CMD ["nginx", "-g", "daemon off;"]