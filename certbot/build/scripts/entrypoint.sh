#!/bin/sh
trap exit TERM;

echo "Strarting certbot entrypoint.sh"

while true
do       
    domains=$(echo $CERTBOT_DOMAINS | tr "," "\n")
    main_domain=$(echo "$domains" | head -n 1)

    echo "Domains to cover:"
    echo $domains

    selfsigned=$(echo $CERTBOT_SELFSIGNED | tr '[:upper:]' '[:lower:]')

    echo "Use self-signed certificate: $selfsigned"

    case "$selfsigned" in
        yes|1|true)

            echo "Using self-signed certificate..."
	    openssl version

            # Self-signed scertificae
            certdirectory="/certificate_pub"

            if test ! -d $certdirectory; then
                mkdir $certdirectory
            fi

            #TODO: Use openssl to generate /certificate-pub/key.pem and /certificate-pub/cert.pem
            certpath="$certdirectory/cert.pem" 
            keypath="$certdirectory/key.pem"
            invalidcert=false
            
	    echo "Checking certificate validity..."
            if test -f $certpath; then
		echo "Certificate already exists, checking if the certificate is about to expire in the next 7 days..."
                openssl x509 -in $certpath -checkend 604800
                if test $? -eq 0; then
                    echo "Ceritificate is ok."
		else
		    echo "Certificate is about to expire."
	            invalidcert=true
                fi
	    else
		echo "No certificate found."
		invalidcert=true
            fi

            if $invalidcert; then
		echo "Generating a new certificate (CN=$main_domain)..."
		echo "New certpath: $certpath"
		echo "New keypath: $keypath"
                subject="/CN=$main_domain"
                cmd="openssl req -x509 -out $certpath -keyout $keypath -newkey rsa:2048 -days 365 -subj \"$subject\" -batch -nodes"

		san="subjectAltName="

		for domain in ${domains//\\n/ }
		do
		    echo "Adding Subject Alternate Name: $domain"
                    san="${san}DNS:$domain,"
	        done

                san=${san::-1}
                cmd="$cmd -addext \"${san}\""

		echo "Running command: $cmd"
                eval $cmd & wait $!
            fi
            ;;
        *)
            # Let's Encrypt (default behavior)
            certdirectory="/etc/letsencrypt/live"

            if test -d $certdirectory; then
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

            srcpath="$certdirectory/$main_domain/fullchain.pem"
            dstpath="/certificate_pub/cert.pem"
            echo "Exporting: $srcpath --> $dstpath"
            cp --update $srcpath $dstpath
            srcpath="$certdirectory/$main_domain/privkey.pem"
            dstpath="/certificate_pub/key.pem"
            echo "Exporting: $srcpath --> $dstpath"
            cp --update $srcpath $dstpath
            ;;
    esac
    sleep 12h
done
