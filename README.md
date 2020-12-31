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

# Programs

There are some main programs implemented to test the lexical and sintactical analyser:

## bin/syntactical_analyser
This is the main program that can detect:

- Prefix declarations
- Base IRI declarations
- Triples
- ~~Prefix remapping declarations~~ (not yet tested)
- Warns wrong Base IRIs endings.
- Warns wrong Prefix IRIs endings.

Some features:

- Show grammatical rules tested (accepted or not) with its recursive level.
- Each Anon (`[]`) subjects and objects are transformed into a new (non-repeated) blank node labelled `_:anonN` (where N is a number).

Synopsis: 
    
	bin/syntactical_analyser TTL_FILE [full|accepted]

The parameter `accepted` activate the debugger messages and shows all tested and accepted grammatical rules. The output shows how the methods were called, which represent the EBNF rules matched at the moment.

If `full` is used instead, the program shows all tested grammatical rules and the result: `--> False` if the rule was rejected and `--> True` otherwise.

## bin/lexical_automata
This program simulates the lexical automata and its transitions. The input are taken from the standard input, and for each symbol it displays the current state.

Consider that the automata accepted state are possible token types but not all acceptable states are mapped as tokens types.

The automata can be blocked. It means that the current string is not recognised after the current symbol and will not be recognised anymore (i.e. the transition function is defined as `(Blocked_State, C) -> Blocked_State` for all symbols C in the alphabet). The program won't restart automatically once it is blocked. Also, the end-of-file/source is considered as a blocked state.

Remember that the token is accepted once the automata enters in a block state and the previous step was in an acceptable state. For example, the token "[]" is a recognised token by the automata because, from the input `[] foaf:known []`, the automata will do the following steps:

1. Starting with "[" gets the acceptable state `Bracket_Open`.
2. The next input symbol "]" gets another acceptable state `Anon`.
3. The next input " " (white space) blocks the automata. But the automata accepted the previous step.

The syntactical analyser will try to process the next tokens from the input.

## bin/lexical_analyser
The lexical analyser will process a file and use the automata as explained before to recognise each token. It will restart the automata as needed and map the acceptable state to the token class type when printing.

The objective of this program is to display all the tokens recognised by the analyser from the input file. It shows the line number, the token class and its value.

`Not_Mapped` value means that the automata ended in an acceptable state, but it was not mapped to a valid token class name. This is a possible token that needs to be mapped in the future.

Some token names may not be what is expected. For example, `@prefix` matches the token type `Language_Tag`, but the syntactical analyser understands it as the "prefix" reserved word.

Any `Invalid` token will stop the lexical analyser because it is a lexical error in the input.

## bin/symbol_set
The finite automata used by the lexical analyser changes from state to state according to the input symbols. But, it is not useful to create a transition mapping from one state to the same for each digit, hexadecimal digit or letter. This will create several transition mappings making it difficult to debug. 

It would be easier to create sets of symbols and represent the transition function by a function partially defined as `(state x symbol-set) -> state`. 

This program ask the user for a symbol and then shows the symbol-sets that that symbol is member of it.

## bin/automata_transition_function
This program shows the transition function used by the lexical finite automata to recognise the tokens.

As explained before, the automata is defined with a non-complete function `(state x symbol-set) -> state`. Thus, a careful choice must be taken in order to select symbol sets: under the same state and the same symbol, there should be one symbol-set with that symbol defined for the current state.

For instance: the letter "A" can be a member of the `Hex_Digit` symbol-set and `Letter_Set`. Mapping a state "S" like this would be a mistake: 

```
(S, Hex_Digit) -> B
(S, Letter_Set) -> C
```

When the automata is at state "S", and receives the symbol "A", what state should choose? A somewhat determinism is preferable to not create a NP-complex analyser because of the non-determinism.

Consider that when a `(S, A)` is not defined at the function it means that it "blocks" the automata. That is to say, the automata enter a state called "blocked" that no matter the next input symbols it will stay in the same state (it is defined as `(Blocked, A) -> Blocked` for all symbol A).

# License
This work is under the General Public License version 3.
