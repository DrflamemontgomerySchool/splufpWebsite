var express = require('express');
var router = express.Router();
var navbar = require('./navbar');


function create_doc(name, link) {
  return {name: name, link: link};
}

const documentation_list = [
  create_doc('home', 'home'),


  create_doc('introduction', 'introduction'),
  create_doc('installation', 'installation')
];

function create_link(header, children)  {
  return { header : header, children : children };
}

const sidebar_links = [
  create_link(undefined, [
      create_doc('Home', 'home')
  ]),

  create_link('Getting Started', [
      create_doc('Introduction', 'introduction'),
      create_doc('Installation', 'installation')
  ]),

  create_link('Getting Started', [
      create_doc('Introduction', 'introduction'),
      create_doc('Installation', 'installation')
  ])
];

var render_information = navbar;
render_information.sidebar = sidebar_links;

for(doc of documentation_list) {
  console.log(`linking docs_${doc.name}`);
  router.get(`/${doc.link}`, function(doc_link, doc_name) { return function(req, res, next) {
    var ri = render_information;
    ri.active_link = doc_link;
    res.render(`docs_${doc_name}`, ri);
    next();
  }}(doc.link, doc.name));
}

module.exports = router;
