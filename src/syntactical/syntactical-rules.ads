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

with Syntactical.Analyser;
use Syntactical.Analyser;

with Lexical.Token;
use Lexical.Token;
with SeA.RDF.Triples;
use SeA.RDF.Triples;
with SeA.Namespaces.Prefixes;
use SeA.Namespaces.Prefixes;

generic

    --  This subprogram will be called every time a triple is parsed.
    with procedure Triple_Readed_Callback (Triple : Triple_Type);

    --  This subprogram will be called every time a @prefix directive is
    --  parsed.
    with procedure Prefix_Directive_Callback (Prefix : Prefix_Type);

    --  This subprogram will be called every time a @base directive is parsed.
    with procedure Base_Directive_Callback (Base_IRI : Universal_String);

    --  This subprogram will be called for any warning message.
    with procedure Warning_Callback (Message : Universal_String);

package Syntactical.Rules is

    --  This is the main entry point for the syntactical analyser.
    function Turtle_Doc (Analyser : in out Syntax_Analyser_Type)
                        return Boolean;

    function Statement (Analyser : in out Syntax_Analyser_Type)
                       return Boolean;
    function Directive (Analyser : in out Syntax_Analyser_Type)
                       return Boolean;
    function Prefix_ID (Analyser : in out Syntax_Analyser_Type)
                       return Boolean;
    function Base (Analyser : in out Syntax_Analyser_Type)
                  return Boolean;
    function Sparql_Base (Analyser : in out Syntax_Analyser_Type)
                         return Boolean;
    function Sparql_Prefix (Analyser : in out Syntax_Analyser_Type)
                           return Boolean;
    function Triples (Analyser : in out Syntax_Analyser_Type)
                     return Boolean;
    function Predicate_Object_List (Analyser : in out Syntax_Analyser_Type)
                                   return Boolean;
    function Object_List (Analyser : in out Syntax_Analyser_Type)
                         return Boolean;
    function Verb (Analyser : in out Syntax_Analyser_Type)
                  return Boolean;
    function Subject (Analyser : in out Syntax_Analyser_Type)
                     return Boolean;
    function Predicate (Analyser : in out Syntax_Analyser_Type;
                       IRI_Str : in out Universal_String)
                       return Boolean;
    function Object (Analyser : in out Syntax_Analyser_Type)
                    return Boolean;
    function Literal (Analyser : in out Syntax_Analyser_Type)
                     return Boolean;
    function Blank_Node_Property_List (Analyser : in out Syntax_Analyser_Type;
                                       Emit_First_Triple : Boolean := False)
                                      return Boolean;
    function Collection (Analyser : in out Syntax_Analyser_Type)
                        return Boolean;
    function Numeric_Literal (Analyser : in out Syntax_Analyser_Type)
                             return Boolean;
    function RDF_Literal (Analyser : in out Syntax_Analyser_Type)
                         return Boolean;
    function Boolean_Literal (Analyser : in out Syntax_Analyser_Type)
                             return Boolean;
    --  This is the String rule, but clashes with Ada's String type.
    function String_Rule (Analyser : in out Syntax_Analyser_Type)
                    return Boolean;
    function IRI (Analyser : in out Syntax_Analyser_Type;
                  IRI_Str : in out Universal_String)
                 return Boolean;
    function IRI (Analyser : in out Syntax_Analyser_Type)
                 return Boolean;
    function Prefixed_Name (Analyser : in out Syntax_Analyser_Type;
                            IRI_Str : in out Universal_String)
                           return Boolean;
    function Blank_Node (Analyser : in out Syntax_Analyser_Type;
                         Value : out Universal_String)
                        return Boolean;

    Expected_Token_Exception : exception;

private

    --
    --  Test if the next token is the given one. If it is, consume it.
    --  If it is not the one, do nothing.
    --
    function Accept_Token (Analyser : in out Syntax_Analyser_Type;
                           Token_Class : Token_Class_Type;
                           Value : Wide_Wide_String)
                          return Boolean;

    function Accept_Token (Analyser : in out Syntax_Analyser_Type;
                           Token_Class : Token_Class_Type;
                           Token : in out Token_Type)
                          return Boolean;
    --
    --  Test if the next token is the given one. If it is, consume it.
    --  If it is not the one, do nothing.
    --
    function Accept_Token (Analyser : in out Syntax_Analyser_Type;
                           Token_Class : Token_Class_Type)
                          return Boolean;

    function Expect_Token (Analyser : in out Syntax_Analyser_Type;
                           Token_Class : Token_Class_Type;
                           Token : in out Token_Type)
                          return Boolean;

    --  The next token must be the given one, if not raise an exception.
    function Expect_Token (Analyser : in out Syntax_Analyser_Type;
                           Token_Class : Token_Class_Type)
                          return Boolean;

        --  The next token must be the given one, if not raise an exception.
    function Expect_Token (Analyser : in out Syntax_Analyser_Type;
                           Token_Class : Token_Class_Type;
                           Value : Wide_Wide_String)
                          return Boolean;

    procedure Debug_Token (Analyser : in out Syntax_Analyser_Type;
                           Token : Token_Type);
    procedure Debug_Put (Analyser : in out Syntax_Analyser_Type;
                         S : Wide_Wide_String);
    procedure Begin_Rule (Analyser : in out Syntax_Analyser_Type;
                          Rule_Name : Wide_Wide_String);
    procedure End_Rule (Analyser : in out Syntax_Analyser_Type);

    --  Remove the "<" and ">" characters from a Turtle IRI.
    function Extract_IRI (Readed_IRI : Universal_String)
                         return Universal_String;

    --  Check if the prefix is correctly written. Raise exceptions or
    --  warnings accordingly.
    procedure Verify_Namespace_Prefix (Analyser : in out Syntax_Analyser_Type;
                                       Prefix : Prefix_Type);

    --  Check if the Base IRI is correctly written. Raise exceptions or
    --  warnings if needed.
    procedure Verify_Base_IRI (Analyser : in out Syntax_Analyser_Type);

    function Current_Position (Analyser : in out Syntax_Analyser_Type)
                              return String;
    function Current_Position (Analyser : in out Syntax_Analyser_Type)
                              return Wide_Wide_String;
    function Current_Position_Us (Analyser : in out Syntax_Analyser_Type)
                                 return Universal_String;
end Syntactical.Rules;
