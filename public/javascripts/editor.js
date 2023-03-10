
// setup the styles and modes
ace.config.setModuleUrl(
  "ace/theme/nord_dark",
  "http://ajaxorg.github.io/ace-builds/src-noconflict/theme-nord_dark.js"
);

ace.config.setModuleUrl(
  "ace/mode/javascript",
  "http://ajaxorg.github.io/ace-builds/src-noconflict/mode-javascript.js"
);
ace.config.setModuleUrl(
  "ace/mode/haskell",
  "http://ajaxorg.github.io/ace-builds/src-noconflict/mode-haskell.js"
);
ace.config.setModuleUrl(
  "ace/mode/lisp",
  "http://ajaxorg.github.io/ace-builds/src-noconflict/mode-lisp.js"
);

// optional modes are javascript, haskell, lisp, and splufp
// splufp is not implemented yet
function make_editor(name, mode = 'javascript') {
  var editor = ace.edit(name);
  editor.setShowPrintMargin(false); // Gets rid of the annoying line in the middle
  editor.setTheme('ace/theme/nord_dark');
  editor.session.setMode(`ace/mode/${mode}`);
  editor.renderer.setPadding(2);

  editor.setOption('tabSize', 2);
  // Setup options from element classes
  var elem_classes = document.getElementById(name).classList;
  for(c of elem_classes) {
    switch(c) {
      case 'ace_readonly':
        editor.setOption('readOnly', true);
        editor.setOption('highlightActiveLine', true);
        break;
      case 'ace_hide_line_numbers':
        editor.setOption('showLineNumbers', false);
        break;
    }
    // matches strings that are ace_line-height-NUMOFLINES
    const re = /^ace_line-height-([0-9]*)$/;
    if(c.match(re)) {
      // extract number value and set maxLines
      editor.setOption('maxLines', parseInt(c.replace(re, '$1')));
      continue;
    }
    const min_re = /^ace_min-line-height-([0-9]*)$/;
    if(c.match(min_re)) {
      // extract number value and set maxLines
      editor.setOption('minLines', parseInt(c.replace(min_re, '$1')));
      continue;
    }
  }
}
