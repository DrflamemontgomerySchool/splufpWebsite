var express = require('express');
var router = express.Router();
var navbar = require('./navbar');


// helper function for generating document links
function create_doc(name, link) {
  return {name: name, link: link};
}


// list of the links and their pug_file_name
const documentation_list = [
  create_doc('home', 'home'),


  create_doc('introduction', 'introduction'),
  create_doc('installation', 'installation')
];


// create the different documentation sidebars
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
  ])
];


// information that will be parsed into the pug compiler
var render_information = navbar;
render_information.sidebar = sidebar_links;


for(doc of documentation_list) {
  console.log(`linking docs_${doc.name}`);

  // route the available pages
  router.get(`/${doc.link}`,
    function(doc_link, doc_name) {
      return function(req, res, next) {
        var ri = render_information;
        ri.active_link = doc_link;
        res.render(`docs_${doc_name}`, ri);
        next();
      }
    }(doc.link, doc.name) // We need to have a helper function to make sure the variable
  );                      // values are not overwritten

}

module.exports = router;
