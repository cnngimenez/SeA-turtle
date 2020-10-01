# RDF/Turtle parser
Parse an RDF/Turtle file to obtain the RDF tripples.

The lexical and syntactical analyser are implemented according to the rules at the [W3C RDF 1.1 Turtle grammar specification](https://www.w3.org/TR/2014/REC-turtle-20140225/#sec-grammar). See the "design" folder for more information on the implementation.

![GPL Licensed](https://img.shields.io/badge/License-GPLv3-informational?logo=gnu) ![Ada Version](https://img.shields.io/badge/Ada-2012-informational)

## Source
The `Source` package and the `Source.Source_Type` type represent a data source. It could be a stream file, a random access file, a wide wide string, etc. 

Some operations must be present in order to use a data source as a parser input. Thus, a subpackage can be created to use other type of data source. Up to now, these are the data source type supported:

- `Source` package implements a `Wide_Wide_String` source type.

## Lexical analyser
The lexical analyser is a finite deterministic automata and it is implemented at the `Lexical` package. Its design was created according to the grammar specified on the uppercased terminals at the RDF 1.1 Turtle grammar. See the [design/design.org](https://github.com/cnngimenez/turtle/blob/master/design/design.org) file for a complete explanation of the conventions used, the automata specification and the relation of the automata with the Ada code.

Packages implemented in Ada:
- `Lexical` The lexical parser
- `Lexical.Finite_Automata` The finite automata implementation.
- `Lexical.Token` It associates the final states with the token object (name and value).
- `Lexical.Turtle_Lexer` Use this subpackage to call the lexical analyser itself.

The following code use a string as an input source, it reads the data source tokens one by one and prints them using the `Print_Token` procedure.

```ada
    Source.Initialize ("WIDE WIDE STRING DATA HERE");

    Lexer.Create (Source);

    loop
        Token := Lexer.Take_Token;

        Print_Token (Token);
        exit when Token = Invalid_Token;
    end loop;
```

A complete usage example can be found at the `src/lexical_analizer.adb` main program.

# Syntactical analyser
The syntactical analyser is a [recursive descent parser](https://en.wikipedia.org/wiki/Recursive_descent_parser) implemented in the `syntactical` package.

# Compiling
The requirements are

- The Ada GNAT compiler. 
- The GPRBuild tools.
- The [Matreshka library](https://forge.ada-ru.org/matreshka).
- The [SeA library](https://github.com/cnngimenez/SeA).

The usual sequence may work for your environment:

```
make
make install
```

The Makefile can be configure at the makefile.setup file. This file can be generated with the following command:

```
make setup
```


## Compiling with GPRBuild

Use the following commands to compile:

```
gprbuild -Pturtle.gpr -p
```

To install the library and binaries:

```
gprinstall -Pturtle.gpr -p
```

A install directory can be specified by the `--prefix` parameter:

```
gprinstall -Pturtle.gpr --prefix=/home/USERNAME/Ada -p
```

# Usage
The API specification are available as `*.ads` files. 

Main programs were created for debuging purposes. They are `src/*.adb` source files and they are specified inside the `turtle.gpr` file at the `Main` variable.
These programs are used to test and debug each part of the parser separately. They can be used as examples to call the parser or one of its parts.

This program is not a KG/quad/tripple-store. The objective is to read a turtle file in order to get the Subject-Predicate-Object tripples stored there. No reasoning support are provided either.

# License
This work is under the General Public License version 3.
