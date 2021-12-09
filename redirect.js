var http = require('http')

http.createServer((req, res) => {
    res.redirect('https://' + req.headers.host + req.url)
})

http.listen(80)