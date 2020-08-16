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
                     & ". Readed :");
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
                     & "'. Readed :");
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

    --  [137s] BlankNode ::= BLANK_NODE_LABEL | ANON
    function Blank_Node (Lexer : in out Lexer_Type) return Boolean is
        Ret : Boolean;
    begin
        Begin_Rule ("Blank_Node");

        Ret := Accept_Token (Lexer, Blank_Node_Label)
          or else Accept_Token (Lexer, Anon);

        End_Rule;
        return Ret;
    end Blank_Node;

    --  [14] blankNodePropertyList ::= '[' predicateObjectList ']'
    function Blank_Node_Property_List (Lexer : in out Lexer_Type)
                                      return Boolean is
        Ret : Boolean;
    begin
        Begin_Rule ("Blank_Node_Property_List");

        Ret := Accept_Token (Lexer, Reserved_Word, "[")
          and then Predicate_Object_List (Lexer)
          and then Expect_Token (Lexer, Reserved_Word, "]");

        End_Rule;
        return Ret;
    end Blank_Node_Property_List;

    --  [133s] BooleanLiteral ::= 'true' | 'false'
    function Boolean_Literal (Lexer : in out Lexer_Type) return Boolean is
        Ret : Boolean;
    begin
        Begin_Rule ("Boolean_Literal");

        Ret := Accept_Token (Lexer, Boolean_Literal);

        End_Rule;
        return Ret;
    end Boolean_Literal;

    --  [15] collection ::= '(' object* ')'
    function Collection (Lexer : in out Lexer_Type) return Boolean is
        Ret : Boolean;
    begin
        Begin_Rule ("Collection");

        Ret := Accept_Token (Lexer, Reserved_Word, "(");

        while Object (Lexer) loop
            null;
        end loop;

        Ret := Ret and then Expect_Token (Lexer, Reserved_Word, ")");

        End_Rule;
        return Ret;
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
                     & ". Readed :");
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

    --  [135s] iri ::= IRIREF | PrefixedName
    function IRI (Lexer : in out Lexer_Type) return Boolean is
        Ret : Boolean;
    begin
        Begin_Rule ("IRI");

        Ret := Accept_Token (Lexer, IRI_Reference)
          or else Prefixed_Name (Lexer);

        End_Rule;
        return Ret;
    end IRI;

    --  [13] literal ::= RDFLiteral | NumericLiteral | BooleanLiteral
    function Literal (Lexer : in out Lexer_Type) return Boolean is
        Ret : Boolean;
    begin
        Begin_Rule ("Literal");

        Ret := RDF_Literal (Lexer)
          or else Numeric_Literal (Lexer)
          or else Boolean_Literal (Lexer);

        End_Rule;
        return Ret;
    end Literal;

    --  [16] NumericLiteral ::= INTEGER | DECIMAL | DOUBLE
    function Numeric_Literal (Lexer : in out Lexer_Type) return Boolean is
        Ret : Boolean;
    begin
        Begin_Rule ("Numeric_Literal");

        Ret := Accept_Token (Lexer, Lexical.Token.Integer)
          or else Accept_Token (Lexer, Lexical.Token.Decimal)
          or else Accept_Token (Lexer, Lexical.Token.Double);

        End_Rule;
        return Ret;
    end Numeric_Literal;

    --  [12] object ::= iri | BlankNode | collection |
    --    blankNodePropertyList | literal
    function Object (Lexer : in out Lexer_Type) return Boolean is
        Ret : Boolean;
    begin
        Begin_Rule ("Object");

        Ret := IRI (Lexer)
          or else Blank_Node (Lexer)
          or else Collection (Lexer)
          or else Blank_Node_Property_List (Lexer)
          or else Literal (Lexer);

        End_Rule;
        return Ret;
    end Object;

    --  [8] objectList ::= object (',' object)*
    function Object_List (Lexer : in out Lexer_Type) return Boolean is
        Ret : Boolean;
    begin
        Begin_Rule ("Object_List");

        Ret := Object (Lexer);

        while Accept_Token (Lexer, Reserved_Word, ",") loop
            Ret := Ret and then Object (Lexer);
        end loop;

        End_Rule;
        return Ret;
    end Object_List;

    --  [11] predicate ::= iri
    function Predicate (Lexer : in out Lexer_Type) return Boolean is
        Ret : Boolean;
    begin
        Begin_Rule ("Predicate");

        Ret := Accept_Token (Lexer, IRI_Reference);

        End_Rule;
        return Ret;
    end Predicate;

    --  [7] predicateObjectList ::= verb objectList (';' (verb objectList)?)*
    function Predicate_Object_List (Lexer : in out Lexer_Type)
                                   return Boolean is
        Ret : Boolean;
    begin
        Begin_Rule ("Predicate_Object_List");

        Ret := Verb (Lexer) and then Object_List (Lexer);

        while Ret and then Accept_Token (Lexer, Reserved_Word, ";")
        loop
            if Verb (Lexer) then
                Ret := Ret and then Object_List (Lexer);
            end if;
        end loop;

        End_Rule;
        return Ret;
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

    --  [136s] PrefixedName ::= PNAME_LN | PNAME_NS
    function Prefixed_Name (Lexer : in out Lexer_Type) return Boolean is
        Ret : Boolean;
    begin
        Begin_Rule ("Prefixed_Name");

        Ret := Accept_Token (Lexer, Prefix_With_Local)
          or else Accept_Token (Lexer, Prefix_Namespace);

        End_Rule;
        return Ret;
    end Prefixed_Name;

    --  [128s] RDFLiteral ::= String (LANGTAG | '^^' iri)?
    function RDF_Literal (Lexer : in out Lexer_Type) return Boolean is
        Ret : Boolean;
    begin
        Begin_Rule ("RDF_Literal");

        Ret := String (Lexer);

        if Accept_Token (Lexer, Language_Tag) then
            End_Rule;
            return Ret;
        elsif Accept_Token (Lexer, Reserved_Word, "^^") then
            Ret := Ret and then IRI (Lexer);
        end if;

        End_Rule;
        return Ret;
    end RDF_Literal;

    --  [5s] sparqlBase ::= "BASE" IRIREF
    function Sparql_Base (Lexer : in out Lexer_Type) return Boolean is
        Ret : Boolean;
    begin
        Begin_Rule ("Sparql_Base");

        Ret := Accept_Token (Lexer, Reserved_Word, "BASE")
          and then Expect_Token (Lexer, IRI_Reference);

        End_Rule;
        return Ret;
    end Sparql_Base;

    --  [6s] sparqlPrefix ::= "PREFIX" PNAME_NS IRIREF
    function Sparql_Prefix (Lexer : in out Lexer_Type) return Boolean is
        Ret : Boolean;
    begin
        Begin_Rule ("Sparql_Prefix");

        Ret := Accept_Token (Lexer, Reserved_Word, "PREFIX")
          and then Expect_Token (Lexer, Prefix_Namespace)
          and then Expect_Token (Lexer, IRI_Reference);

        End_Rule;
        return Ret;
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

    --  [17] String ::= STRING_LITERAL_QUOTE | STRING_LITERAL_SINGLE_QUOTE
    --    | STRING_LITERAL_LONG_SINGLE_QUOTE | STRING_LITERAL_LONG_QUOTE
    function String (Lexer : in out Lexer_Type) return Boolean is
        Ret : Boolean;
    begin
        Begin_Rule ("String");

        Ret := Accept_Token (Lexer, String_Literal_Quote)
          or else Accept_Token (Lexer, String_Literal_Single_Quote)
          or else Accept_Token (Lexer, String_Literal_Long_Single_Quote)
          or else Accept_Token (Lexer, String_Literal_Long_Quote);

        End_Rule;
        return Ret;
    end String;

    --  [10] subject ::= iri | BlankNode | collection
    function Subject (Lexer : in out Lexer_Type) return Boolean is
        Ret : Boolean;
    begin
        Begin_Rule ("Subject");

        Ret := IRI (Lexer)
          or else Blank_Node (Lexer)
          or else Collection (Lexer);

        End_Rule;
        return Ret;
    end Subject;

    --  [6] triples ::= subject predicateObjectList
    --    | blankNodePropertyList predicateObjectList?
    function Triples (Lexer : in out Lexer_Type) return Boolean is
        Ret : Boolean;
    begin
        Begin_Rule ("Triples");

        if Subject (Lexer) then
            Ret := Predicate_Object_List (Lexer);
        else
            Ret := Blank_Node_Property_List (Lexer)
              and then (Predicate_Object_List (Lexer) or else True);
        end if;

        End_Rule;
        return Ret;
    end Triples;

    --  [1] turtleDoc ::= statement*
    function Turtle_Doc (Lexer : in out Lexer_Type) return Boolean is
        Ret : Boolean := True;
    begin
        Begin_Rule ("Turtle_Doc");

        loop
            Ret := Ret and then Statement (Lexer);
            exit when not Ret;
        end loop;

        End_Rule;
        return True;
    end Turtle_Doc;

    --  [9] verb ::= predicate | 'a'
    function Verb (Lexer : in out Lexer_Type) return Boolean is
        Ret : Boolean;
    begin
        Begin_Rule ("Verb");

        Ret := Predicate (Lexer)
          or else Accept_Token (Lexer, Reserved_Word, "a");

        End_Rule;
        return Ret;
    end Verb;
end Syntactical.Rules;
