var express = require('express');
var router = express.Router();
var navbar = require('./navbar');

console.log(navbar);

function gen_faq(header, body) {
  return {header:header, body:body}
}

const faqs = [
  gen_faq(
    "Where can I report Issues?",
    "Contact my email <a href='mailto:ashton.warner@kingsway.school.nz'>ashton.warner@kingsway.school.nz</a>"
  )
];

var output = navbar;
output["faq"] = faqs

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('help', navbar);
  next();
});

module.exports = router;
