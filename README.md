# DON

Basic Object Notation, an alternative to JSON, YAML and TOML,
is a sophisticated language to express data. It supports expressions,
variables, types, schema validations and code completion.

# A simple example:

```don
name = "teja"
age = 30
places = [
  {
    city = "Stockholm"
    country = "Sweden"
  },
  {
    city = "Berlin"
    country = "Germany"
  }
]
```

# Short notation for List of Objects

Optionally Skip the curly braces `{}` for Objects inside lists to write concise and
readable data.

```don
[
  name = "dog"
  sound = "bow bow"
  ,
  name = "cat"
  sound = "meow meow"
]
```

Skip `,` after an object for `>` in front of the object to attain YAML like syntax.

```don
dog = {
  name = "dog"
  sound = "bow bow"
  limbs = [
  > left = true
    front = true
  > left = false
    front = true
  > left = true
    front = false
  > left = false
    front = false
  ]
}
```

# Use variables

DON is a sophisticated language. Use variables for reusable data.

```don
let $militia = {
  hp = 60
  speed = 0.9
}

militia = $militia

champion = $militia
```

# Types

```don
type Place = {
  city      String
  country   String
}

type Person = {
  name      String
  age       Int
  places    List<String>
}
```

# Features

## Prio1
+ [ ] Preserve parenthesis
+ [ ] Formatter
+ [ ] Concise encoder
## Prio2
+ [ ] Analyzer
+ [ ] VSCode Syntax highlighting
## Prio3
+ [ ] Types
+ [ ] Type/schema checking

