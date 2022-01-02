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
            certbot certonly --webroot -w /var/www/certbot -d $CERTBOT_DOMAINS --non-interactive --agree-tos -m $CERTBOT_EMAIL & wait $!
            domains=$(echo $CERTBOT_DOMAINS | tr "," "\n")
            main_domain=(domains)
            cp "etc/letsencrypt/live/$main_domain/cert.pem" /certificate_pub/cert.pem
            cp "etc/letsencrypt/live/$main_domain/privkey.pem" /certificate_pub/key.pem
    fi
done
