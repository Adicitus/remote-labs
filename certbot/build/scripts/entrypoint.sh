#!/bin/sh
trap exit TERM;

while true
do
    if test -d /etc/letsencrypt/live; then
        echo "Checking if the certificate needs to be renewed."
        certbot renew & wait $!
    else
        echo "Attempt to get a certificate for the given domains ($CERTBOT_DOMAINS)"
        cmd="certbot certonly --webroot -w /var/www/certbot -d $CERTBOT_DOMAINS --non-interactive --agree-tos -m $CERTBOT_EMAIL"
        staging=$(echo $CERTBOT_STAGING | tr '[:upper:]' '[:lower:]')
        if [ -n ${CERTBOT_STAGING+x} ]; then
            staging=$(echo $CERTBOT_STAGING | tr '[:upper:]' '[:lower:]')
            if [[ $staging == yes ]]
            then
                echo "Getting a staging certificate.."
                cmd="$cmd --staging"
            fi
        fi
        echo "Running: $cmd"
        $cmd & wait $!
    fi
    
    domains=$(echo $CERTBOT_DOMAINS | tr "," "\n")
    main_domain=$(echo "$domains" | head -n 1)
    srcpath="/etc/letsencrypt/live/$main_domain/fullchain.pem"
    dstpath="/certificate_pub/cert.pem"
    echo "Exporting: $srcpath --> $dstpath"
    cp --update $srcpath $dstpath
    srcpath="/etc/letsencrypt/live/$main_domain/privkey.pem"
    dstpath="/certificate_pub/key.pem"
    echo "Exporting: $srcpath --> $dstpath"
    cp --update $srcpath $dstpath
    sleep 12h
done
