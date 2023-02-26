var express = require('express');
var router = express.Router();

function nav_data(name, href) {
  return {
    name: name,
    href, href
  };
}

/* GET home page. */
router.get('/', function(req, res, next) {
  var pass_through_data = { title: 'Express', links:
    [
      nav_data('Navbar1', '/Navbar1'),
      nav_data('Navbar2', '/Navbar2'),
      nav_data('Navbar3', '/Navbar3')
    ]
  };
  console.log(pass_through_data);
  res.render('index', pass_through_data);
  next();
});

module.exports = router;
