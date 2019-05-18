# BON

Basic Object Notation, an alternative to JSON, YAML and TOML,
is a sophisticated language to express data that supports expressions,
variables, types, schema validations and content assist.

# A simple example:

```
.name:  "teja"
.age:  30
.places:  [
    {
      .city:  "Stockholm"
      .country:  "Sweden"
    }, {
      .city:  "Berlin"
      .country:  "Germany"
    },
  ]
}
```

# Short notation for List of Objects

Optionally Skip the curly braces `{}` for Objects inside lists to write concise and
readable data.

```
.dog {
  .name:  dog
  .sound:  bow bow
  .limbs: [
    .left:  true
    .front:  true
    ,
    .left:  false
    .front:  true
    ,
    .left:  true
    .front:  false
    ,
    .left:  false
    .front:  false
  ]
}
```

Skip `,` after an object for `>` in front of the object to attain YAML like syntax.

```
.dog {
  .name:  dog
  .sound:  bow bow
  .limbs: [
  > .left:  true
    .front:  true
  > .left:  false
    .front:  true
  > .left:  true
    .front:  false
  > .left:  false
    .front:  false
  ]
}
```

# Declare variables

```
let $militia = {
  .hp: 60
  .speed: 0.9
}
```

# Types

```
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

+ [ ] Formatter
+ [ ] Set operation
