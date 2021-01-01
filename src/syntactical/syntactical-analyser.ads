--  syntactical-analyser.ads ---

--  Copyright 2020 cnngimenez
--
--  Author: cnngimenez

--  This program is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.

--  You should have received a copy of the GNU General Public License
--  along with this program.  If not, see <http://www.gnu.org/licenses/>.

-------------------------------------------------------------------------

with Ada.Containers.Vectors;

with League.Strings;
use League.Strings;

with SeA.RDF.Triples;
use SeA.RDF.Triples;

with Lexical.Token;
use Lexical.Token;
with Lexical.Turtle_Lexer;
use Lexical.Turtle_Lexer;
with Turtle.Parser_States;
use Turtle.Parser_States;

--  Creates and manages the syntax analyser objects.
--
--  Each analyser object consists of a lexical analyser and a parser state
--  according to the RDF 1.1 Turtle standard. It also has got any state that
--  should be recorded through the transition of the syntax rules.
package Syntactical.Analyser is

    type Debug_Mode_Type is (Off, Only_Accepted_Tokens, Full_Debug);

    type Syntax_Analyser_Type is tagged private;

    function Get_Lexer (Syntax_Analyser : Syntax_Analyser_Type)
                       return Lexer_Type;
    function Get_Parser_State (Syntax_Analyser : Syntax_Analyser_Type)
                              return Parser_State_Type;
    function Get_Debug_Mode (Syntax_Analyser : Syntax_Analyser_Type)
                            return Debug_Mode_Type;
    function Get_Recursion_Level (Syntax_Analyser : Syntax_Analyser_Type)
                                 return Natural;
    procedure Set_Lexer (Syntax_Analyser : in out Syntax_Analyser_Type;
                         Lexer : Lexer_Type);
    procedure Set_Parser_State (Syntax_Analyser : in out Syntax_Analyser_Type;
                                Parser_State : Parser_State_Type);
    procedure Set_Debug_Mode (Syntax_Analyser : in out Syntax_Analyser_Type;
                              Debug_Mode : Debug_Mode_Type);

    function Get_New_Anon_Value (Syntax_Analyser : in out Syntax_Analyser_Type)
                                return Universal_String;

    --  --------------------
    --  Debugging
    --  --------------------

    procedure Add_Recursion_Level
      (Syntax_Analyser : in out Syntax_Analyser_Type);
    procedure Remove_Recursion_Level
      (Syntax_Analyser : in out Syntax_Analyser_Type);

    --  --------------------
    --  Lexer management
    --  --------------------

    function Peek_Token (Syntax_Analyser : in out Syntax_Analyser_Type)
                        return Token_Type;
    function Take_Token (Syntax_Analyser : in out Syntax_Analyser_Type)
                        return Token_Type;
    function Is_End_Of_Source (Syntax_Analyser : in out Syntax_Analyser_Type)
                              return Boolean;
    function Get_Line_Number (Syntax_Analyser : in out Syntax_Analyser_Type)
                             return Natural;
    function Get_Column_Number (Syntax_Analyser : in out Syntax_Analyser_Type)
                               return Natural;
    --  --------------------
    --  Parser State management
    --  --------------------

    procedure Assign_Namespace (Analyser : in out Syntax_Analyser_Type;
                                Prefix : Universal_String;
                                Iri : Universal_String);

    function Get_Base_URI (Analyser  : in out Syntax_Analyser_Type)
                          return Universal_String;

    procedure Assign_Base_URI (Analyser : in out Syntax_Analyser_Type;
                               URI : Universal_String);

    --  Assign the current subject to the state. New emitted triples are going
    --  to have this subject.
    --
    --  Value can be an IRI or the blank node value.
    procedure Assign_Cur_Subject (Analyser : in out Syntax_Analyser_Type;
                                  Value : Universal_String;
                                  Subject_Type : Subject_Type_Type := IRI);

    --  Assign the Cur_Predicate to the given IRI. Considers the "a" string as
    --  the rdf:type IRI.
    procedure Assign_Cur_Predicate (Analyser : in out Syntax_Analyser_Type;
                                    IRI : Universal_String);

    --  Construct an RDF_Triple with the Cur_Subject, Cur_Predicate and the
    --  given Object_IRI.
    function Emit_RDF_Triple (Analyser : in out Syntax_Analyser_Type;
                              Object_Value : Universal_String;
                              Object_Type : Object_Type_Type := IRI)
                             return Triple_Type;

    function Substitute_Prefix (Analyser : in out Syntax_Analyser_Type;
                                Pname_Ns : Universal_String)
                               return Universal_String;

    function Is_Base_IRI_Ending_Correctly
      (Analyser : in out Syntax_Analyser_Type)
      return Boolean;

    function Is_Base_IRI_Relative
      (Analyser : in out Syntax_Analyser_Type)
      return Boolean;
    function Is_Base_IRI_Valid
      (Analyser : in out Syntax_Analyser_Type)
      return Boolean;

    --  Subject and predicate saving.
    --  The following proceduresa are used to save and restore the current
    --  subject and predicate when using blank node property lists.
    procedure Restore_Cursubject (Analyser : in out Syntax_Analyser_Type);
    procedure Restore_Curpredicate (Analyser : in out Syntax_Analyser_Type);
    procedure Save_Cursubject (Analyser : in out Syntax_Analyser_Type);
    procedure Save_Curpredicate (Analyser : in out Syntax_Analyser_Type);

private

    type Subject_Element_Type is tagged record
        Subject_Value : Universal_String;
        Subject_Type : Subject_Type_Type;
    end record;

    package Subject_Heap_Package is new Ada.Containers.Vectors
      (Index_Type => Natural,
       Element_type => Subject_Element_Type);
    package Predicate_Heap_Package is new Ada.Containers.Vectors
      (Index_Type => Natural,
       Element_Type => Universal_String);

    type Syntax_Analyser_Type is tagged record
        Lexer : Lexer_Type;
        Parser_State : Parser_State_Type;

        --  Subject and predicate savings.
        --  In order to restore subject and predicate when using blank node
        --  property lists, we need a "heap" to save them.
        Subject_Heap : Subject_Heap_Package.Vector;
        Predicate_Heap : Predicate_Heap_Package.Vector;

        --  Debugging features:

        --  Should the rules be printed at standard output?
        Debug_Mode : Debug_Mode_Type := Off;
        --  It is used to show the syntax tree on the standard output.
        Recursion_Level : Natural := 0;
    end record;

end Syntactical.Analyser;
