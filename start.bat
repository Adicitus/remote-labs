cd %~pd0\public
start node "%~pd0\redirect.js"
node "%~pd0\node_modules\http-server\bin\http-server" -p 443 -S -C C:\certs\remotelabs.cornerstone.se-crt.pem -K C:\certs\remotelabs.cornerstone.se-key.pem