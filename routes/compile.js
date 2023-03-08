var express = require('express');
var router = express.Router();
var navbar = require('./navbar');
var fs = require('fs');
var crypto = require('crypto');
var exec = require('child_process');
var util = require('util');
var bodyParser = require('body-parser');

var jsonParser = bodyParser.json();

console.log(navbar);
/* POST compiler. */

router.post('/', function(req, res) {
  var data = req.body.code;
  var file = '/tmp/splufp-' + crypto.randomUUID() + '.spl';
  fs.writeFile(file, data, err => {
    if(err) {
      res.send('err');
    }
    else {
      var out = '/tmp/splufp-js-' + crypto.randomUUID() + '.js';
      exec.exec(`node splufp-interpreter/bin/js/main.js splufp-interpreter/spl/* --out=${out} ${file}`, (error, stdout, stderr) => {
        if(error) {
          res.send('err');
        }
        else {
          res.sendFile(out);
        }
      });
    }
  });
});

module.exports = router;
