const express = require('express')

let app = express()
app.use(express.static('public', {
    index:false
}))
let server = require('http').createServer(app)

server.listen(80)
