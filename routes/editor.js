// import modules
var express = require('express');
var router = express.Router();
var navbar = require('./navbar');

// debug logging
console.log(navbar);

/* GET home page. */
router.get('/', function(req, res, next) {
  // render the editor with the navbar data
  res.render('editor', navbar);
  next();
});

module.exports = router;
