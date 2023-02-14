package;

import parser.LanguageParser;

class Main {
 

  // helper function for converting the data into a string 
  static function splufpDataToString(data:SplufpDataType) : String {
    switch(data) {
      case SNull:
        return 'Null';

      case SBool(val):
        return 'Bool $val';

      case SString(val):
        return 'String \'$val\'';

      case SNumber(val):
        return 'Number $val';

      case SArray(arr):
        var s = '[ ';
        for(i in arr) {
          s += splufpDataToString(i) + ', ';
        }

        // \x08 is a backspace
        s += '\x08\x08 ]';
        return s;

      case SFunc(const, name, args, body):
        return (const ? 'const ' : '') + 'function ${name} ${args} { ${body} }';

      case SJSFunc(name, args):
        return 'jsfunction ${name} ${args}';

      case SObject(val):
        var s = '{ ';
        for(key in val.keys()) {
          s += '${splufpDataToString(key)} : ${splufpDataToString(val[key])}, ';
        }
        // \x08 is a backspace
        s += '\x08\x08 }';
        return s;

      case SMacro(_, _, _):
        return 'Macro unsupported';

      case SLambda(_, _):
        return 'Lambda unsupported';
    }
  }

  static function printSplufpData(data:SplufpDataType) {
    trace(splufpDataToString(data));
    return ''; // You need a return for Lambda.map
  }

  public static function main() {
    // print every element returned from the parsed text
    Lambda.map(LanguageParser.parse("let asd a = 2"), printSplufpData);
  }

}
