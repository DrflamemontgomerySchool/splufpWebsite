var express = require('express');
var router = express.Router();
var navbar = require('./navbar');


// information that will be parsed into the pug compiler
var render_information = navbar;

router.get('/', function(req, res, next) {
  res.render('examples', {script_src : `example/${req.query.script}`});
  next()
});

module.exports = router;
