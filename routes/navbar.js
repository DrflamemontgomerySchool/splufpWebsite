var express = require('express')


// helper function for generating navigation data
function nav_data(name, href) {
  return {
    name: name,
    href, href
  };
}


// This variable is exported so that every other file does not need to rewrite the navigation info
const navigation_headers = { title: 'Express', links:
  [
    nav_data('Home', '/'),
    nav_data('Documentation', '/docs/home'),
    nav_data('Try Splufp', '/editor')
  ]
};

module.exports = navigation_headers;
