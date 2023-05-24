var express = require('express');
var router = express.Router();
var navbar = require('./navbar');

console.log(navbar);
/* GET home page. */
router.get('/', function(req, res, next) {
  // render the index page with the navbar
  res.render('index', navbar);
  next();
});

module.exports = router;
