var executable = undefined;

function compile_code() {
  var editor = ace.edit('splufp-editor')
  var code = editor.getValue();

  var req = new XMLHttpRequest();
  req.open('POST', '/compile', true);
  req.setRequestHeader('Content-Type', 'application/json'); 

  var text = document.getElementById('text-output');
  text.textContent = "Waiting to Compile";

  req.onload = function() {
    executable = this.responseText;
    var response = JSON.parse(this.responseText);
    if(response["error"] != undefined) {
      text.textContent = "ERROR COMPILING\n"
      text.textContent += response["error"].split('\n').map((s) => {
        return s.replace(/^\s+/, "")
      }).reduce((a, b) => {
        return `${a}\n${b}`;
      });
    } else if(response["exec"] != undefined) {
      executable = response["exec"];
      on_compiled();
    } else {
      text.textContent = "Internal Server Error"; 
    }
  };

  req.send(JSON.stringify({"code" : code}));

}

function on_compiled() {
  var text = document.getElementById('text-output');
  function onwait() {
    text.textContent += '.';
  }
  
  setTimeout(onwait, 500);
  setTimeout(onwait, 1000);
  setTimeout(onwait, 1500);

  setTimeout(function() {
      text.textContent += '\nCode Compiled';
  }, 2000);
}

function run_code() {
  var text = document.getElementById('text-output');
  text.textContent = 'Waiting to run';
  function onwait() {
    text.textContent += '.';
  }
  var canvas = document.getElementById('graphics-canvas');
  var ctx = canvas.getContext('2d');
  ctx.clearRect(0, 0, canvas.width, canvas.height);

  setTimeout(onwait, 500);
  setTimeout(onwait, 1000);
  setTimeout(onwait, 1500);
  setTimeout(function(){
    text.textContent += "\nCalling main function";
  }, 2000);
  setTimeout(function(){
    if(executable == undefined || executable == "") {
      text.textContent += '\nNo executable provided';
      return;
    }
    text.textContent = '';
    try {
      eval(`${executable}; __spl__main.call();`);
    } catch(e) {
      console.log(`ERROR: ${e}`);
    }
  }, 4000);
}

console.log = function(str) {
  document.getElementById('text-output').textContent += `${str}\n`;
}
