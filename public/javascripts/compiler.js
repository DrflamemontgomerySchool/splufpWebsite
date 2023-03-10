var executable = undefined;

function compile_code() {
  var editor = ace.edit('splufp-editor')
  var code = editor.getValue();

  var req = new XMLHttpRequest();
  req.open('POST', '/compile', true);
  req.setRequestHeader('Content-Type', 'application/json'); 
  var data = new FormData();
  data.append('code', code);

  req.onload = function() {
    executable = this.responseText;
    run_code();
  };

  req.send(JSON.stringify({"code" : code}));
}

function run_code() {
  document.getElementById('text-output').textContent = '';
  var canvas = document.getElementById('graphics-canvas');
  var ctx = canvas.getContext('2d');
  ctx.clearRect(0, 0, canvas.width, canvas.height);

  eval(`${executable}; __spl__main.call();`);
}

console.log = function(str) {
  document.getElementById('text-output').textContent += `${str}\n`;
}
