#!/usr/bin/env sh

cat > $NGINX_DIR/snippets/letsencryptauth.conf <<EOF
location /.well-known/acme-challenge {
    alias /var/www/html/.well-known/acme-challenge;
    location ~ /.well-known/acme-challenge/(.*) {
        add_header Content-Type application/jose+json;
    }
}
EOF

cat > $NGINX_DIR/sites-available/unifi <<EOF
upstream unifi_ssl {
    server $SSL_UPSTREAM;
}

upstream unifi {
    server $UPSTREAM;
}

server {
    listen 443 ssl;
    listen [::]:443 ssl;

    server_name $UNIFI_HOSTNAME;

    ssl on;
    ssl_certificate $SSL_CERT;
    ssl_certificate_key $SSL_KEY;

    location /wss/ {
        proxy_pass https://unifi_ssl;
        include proxy_params;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    location / {
        proxy_pass https://unifi_ssl;
        include proxy_params;
    }
}

server {
    listen 80;
    listen [::]:80;

    server_name \$unifi_hostname;

    include snippets/letsencryptauth.conf;

    location /inform {
        proxy_pass http://unifi/inform;
        include proxy_pass;
    }

    location / {
        return 301 https://\$http_host\$request_uri;
    }
}
EOF

rm -rf $NGINX_DIR/sites-enabled/unifi
ln -s $NGINX_DIR/sites-available/unifi $NGINX_DIR/sites-enabled/unifi
