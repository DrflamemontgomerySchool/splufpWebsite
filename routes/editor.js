var express = require('express');
var router = express.Router();
var navbar = require('./navbar');

console.log(navbar);
/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('editor', navbar);
  next();
});

module.exports = router;
