package;

import parser.LanguageParser;

class Main {

  static function splufpExprToString(expr:SplufpExpr) {
    switch(expr) {
      case SNull:
        return 'Null';

      case SBool(val):
        return 'Bool $val';

      case SString(val):
        return 'String \'$val\'';

      case SNumber(val):
        return 'Number $val';
      case SVariable(val):
        return 'Variable $val';
      case SVariableAssign(val, assignment):
        return 'Variable $val = ${splufpExprToString(assignment)}';
      case SLambda(args, body):
        var func_str = 'Lambda ${args} {\n';
        for(i in body) {
          func_str += '  ' + splufpExprToString(i) + '\n';
        }

        return func_str + '}';
        return 'Lambda $args $body';
      case SArray(arr):
        var s = '[ ';
        for(i in arr) {
          s += splufpExprToString(i) + ', ';
        }

        // \x08 is a backspace
        // if we have an array of length 0 we don't want to erase it 
        s += (arr.length > 0 ? '\x08\x08' : '\x08') + ' ]';
        return s;
      case SObject(val):
        var s = '{ ';
          for(key in val.keys()) {
            s += '${key} : ${splufpExprToString(val[key])}, ';
          }
          // \x08 is a backspace
          s += '\x08\x08 }';
        return s;
      case SBracketExpr(expr):
        var bracket_str = '( ';
        for(e in expr) {
          bracket_str += '${splufpExprToString(e)} ';
        }
        bracket_str += ')';
        return bracket_str;
    }
    return ''; 
  }

  // helper function for converting the data into a string 
  static function splufpDataToString(data:SplufpDataType) : String {
    switch(data) {
      case SVariable(const, name, expr):
        return (const ? 'let' : 'set') + ' ${name} ${splufpExprToString(expr)}';

      case SFunc(const, name, args, body):
        var func_str = (const ? 'const ' : '') + 'function ${name} ${args} {\n';
        for(i in body) {
          func_str += '  ' + splufpExprToString(i) + '\n';
        }

        return func_str + '}';

      case SJSFunc(name, args):
        return 'jsfunction ${name} ${args}';

      case SMacro(_, _, _):
        return 'Macro unsupported';

    }
  }

  static function printSplufpData(data:SplufpDataType) {
#if js
    js.Browser.console.log(splufpDataToString(data));
#else
    Std.printLn(splufpDataToString(data));
#end

    return ''; // You need a return for Lambda.map
  }

  public static function main() {
    // print every element returned from the parsed text
    final test_parsing = "
let a = [ // Single Line Comment Test
/**
 *
 * Multiline comment test
 *
 *
**/
  null,
  true,
  false,
  'string\n\n\\\'string\\\'',
  123,
  -123,
  1.3,
  -1.2,
  [ 1, 2, 3]
]\n
set b = [
  [ 
    [
      1, '2', \"3\", null
    ],

    [
      true, false, arg
    ],

    []

  ]
]

test_func a b {
  123
  321
  null
  3
  a = b
  \\(a, b\\) -> {
    \\(b,  a\\) -> {
      a
    }
  }
}
func { null }
func { 123 }
  ";
#if js
    js.Browser.console.log('Parsing String:\n${test_parsing}');
    js.Browser.console.log('Output:\n');
#else
    Std.printLn('Parsing String:\n${test_parsing}');
    Std.printLn('Output:\n');
#end
    Lambda.map(LanguageParser.parse(test_parsing + '\n'), printSplufpData);
  }

}
