// import the packages
var express = require('express');
var router = express.Router();
var navbar = require('./navbar');
var fs = require('fs');
var crypto = require('crypto');
var exec = require('child_process');
var util = require('util');
var bodyParser = require('body-parser');
var jsonParser = bodyParser.json();

// log the navbar for debugging purposes
console.log(navbar);
/* POST compiler. */

router.post('/', function(req, res) {
  // receive the code
  var data = req.body.code;
  
  // generate a temporary splufp file name
  var file = '/tmp/splufp-' + crypto.randomUUID() + '.spl';
  
  // write the code to the temporary file
  fs.writeFile(file, data, err => {
    if(err) { // catch errors
      res.send('err');
    }
    else {
      // generate a temporary javascript file name
      var out = '/tmp/splufp-js-' + crypto.randomUUID() + '.js';

      // run the transpiler using the splufp file as input and the javascript file as an output
      exec.exec(`node splufp-interpreter/bin/js/main.js --out=${out} ${file}`, (error, stdout, stderr) => {
        // if the code errors, send the error report to the client
        if(error) { 
          var output = { "error" : stderr };
          console.log(`I errored out: """${stderr}"""`);
          res.send(output);
        }
        else {
          // read the javascript file and send the data
          fs.readFile(out, 'utf-8', (err, data) => {
            if(err) {
              res.send({ "error" : error });
            }
            else {
              res.send({ "exec" : data });
            }
          });
        }
      });
    }
  });
});

module.exports = router;
