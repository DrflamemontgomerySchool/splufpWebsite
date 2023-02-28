var express = require('express')

function nav_data(name, href) {
  return {
    name: name,
    href, href
  };
}

const navigation_headers = { title: 'Express', links:
  [
    nav_data('Home', '/'),
    nav_data('Documentation', '/docs/home')
  ]
};

module.exports = navigation_headers;
