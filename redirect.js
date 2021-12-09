var http = require('express')()

http.get('*', ((req, res) => {
    res.redirect('https://' + req.headers.host + req.url)
}))

http.listen(80)