
# RemoteLabs
Full docker-based setup of Guacamole, with HTTPS via Nginx and TLS certificate via Certbot/Let's Encrypt.

Used for lab environment access at Cornerstone Group AB.

## Requirements
The solution has been tested on Ubuntu 18.04 and 20.04. Theoretically any OS with Docker and Docker-Compose should be supported.

## Installaton
1. Download or clone this repository to the server where you wish to run the solution.
2. Create a copy of ".env.sample" named ".env" and fill the details relevant to your scenario.
3. Replace any placeholders (marked by '<' and '>') by the relevant value. Lines starting with '#' are comments and can be ignored.
4. Make sure that the FQDN(s) specified in the `CERTBOT_DOMAINS` variable point to the IP address where this solution will be hosted.
5. Run `docker-compose up`.
	- On the first run the `mysql` & `certbot` containers will take a while to start up, as they need to perform initial configuration: creating the guacamole DB and retrieving a certificate.
	- During this time, the `proxy` container will fail with exit-code 1 as the certificate for HTTPS is not available.
	- Once all containers have been initialized, the application should be online, however you will still receive a certificate warning when you browse to the site, because by default the app will get a staging/testing certificate from Let's Encrypt (this needs to be disabled in the .env).
	- Log in as guacadmin (default password 'guacadmin') to verify that everything is working as intended.
	- Take this opportunity to change the password of guacadmin (under 'settings' -> 'preferences').
6. Once you have verified that everything is up and running, bring the application down with `docker-compose down`.
7. Edit the ".env" file to comment out the `CERTBOT_STAGING` variable (or change it to something other than 1, true and yes). This will disable the staging/testing mode.
8. Remove the `certbot/.data` folder, this will cause the `certbot` to retrieve a new certificate the next time it starts.
9. The application should now be running and ready for public consumption.

## Components
All component containers have been separated into folders based on the underlying tech:
 - Guacd: Guacamole daemon, used to connect to local lab machines.
 - Guacamole: Guacamole frontend.
 - Sql: MySQL server used by Guacamole to store configuration/authentication data.
 - certbot: Used to retrieve and maintain a certificate from Let's Encrypt to allow HTTPS via the Proxy.
 - Nginx
   - Proxy: Provides HTTPS support and routing.
   - Redirect: HTTP server listening on port 80, used to redirect HTTP requests to the proxy for HTTPS and exposes the /.well-known/letsencrypt path for certbot validation.
 - "Files": used to 

Each component has a .data folder where it's internal state is stored. Removing this folder will reset the component. In the case of Sql this will reset the entire Guacamole insallation. Removing the .data folder for Certbot forces it to request a new certificate, which comes in handy if you want to change the domains covered by the certificate.
