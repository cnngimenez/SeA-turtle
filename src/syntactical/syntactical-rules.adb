-- syntactical-rules.adb --- 

-- Copyright 2020 cnngimenez
--
-- Author: cnngimenez

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

-------------------------------------------------------------------------

package body Syntactical.Rules is
    function Accept_Token (Token_Name : Token_Type; Value : Wide_Wide_String)
                          return Boolean is
    begin
        if Lexer.Accept_Token (Token_Name, Value) then
            Lexer.Consume;
            return True;
        else
            return False;
        end if;
    end Accept_Token;
    
    function Expect_Token (Token_Name : Token_Type) return Boolean is
    begin
        if Lexer.Accept_Token (Token_Name) then
            Lexer.Consume;
            return True;
        else
            --  Raise exception here
            return False;
        end if;
    end Expect_Token;

    function Base (Lexer : in out Lexer_Type) return Boolean is
    begin
        return Accept_Token (Language_Tag, "@base") 
          and then Expect_Token (Iri_Ref)
          and then Expect_Token (Dot);
    end Base;
    
    function Blank_Node (Lexer : in out Lexer_Type) return Boolean;
    
    function Blank_Node_Property_List (Lexer : in out Lexer_Type) return Boolean;
    
    function Boolean_Literal (Lexer : in out Lexer_Type) return Boolean;
    
    function Collection (Lexer : in out Lexer_Type) return Boolean;
    
    function Directive (Lexer : in out Lexer_Type) return Boolean is
    begin
        return Prefix_ID (Lexer) 
          or else Base (Lexer)
          or else Sparql_Prefix (Lexer)
          or else Sparql_Base (Lexer);
    end Directive;
    
    function IRI (Lexer : in out Lexer_Type) return Boolean;
    
    function Literal (Lexer : in out Lexer_Type) return Boolean;
    
    function Numeric_Literal (Lexer : in out Lexer_Type) return Boolean;
    
    function Object (Lexer : in out Lexer_Type) return Boolean;
    
    function Object_List (Lexer : in out Lexer_Type) return Boolean;
    
    function Predicate (Lexer : in out Lexer_Type) return Boolean;
    
    function Predicate_Object_List (Lexer : in out Lexer_Type) return Boolean;
    
    function Prefix_ID (Lexer : in out Lexer_Type) return Boolean;
    
    function Prefixed_Name (Lexer : in out Lexer_Type) return Boolean;
    
    function RDF_Literal (Lexer : in out Lexer_Type) return Boolean;
    
    function Sparql_Base (Lexer : in out Lexer_Type) return Boolean;
    
    function Sparql_Prefix (Lexer : in out Lexer_Type) return Boolean;

    function Statement (Lexer : in out Lexer_Type) return Boolean is
    begin
        if not Directive (Lexer) then
            if not Triples (Lexer) then
                return False;
            end if;
        end if;
        
        Accept_Token (Dot);
    end Statement;
    
    function String (Lexer : in out Lexer_Type) return Boolean;
    
    function Subject (Lexer : in out Lexer_Type) return Boolean;
    
    function Triples (Lexer : in out Lexer_Type) return Boolean;
    
    function Turtle_Doc (Lexer : in out Lexer_Type) return Booleanis
    begin
        
    end Turtle_Doc;
    
    function Verb (Lexer : in out Lexer_Type) return Boolean;
    
end Syntactical.Rules;
