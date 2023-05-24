//========================================---
//  SPLUFP DATA TYPE HOLDER
//========================================---

class __splufp__function {
  #value;
  constructor(value) {
    if(typeof(value) == 'function') {
      // wrap in a function to prevent auto calling if we don't have arguments
      if(value.length > 0) {
        this.value = function() { return value };
        return;
      }
    }

    this.value = value;
  }

  // allow us to call the function
  call() {
    if(typeof(this.value) == "function") {
      return this.value();
    }
    return this.value;
  }
}

class __splufp__function_assignable {
  #value;
  constructor(value) {
    if(typeof(value) == 'function') {
      // wrap in a function to prevent auto calling if we don't have arguments
      if(value.length > 0) {
        this.value = function() { return value };
        return;
      }
    }
    this.value = value;
  }

  // allow us to call the function
  call() {
    if(typeof(this.value) == "function") {
      return this.value();
    }
    return this.value;
  }

  // allow us to modify the function value
  set_value(value) {
    this.value = value;
  }
}

//========================================---
//  SPLUFP EXTERNAL JAVASCRIPT FUNCTIONS
//========================================---

// reduce an array
function foldl(fn, init, arr) {
  if(arr.length > 1) {
    return foldl(fn, fn(new __splufp__function(init))(new __splufp__function(arr[0])), arr.slice(1, arr.length));
  }
  else if(arr.length > 0) {
    return fn(new __splufp__function(init))(new __splufp__function(arr[0]));
  }
  return init;
}

// reduce an array
function foldr(fn, init, arr) {
  if(arr.length > 1) {
    return fn(new __splufp__function(arr[0]))(new __splufp__function(foldr(fn, init, arr.slice(1, arr.length))));
  }
  else if(arr.length > 0) {
    return fn(new __splufp__function(arr[0]))(new __splufp__function(init));
  }
  return init;
}

// iterate over an array of elements
function map(fn, arr) {
  if(arr.length > 0) {
    fn(new __splufp__function(arr[0]));
    map(fn, arr.slice(1, arr.length));
  }
}

// wait 'ms' amount of milliseconds
function delay(ms) {
  var now = new Date().getTime();
  while(new Date().getTime() < now + ms){ /* Do nothing */ }
}
