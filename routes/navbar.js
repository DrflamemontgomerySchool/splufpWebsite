var express = require('express')

function nav_data(name, href) {
  return {
    name: name,
    href, href
  };
}

const navigation_headers = { title: 'Express', links:
  [
    nav_data('Documentation', '/docs/introduction'),
    nav_data('Navbar2', '/Navbar2'),
    nav_data('Navbar3', '/Navbar3')
  ]
};

module.exports = navigation_headers;
