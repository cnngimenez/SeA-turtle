--  syntactical-rules.ads ---

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
with League.Strings;
use League.Strings;

with Lexical.Token;
use Lexical.Token;
with Lexical.Turtle_Lexer;
use Lexical.Turtle_Lexer;
with Elements.Triples;
use Elements.Triples;
with Elements.Prefixes;
use Elements.Prefixes;

generic
    Debug_Mode : Boolean := False;
    --  This subprogram will be called every time a triple is parsed.
    with procedure Triple_Readed_Callback (Triple : Triple_Type);
    --
    --  This subprogram will be called every time a @prefix directive is
    --  parsed.
    --
    with procedure Prefix_Directive_Callback (Prefix : Prefix_Type);
    --  This subprogram will be called every time a @base directive is parsed.
    with procedure Base_Directive_Callback (Base_IRI : Universal_String);
package Syntactical.Rules is
    --  This is the main entry point for the syntactical analyser.
    function Turtle_Doc (Lexer : in out Lexer_Type) return Boolean;

    function Statement (Lexer : in out Lexer_Type) return Boolean;
    function Directive (Lexer : in out Lexer_Type) return Boolean;
    function Prefix_ID (Lexer : in out Lexer_Type) return Boolean;
    function Base (Lexer : in out Lexer_Type) return Boolean;
    function Sparql_Base (Lexer : in out Lexer_Type) return Boolean;
    function Sparql_Prefix (Lexer : in out Lexer_Type) return Boolean;
    function Triples (Lexer : in out Lexer_Type) return Boolean;
    function Predicate_Object_List (Lexer : in out Lexer_Type) return Boolean;
    function Object_List (Lexer : in out Lexer_Type) return Boolean;
    function Verb (Lexer : in out Lexer_Type) return Boolean;
    function Subject (Lexer : in out Lexer_Type) return Boolean;
    function Predicate (Lexer : in out Lexer_Type) return Boolean;
    function Object (Lexer : in out Lexer_Type) return Boolean;
    function Literal (Lexer : in out Lexer_Type) return Boolean;
    function Blank_Node_Property_List (Lexer : in out Lexer_Type)
                                      return Boolean;
    function Collection (Lexer : in out Lexer_Type) return Boolean;
    function Numeric_Literal (Lexer : in out Lexer_Type) return Boolean;
    function RDF_Literal (Lexer : in out Lexer_Type) return Boolean;
    function Boolean_Literal (Lexer : in out Lexer_Type) return Boolean;
    function String (Lexer : in out Lexer_Type) return Boolean;
    function IRI (Lexer : in out Lexer_Type) return Boolean;
    function Prefixed_Name (Lexer : in out Lexer_Type) return Boolean;
    function Blank_Node (Lexer : in out Lexer_Type) return Boolean;

    Expected_Token_Exception : exception;

private

    --
    --  Test if the next token is the given one. If it is, consume it.
    --  If it is not the one, do nothing.
    --
    function Accept_Token (Lexer : in out Lexer_Type;
                           Token_Class : Token_Class_Type;
                           Value : Wide_Wide_String)
                          return Boolean;
    --
    --  Test if the next token is the given one. If it is, consume it.
    --  If it is not the one, do nothing.
    --
    function Accept_Token (Lexer : in out Lexer_Type;
                          Token_Class : Token_Class_Type)
                         return Boolean;

    function Expect_Token (Lexer : in out Lexer_Type;
                           Token_Class : Token_Class_Type;
                           Token : in out Token_Type)
                          return Boolean;

    --  The next token must be the given one, if not raise an exception.
    function Expect_Token (Lexer : in out Lexer_Type;
                           Token_Class : Token_Class_Type)
                          return Boolean;

        --  The next token must be the given one, if not raise an exception.
    function Expect_Token (Lexer : in out Lexer_Type;
                           Token_Class : Token_Class_Type;
                           Value : Wide_Wide_String)
                          return Boolean;

    procedure Put_Token (Token : Token_Type);
    procedure Put_Rule (Rule_Name : Wide_Wide_String);
end Syntactical.Rules;
