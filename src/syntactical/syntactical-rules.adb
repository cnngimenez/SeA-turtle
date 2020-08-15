--  syntactical-rules.adb ---

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

with Ada.Wide_Wide_Text_IO;
use Ada.Wide_Wide_Text_IO;

package body Syntactical.Rules is

    Recursion_Level : Natural := 0;

    function Accept_Token (Lexer : in out Lexer_Type;
                           Token_Class : Token_Class_Type)
                          return Boolean is
        Token : Token_Type;
    begin
        Token := Lexer.Peek_Token;

        Debug_Put ("| Accept token : "
                     & Token_Class'Wide_Wide_Image
                     & ". Readed:");
        Debug_Token (Token);

        if Token.Get_Class = Token_Class then
            Token := Lexer.Take_Token;

            Debug_Put  ("| --> True");

            return True;
        else
            Debug_Put ("| --> False");
            return False;
        end if;
    end Accept_Token;

    function Accept_Token (Lexer : in out Lexer_Type;
                           Token_Class : Token_Class_Type;
                           Value : Wide_Wide_String)
                          return Boolean is
        Token : Token_Type;
    begin
        Token := Lexer.Peek_Token;

        Debug_Put ("| Accept token : "
                     & Token_Class'Wide_Wide_Image
                     & " with value '"
                     & Value
                     & "'. Readed:");
        Debug_Token (Token);

        if Token.Get_Class = Token_Class and then
          Token.Get_Value = To_Universal_String (Value)
        then
            Token := Lexer.Take_Token;

            Debug_Put ("| --> True");

            return True;
        else
            Debug_Put ("| --> False");
            return False;
        end if;
    end Accept_Token;

    --  [5] base ::= '@base' IRIREF '.'
    function Base (Lexer : in out Lexer_Type) return Boolean is
        Ret : Boolean;
        Token : Token_Type;
    begin
        Begin_Rule ("Base");

        Ret := Accept_Token (Lexer, Language_Tag, "@base")
          and then Expect_Token (Lexer, IRI_Reference, Token)
          and then Expect_Token (Lexer, Reserved_Word, ".");

        if Ret then
            Base_Directive_Callback (Token.Get_Value);
        end if;

        End_Rule;
        return Ret;
    end Base;

    procedure Begin_Rule (Rule_Name : Wide_Wide_String) is
    begin
        Debug_Put (Rule_Name & " ->");
        Recursion_Level := Recursion_Level + 1;
    end Begin_Rule;

    function Blank_Node (Lexer : in out Lexer_Type) return Boolean is
    begin
        return False;
    end Blank_Node;

    function Blank_Node_Property_List (Lexer : in out Lexer_Type)
                                      return Boolean is
    begin
        return False;
    end Blank_Node_Property_List;

    function Boolean_Literal (Lexer : in out Lexer_Type) return Boolean is
    begin
        return False;
    end Boolean_Literal;

    function Collection (Lexer : in out Lexer_Type) return Boolean is
    begin
        return False;
    end Collection;

    procedure Debug_Put (S : Wide_Wide_String) is
    begin
        if Debug_Mode then
            for i in 0 .. Recursion_Level loop
                Put ('-');
            end loop;
            Put (" " & Recursion_Level'Wide_Wide_Image & "| ");
            Put_Line (S);
        end if;
    end Debug_Put;

    procedure Debug_Token (Token : Token_Type) is
    begin
        Debug_Put ("| Token : <"
                     & Token.Get_Class'Wide_Wide_Image
                     & "> '"
                     & To_Wide_Wide_String (Token.Get_Value)
                     & "'");
    end Debug_Token;

    --  [3] directive ::= prefixID | base | sparqlPrefix | sparqlBase
    function Directive (Lexer : in out Lexer_Type) return Boolean is
        Ret : Boolean;
    begin
        Begin_Rule ("Directive");

        Ret := Prefix_ID (Lexer)
          or else Base (Lexer)
          or else Sparql_Prefix (Lexer)
          or else Sparql_Base (Lexer);

        End_Rule;
        return Ret;
    end Directive;

    procedure End_Rule is
    begin
        Recursion_Level := Recursion_Level - 1;
    end End_Rule;

    function Expect_Token (Lexer : in out Lexer_Type;
                           Token_Class : Token_Class_Type;
                           Token : in out Token_Type)
                          return Boolean is
    begin
        Token := Lexer.Take_Token;

        Debug_Put ("| Expect token : "
                     & Token_Class'Wide_Wide_Image
                     & ". Readed:");
        Debug_Token (Token);

        if Token.Get_Class = Token_Class then
            Debug_Put ("| --> True");

            return True;
        else
            raise Expected_Token_Exception with
              "Expected token of class '" & Token_Class'Image &
              "' and got '" & Token.Get_Class'Image & "'.";
            --  return False;
        end if;
    end Expect_Token;

    function Expect_Token (Lexer : in out Lexer_Type;
                           Token_Class : Token_Class_Type)
                          return Boolean is
        Token : Token_Type;
    begin
        return Expect_Token (Lexer, Token_Class, Token);
    end Expect_Token;

    function Expect_Token (Lexer : in out Lexer_Type;
                           Token_Class : Token_Class_Type;
                           Value : Wide_Wide_String)
                          return Boolean is
        Token : Token_Type;
        Ret : Boolean;
    begin
        Ret := Expect_Token (Lexer, Token_Class, Token);

        Debug_Put ("| Expect token with value '" & Value & "'");

        if Ret and then Token.Get_Value = To_Universal_String (Value)
        then
            Debug_Put ("| --> True");
            return True;
        else
            raise Expected_Token_Exception with
              "Unexpected token value.";
            --  return False;
        end if;
    end Expect_Token;

    function IRI (Lexer : in out Lexer_Type) return Boolean is
    begin
        return False;
    end IRI;

    function Literal (Lexer : in out Lexer_Type) return Boolean is
    begin
        return False;
    end Literal;

    function Numeric_Literal (Lexer : in out Lexer_Type) return Boolean is
    begin
        return False;
    end Numeric_Literal;

    function Object (Lexer : in out Lexer_Type) return Boolean is
    begin
        return False;
    end Object;

    function Object_List (Lexer : in out Lexer_Type) return Boolean is
    begin
        return False;
    end Object_List;

    function Predicate (Lexer : in out Lexer_Type) return Boolean is
    begin
        return False;
    end Predicate;

    function Predicate_Object_List (Lexer : in out Lexer_Type)
                                   return Boolean is
    begin
        return False;
    end Predicate_Object_List;

    --  [4] prefixID ::= '@prefix' PNAME_NS IRIREF '.'
    function Prefix_ID (Lexer : in out Lexer_Type) return Boolean is
        Token_Prefix, Token_IRI : Token_Type;
        Prefix : Prefix_Type;
        Ret : Boolean;
    begin
        Begin_Rule ("Prefix_ID");

        Ret :=  Accept_Token (Lexer, Language_Tag, "@prefix")
          and then Expect_Token (Lexer, Prefix_Namespace, Token_Prefix)
          and then Expect_Token (Lexer, IRI_Reference, Token_IRI)
          and then Expect_Token (Lexer, Reserved_Word, ".");

        if Ret then
            Prefix.Initialize (Token_Prefix.Get_Value, Token_IRI.Get_Value);
            Prefix_Directive_Callback (Prefix);
        end if;

        End_Rule;
        return Ret;
    end Prefix_ID;

    function Prefixed_Name (Lexer : in out Lexer_Type) return Boolean is
    begin
        return False;
    end Prefixed_Name;

    function RDF_Literal (Lexer : in out Lexer_Type) return Boolean is
    begin
        return False;
    end RDF_Literal;

    function Sparql_Base (Lexer : in out Lexer_Type) return Boolean is
    begin
        return False;
    end Sparql_Base;

    function Sparql_Prefix (Lexer : in out Lexer_Type) return Boolean is
    begin
        return False;
    end Sparql_Prefix;

    --  [2] statement ::= directive | triples '.'
    function Statement (Lexer : in out Lexer_Type) return Boolean is
        Ret : Boolean;
    begin
        Begin_Rule ("Statement");

        Ret := Directive (Lexer)
          or else (Triples (Lexer)
                     and then Accept_Token (Lexer, Reserved_Word, "."));

        End_Rule;
        return Ret;
    end Statement;

    function String (Lexer : in out Lexer_Type) return Boolean is
    begin
        return False;
    end String;

    function Subject (Lexer : in out Lexer_Type) return Boolean is
    begin
        return False;
    end Subject;

    --  [6] triples ::= subject predicateObjectList
    --    | blankNodePropertyList predicateObjectList?
    function Triples (Lexer : in out Lexer_Type) return Boolean is
    begin
        if Subject (Lexer) then
            return Predicate_Object_List (Lexer);
        else
            return Blank_Node_Property_List (Lexer)
              and then (Predicate_Object_List (Lexer) or else True);
        end if;
    end Triples;

    function Turtle_Doc (Lexer : in out Lexer_Type) return Boolean is
        Ret : Boolean := True;
    begin
        Begin_Rule ("Turtle_Doc");

        loop
            Ret := Statement (Lexer);
            exit when not Ret;
        end loop;

        End_Rule;
        return True;
    end Turtle_Doc;

    function Verb (Lexer : in out Lexer_Type) return Boolean is
    begin
        return False;
    end Verb;
end Syntactical.Rules;
