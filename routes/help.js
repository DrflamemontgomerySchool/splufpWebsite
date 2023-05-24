var express = require('express');
var router = express.Router();
var navbar = require('./navbar');

// debug log
console.log(navbar);

// Generate a FAQ description
function gen_faq(header, body) {
  return {header:header, body:body}
}

// Generate all the FAQs
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
  // render the help page
  res.render('help', navbar);
  next();
});

module.exports = router;
