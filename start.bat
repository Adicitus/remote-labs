cd %~pd0\public
node "%~pd0\node_modules\http-server\bin\http-server" -p 443 -S -C C:\certs\remotelabs.cornerstone.se-crt.pem -K C:\certs\remotelabs.cornerstone.se-key.pem
