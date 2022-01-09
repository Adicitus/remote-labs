
# RemoteLabs
Full docker-based setup of Guacamole, with HTTPS via Nginx and TLS certificate via Certbot/Let's Encrypt.

Used for lab environment access at Cornerstone Group AB.

## Installaton
1. Create a copy of ".env.sample" named ".env" and fill the details relevant to your scenario.
2. Replace any placeholders (marked by '<' and '>') by the relevant value. Lines starting with '#' are comments and can be ignored.
3. Make sure that the FQDN(s) specified in the `CERTBOT_DOMAINS` variable point tot the IP address where this application will be hosted.
4. Run `docker-compose up`.
	- On the first run the `mysql` & `certbot` containers will take a while to start up, as they need to perform initial configuration: creating the guacamole DB and retrieving a certificate.
	- During this time, the `proxy` container will fail with exit-code 1 as the certificate for HTTPS is not available.
	- Once all containers have been initialized, the application should be online, however you will still receive a certificate warning when you browse to the site, because by default the app will get a staging/testing certificate from Let's Encrypt.
	- Log in as guacadmin (default password 'guacadmin') to verify that everything is working as intended.
	- Take this opportunity to change the password of guacadmin (under 'settings' -> 'preferences').
5. Once you have verified that everything is up and running, bring the application down with `docker-compose down`.
6. Edit the ".env" file to comment out the `CERTBOT_STAGING` variable (or change it to something other than 1, true and yes). This will disable the staging/testing mode.
7. Remove the `certbot/.data` folder, this will cause the `certbot` to retrieve a new certificate the next time it starts.
8. The application should now be running and ready for public consumption.