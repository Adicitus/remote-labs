#!/bin/sh
trap exit TERM;

while true
do
    if test -d /etc/letsencrypt/live; then
        # Check if the certificate needs to be renewed.
        certbot renew & wait $!
        sleep 12h
        else
            # Attempt to get a certificate for the given domains.
            certbot certonly --webroot -w /var/www/certbot -d $CERTBOT_DOMAIN --non-interactive --agree-tos -m $CERTBOT_EMAIL
    fi
done
