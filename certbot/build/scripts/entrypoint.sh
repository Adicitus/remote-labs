#!/bin/sh
trap exit TERM;

while true
do
    if test -d /etc/letsencrypt/live; then
        # Check if the certificate needs to be renewed.
        certbot renew & wait $!
    else
        # Attempt to get a certificate for the given domains.
        certbot certonly --webroot -w /var/www/certbot -d $CERTBOT_DOMAINS --non-interactive --agree-tos -m $CERTBOT_EMAIL & wait $!
    fi
    
    domains=$(echo $CERTBOT_DOMAINS | tr "," "\n")
    main_domain=$(echo "$domains" | head -n 1)
    srcpath="/etc/letsencrypt/live/$main_domain/cert.pem"
    dstpath="/certificate_pub/cert.pem"
    echo "Exporting: $srcpath --> $dstpath"
    cp --update $srcpath $dstpath
    srcpath="/etc/letsencrypt/live/$main_domain/privkey.pem"
    dstpath="/certificate_pub/key.pem"
    echo "Exporting: $srcpath --> $dstpath"
    cp --update $srcpath $dstpath
    sleep 12h
done
