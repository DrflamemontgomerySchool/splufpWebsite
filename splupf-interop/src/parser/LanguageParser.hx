package parser;


// Definitions of the data types that can be parsed

enum SplufpDataType {
  SNull;
  SBool(val:Bool);
  SString(val:String);
  SNumber(val:Float);
  SArray(val:Array<SplufpDataType>);
  SFunc(const:Bool, name:String, argumentList:Array<String>, body:String);
  SJSFunc(name:String, argumentList:Array<String>); // links to a javascript function
  SObject(val:Map<SplufpDataType, SplufpDataType>); // javascript { "1" : 2 } object
  SMacro(name:String, argumentList:Array<String>, body:String); // Unused
  SLambda(argumentList:Array<String>, body:String); // inline function \(x, y\) -> x + y
}

class LanguageParser {
  
  // creates a new object that parses the string
  public static inline function parse(str:String):Array<SplufpDataType> {
    return new LanguageParser(str).doParse();
  }


  var str:String;
  var pos:Int;

  function new(str:String) {
    this.str = str;
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
        // Parse a function that is not constant
        return parseFunc(false, nextString());
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

  inline function isValidName(name:String):Bool {
    /**
     * Matches a name that:
     *  - starts with a letter or '_'
     *  - contains letters, numbers, and '_'
     *  - is not a keyword
    **/
    return ~/^[a-zA-Z_][a-zA-Z0-9_]*$/.match(name) && !isKeyword(name);
  }

  function parseFunc(const: Bool, name:String) : Null<SplufpDataType> {
    if(!isValidName(name)) {
      throw 'function name is invalid \'${name}\'';
      return null;
    }

    var args : Array<String> = [];
    var identifier : String;

    while((identifier = nextString()) != "=") {
      if(identifier == '') { throw "expected '=' before newline"; }
      if(!isValidName(identifier)) {
        throw 'argument name is invalid \'${identifier}\'';
        return null;
      }

      args.push(identifier);
    }
    
    // TODO implement parsing of function body

    return SFunc(const, name, args, "");
  }

  inline function nextChar() {
    return StringTools.fastCodeAt(str, pos++);
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
          while( !StringTools.isEof((c = nextChar()) ) ) {
            switch(c) {
              case ' '.code, '\r'.code, '\n'.code, '\t'.code:
                // return on whitespace
                return ret_string;
              default:
                ret_string += String.fromCharCode(c);
            }
          }
          break;
      }
    }
    return "";
  }

  function invalidChar() {
    pos--;
    throw "Invalid char " + StringTools.fastCodeAt(str, pos) + " at position " + pos;
  }

}
