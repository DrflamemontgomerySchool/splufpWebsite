# My Language
## What is my language

My language is dynamically typed function programming language \
Everything is a function including variables \
This language does not support pure functions \
Currying is supported by default \

## Data Types
- Null
- Bool
- String
- Number (floats and integers are the same)

## Currying

```haskell
-- Profile of 'function_name'
-- function_name arg1 arg2 arg3 arg4


-- returns a function with profile of 'function arg3 arg4'
function_name 1 2
```

## Example of Project Transpile

Input:

```haskell
let a = 5

func a b c d =
  ret a + b + c + d
  
main =
  let b = func 1 2 3
  log (b 1)
```

Ouput: 

```javascript

var __spl__a = function() { return 5; }

var __spl__func = function(__spl__func__a) {
  return function(__spl__func__b) {
    return function(__spl__func__c) {
      return function(__spl__func__d) {
        return __spl__func__a + __spl__func__b + __spl__func__c + __spl__func__d;
      }
    }
  }
}

var __spl__main = function() {
  var __spl__b = __spl__func(1)(2)(3);
  console.log(__spl__b(1));
}

```
