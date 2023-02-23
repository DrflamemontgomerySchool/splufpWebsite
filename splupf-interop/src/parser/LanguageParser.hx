package parser;


// Definitions of the data types that can be parsed

enum SplufpExpr {
  SNull;
  SBool(val:Bool);
  SString(val:String);
  SNumber(val:Float);
  SArray(val:Array<SplufpExpr>);
  SObject(val:Map<String, SplufpExpr>);
  SVariable(val:String); // reference to variable name
  SVariableAssign(val:String, assignment:SplufpExpr); // reference to variable name
  SLambda(argumentList:Array<String>, body:Array<SplufpExpr>); // inline function \(x, y\) -> x + y
  SBracketExpr(expr:Array<SplufpExpr>);
}

enum SplufpDataType {
  SVariable(const:Bool, name:String, expr:SplufpExpr);
  SFunc(const:Bool, name:String, argumentList:Array<String>, body:Array<SplufpExpr>);
  SJSFunc(name:String, argumentList:Array<String>); // links to a javascript function
  SMacro(name:String, argumentList:Array<String>, body:String); // Unused
}

class LanguageParser {
  
  // creates a new object that parses the string
  public static inline function parse(str:String):Array<SplufpDataType> {
    return new LanguageParser(str).doParse();
  }


  var str:String;
  var pos:Int;

  function new(str:String) {
    this.str = stripComments(str); // strip all the comments out so that we don't parse them
    this.pos = 0;
  }

  function doParse():Array<SplufpDataType> {
    var programData : Array<SplufpDataType> = []; // The tree of the language
    while( true ) {
      var d : Null<SplufpDataType> = parseRec();
      if(d == null) { break; }
      
      programData.push(d);
    }
    return programData;
  }



  
  // parses base level elements
  function parseRec() : Null<SplufpDataType> {
    var identifier:String = nextString(true);
    
    switch(identifier) {
      case "":
      // do nothing if it is an empty string
      case "let":
        // Parse a function that is constant
        return parseVariable(true, nextString());
      case "set":
        // Parse a variable that is not constant
        return parseVariable(false, nextString());
      default:
        // Parse a function that is constant
        return parseFunc(true, identifier);

    }

    return null;
  }

  inline function isKeyword(str : String) {
    /**
     * Matches keywords:
     *  - macro
     *  - externjs
     *  - let
    **/
    return ~/(^macro|^externjs|^let)$/.match(str);
  }
  
  inline function isVariable(name:String):Bool {
    /**
     * Matches a name that:
     *  - starts with a letter or '_'
     *  - contains letters, numbers, and '_'
    **/
    return ~/^[a-zA-Z_][a-zA-Z0-9_]*$/.match(name);
  }

  inline function isValidName(name:String):Bool {
    /**
     * Matches a name that:
     *  - starts with a letter or '_'
     *  - contains letters, numbers, and '_'
     *  - is not a keyword
    **/
    return isVariable(name)  && !isKeyword(name);
  }

  function parseVariable(const: Bool, name:String) : Null<SplufpDataType> {
    if(!isValidName(name)) {
      throw 'variable name is invalid \'${name}\'';
      return null;
    }
    //var s = nextString();
    if(nextString() != "=") {
      throw 'expected \'=\' before newline';
      return null;
    }
  
    var expr = parseExpr();
    if(expr == null) {
      throw 'Variable requires assignment';
      return null;
    }
    
    if(nextString() != '') {
      throw 'expected newline after variable assignment';
      return null;
    }

    return SVariable(const, name, expr);
  }

  function parseFunc(const: Bool, name:String) : Null<SplufpDataType> {
    if(!isValidName(name)) {
      throw 'function name is invalid \'${name}\'';
      return null;
    }

    var args : Array<String> = [];
    var identifier : String;

    while( !~/^\{/.match((identifier = nextString())) ) {
      if(identifier == '') { throw "expected '{' before newline"; }
      if(!isValidName(identifier)) {
        throw 'argument name is invalid \'${identifier}\'';
        return null;
      }

      args.push(identifier);
    }

    
    // TODO implement parsing of function body
    pos -= identifier.length + 1;
    var body = parseFuncBody();
    if(body == null) {
      throw 'expected a body for the function';
      return null;
    }
    
    if(nextString() != '') {
      throw 'expected newline after \'}\'';
      return null;
    }

    return SFunc(const, name, args, body);
  }


  function parseExpr(deliminators : Null<Array<String>> = null, variable_assignment : Bool = false) : Null<SplufpExpr> {

    var identifier : String = nextString((deliminators == null) ? false : !deliminators.contains(''));
    switch(identifier) {
      case b if(~/^\(/.match(b)):

        pos -= b.length;
        return parseExpr([')'], false);
      case n if(~/^null[^a-zA-Z0-9_]*/.match(n)):
        // if full variable name is 'null' retun null

        // return to position to read the rest of the token
        pos -= ~/null/.replace(n, "").length + 1;
        return SNull;

      case t if(~/^true[^a-zA-Z0-9_]*/.match(t)):
        // if full variable name is 'true' retun null

        // return to position to read the rest of the token
        pos -= ~/true/.replace(t, "").length + 1;
        return SBool(true);
      case f if(~/^false[^a-zA-Z0-9_]*/.match(f)):
        // if full variable name is 'false' retun null

        // return to position to read the rest of the token
        pos -= ~/false/.replace(f, "").length + 1;
        return SBool(false);
      case num if(~/^-?[0-9]+\.*[0-9]*/.match(num)):
        // if we match a number with optional '-' sign we parse it

        // return to position to read the rest of the token
        pos -= ~/^-?[0-9]+\.*[0-9]*/.replace(num, "").length + 1;
        return SNumber(Std.parseFloat(num));
      case str if(~/^['"]/.match(str)):
        // if we have either an ' or " parse it

        // return to the start of the string
        pos -= str.length;
        return parseString(str.charCodeAt(0));
      case arr if(~/^\[/.match(arr)):
        // if we match a '[' parse an array

        // return to position to read the rest of the token
        pos -= arr.length;
        return parseArray();
      case v if(isVariable(v)):
        // if it is a valid variable name then parse it
        return parseExprVariable(v, variable_assignment);
      case l if( ~/^\\\(/.match(l) ):
        pos -= l.length - 1;
        return parseLambda();
      default:
        throw "expr type is not supported yet";
        return null;
    }
    return null;
  }

  function parseLambda() : Null<SplufpExpr> {
    var args = [];

    switch(nextString(true)) {
      case '\\)':
      case str:
        // otherwise return to previous position
        pos -= str.length + 1;
        var last_string : String;
        
        final variable_name = ~/^([a-zA-Z_][a-zA-Z0-9_]*)(.*)/;


        do {

          var arg_name = nextString();
          if(!variable_name.match(arg_name)) {
            throw 'invalid argument name';
            return null;
          }
          args.push(variable_name.matched(1));
          pos -= variable_name.matched(2).length + 1;


          // Test whether our token contains ',' or ']'
          last_string = nextString(true);
          if(~/(,|\\\))/.match(last_string)) {
            pos -= last_string.length + 1;
            // Get the position of the first ',' or ']'
            do {
              switch(nextChar()) {
                case ','.code:
                  pos--;
                  break;
                case '\\'.code:
                  if(nextChar() == ')'.code)  {
                    pos -= 2;
                    break;
                  }
              }
            } while(true);
          }

          last_string = nextString(true);

          // return to the correct position for eating more tokens
          if(last_string.charAt(0) == ',') {
            pos -= last_string.length;
          }
        } while(last_string.charAt(0) == ',');

    }

    switch(nextString(true)) {
      case str if(~/^->/.match(str)):
        pos -= str.length - 1;
      default:
        throw 'error expected \'->\' after lambda arguments';
        return null;
    }

    var body = parseFuncBody();
    if(body == null) {
      throw 'expected function body after \'->\'';
    }

    return SLambda(args, body);
  }

  function parseExprVariable(name : String, assignable : Bool) : Null<SplufpExpr> {
    pos--;
    var str = nextString();
    switch(str) {
      case '':
        return SVariable(name);
      case '=' if(assignable):
        var expr = parseExpr();
        if(expr == null) {
          throw 'expected expression after \'=\'';
          return null;
        }
        pos--;
        if(nextString() != '') {
          throw 'expected newline after expression';
          return null;
        }
        pos--;
        
        return SVariableAssign(name, expr);
      case _:
        var expr
      case _ if(assignable):
        throw 'expected \'=\'';
        return null;
    }

    return null;

  }
  
  inline function parseEscape() : Int {
    var c = nextChar();
    switch(c) {
      case 'a'.code:
        return 0x07;
      case 'b'.code:
        return 0x08;
      case 'e'.code:
        return 0x1b;
      case 'f'.code:
        return 0x0c; 
      case 'n'.code:
        return '\n'.code;
      case 'r'.code:
        return '\r'.code;
      case 't'.code:
        return '\t'.code;
      case 'v'.code:
        return 0x0b;
      case 'x'.code:
        return Std.parseInt('0x${nextChar()}${nextChar()}');
      default:
        return c;
    }
  }

  function parseFuncBody() : Null<Array<SplufpExpr>> {
    var body : Array<SplufpExpr> = [];    
    var last_string = "";
  
    switch(nextString()) {
      case str if(~/^\{/.match(str)):
        pos -= str.length;
      default:
        throw "Expected '{' for function body";
        return null;
    }
    
    do {
       
      var expr : Null<SplufpExpr> = parseExpr([], true);
      if(expr == null) {
        throw 'expected an expression';
        return null;
      }
      body.push(expr);

      last_string = nextString(true);
      if(~/^.\+\}/.match(last_string)) {
        pos -= last_string.length + 1;
        ~/\}/.replace(str, '\n}');
      }
      else if( !~/^\}/.match(last_string)) {
        pos -= last_string.length + 1;
      } 


    } while(last_string != '}');
    

    if(last_string.charAt(0) != '}') {
      throw 'expected \'}\' to terminate function body';
      return null;
    }
      

    pos -= last_string.length;
    return body;
  }
  
  

  function parseArray(): Null<SplufpExpr> {

    var arr = [];
    var last_string = "";

    switch(nextString(true)) {
      case ']':
        // return an empty array if it contains no elements
        return SArray([]);
      case str:
        // otherwise return to previous position
        pos -= str.length + 1;
    }

    do {

      var expr = parseExpr([]);
      if(expr == null) {
        throw 'expected an expression';
        return null;
      }
      arr.push(expr);
    

      // Test whether our token contains ',' or ']'
      last_string = nextString(true);
      if(~/[,\]]/.match(last_string)) {
        pos -= last_string.length + 1;
        // Get the position of the first ',' or ']'
        do {
        } while( !~/[,\]]/.match(String.fromCharCode(nextChar())) );
        pos--;
      }

      last_string = nextString(true);

      // return to the correct position for eating more tokens
      if(last_string.charAt(0) == ',') {
        pos -= last_string.length;
      }
    } while(last_string.charAt(0) == ',');
    

    if(last_string.charAt(0) != ']') {
      throw 'expected \']\' to terminate array';
      return null;
    }
      

    pos -= last_string.length;
    return SArray(arr);
  }

  function parseString(stringId : Int) : Null<SplufpExpr> {
    var string = "";
    var c;
    while((c = nextChar()) >= 0) {
     switch(c) {
        case '\\'.code:
          string += String.fromCharCode(parseEscape()); 
        case _ if(c == stringId):
          return SString(string);
        default:
          string += String.fromCharCode(c);
     }
    }
    return null;
  }

  inline function nextChar() {
    return StringTools.fastCodeAt(str, pos++);
  }

  inline function stripMultiLineComment(str:String):String {
    /*
       replace all comments in this style
    */
    return ~/\/\*.*\*\//s.replace(str, "");
  }
  
  inline function stripSingleLineComment(str:String):String {
    // replace all comments in this style
    return ~/\/\/.*/g.replace(str, "");
  }

  function stripComments(str:String):String {
    // strip all types of comments
    return stripMultiLineComment(stripSingleLineComment(str));    
  }

  function nextString(newline:Bool = false):String {
    var ret_string = "";
    var c ;
    while( !StringTools.isEof((c = nextChar())) ) {
      switch(c) {
        case '\n'.code if(!newline):
          // return nothing if we break on newlines
          return '';
        case '\n'.code if(newline):
          // loop
        case ' '.code, '\r'.code, '\t'.code:
          // loop
        default:
          ret_string += String.fromCharCode(c);
          do {
            c = nextChar();
            switch(c) {
              case ' '.code, '\r'.code, '\n'.code, '\t'.code:
                // return on whitespace
                return ret_string;
              default:
                ret_string += String.fromCharCode(c);
            }
          } while( !StringTools.isEof(c));
          return ret_string;
      }
    }
    return "";
  }

  function invalidChar() {
    pos--;
    throw "Invalid char " + StringTools.fastCodeAt(str, pos) + " at position " + pos;
  }

}
