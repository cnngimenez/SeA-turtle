--  syntactical-analyser.adb ---

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

with Ada.Characters;
with Ada.Characters.Conversions;

package body Syntactical.Analyser is

    procedure Add_Recursion_Level
      (Syntax_Analyser : in out Syntax_Analyser_Type) is
    begin
        Syntax_Analyser.Recursion_Level := Syntax_Analyser.Recursion_Level + 1;
    end Add_Recursion_Level;

    procedure Assign_Base_URI (Analyser : in out Syntax_Analyser_Type;
                               URI : Universal_String) is
    begin
        Analyser.Parser_State.Set_Base_URI (URI);
    end Assign_Base_URI;

    procedure Assign_Cur_Predicate (Analyser : in out Syntax_Analyser_Type;
                                    IRI : Universal_String) is
    begin
        if IRI = To_Universal_String ("a") then
            Analyser.Parser_State.Set_Cur_Predicate
              (To_Universal_String
                 ("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"));
        else
            Analyser.Parser_State.Set_Cur_Predicate (IRI);
        end if;
    end Assign_Cur_Predicate;

    procedure Assign_Cur_Subject (Analyser : in out Syntax_Analyser_Type;
                                  Value : Universal_String;
                                  Subject_Type : Subject_Type_Type := IRI) is
    begin
        Analyser.Parser_State.Set_Cur_Subject (Value, Subject_Type);
    end Assign_Cur_Subject;

    procedure Assign_Namespace (Analyser : in out Syntax_Analyser_Type;
                                Prefix : Universal_String;
                                Iri : Universal_String) is
    begin
        Analyser.Parser_State.Assign_Namespace (Prefix, Iri);
    end Assign_Namespace;

    function Current_Position (Analyser : in out Syntax_Analyser_Type)
                              return String is
        Line_Number : constant Natural := Analyser.Get_Line_Number;
        Column_Number : constant Natural  := Analyser.Get_Column_Number;
    begin
        return "(" & Line_Number'Image & " : "
          & Column_Number'Image & "): ";
    end Current_Position;

    function Current_Position (Analyser : in out Syntax_Analyser_Type)
                              return Wide_Wide_String is
        use Ada.Characters;
    begin
        return Conversions.To_Wide_Wide_String (Current_Position (Analyser));
    end Current_Position;

    function Current_Position_Us (Analyser : in out Syntax_Analyser_Type)
                                 return Universal_String is
    begin
        return To_Universal_String (Current_Position (Analyser));
    end Current_Position_Us;

    function Emit_RDF_Triple (Analyser : in out Syntax_Analyser_Type;
                              Object_Value : Universal_String;
                              Object_Type : Object_Type_Type := IRI)
                             return Triple_Type is
    begin
        return Analyser.Parser_State.Get_New_Triple
          (Object_Value, Object_Type);
    end Emit_RDF_Triple;

    function Get_Base_URI (Analyser : in out Syntax_Analyser_Type)
                      return Universal_String is
    begin
        return Analyser.Parser_State.Get_Base_URI;
    end Get_Base_URI;

    function Get_Column_Number (Syntax_Analyser : in out Syntax_Analyser_Type)
                               return Natural is
    begin
        return Syntax_Analyser.Lexer.Get_Column_Number;
    end Get_Column_Number;

    function Get_Debug_Mode (Syntax_Analyser : Syntax_Analyser_Type)
                            return Debug_Mode_Type is
    begin
        return Syntax_Analyser.Debug_Mode;
    end Get_Debug_Mode;

    function Get_Lexer (Syntax_Analyser : Syntax_Analyser_Type)
                      return Lexer_Type is
    begin
        return Syntax_Analyser.Lexer;
    end Get_Lexer;

    function Get_Line_Number (Syntax_Analyser : in out Syntax_Analyser_Type)
                             return Natural is
    begin
        return Syntax_Analyser.Lexer.Get_Line_Number;
    end Get_Line_Number;

    function Get_New_Anon_Value (Syntax_Analyser : in out Syntax_Analyser_Type)
                                return Universal_String is
    begin
        return Syntax_Analyser.Parser_State.Get_New_Anon_Value;
    end Get_New_Anon_Value;

    function Get_Parser_State (Syntax_Analyser : Syntax_Analyser_Type)
                      return Parser_State_Type is
    begin
        return Syntax_Analyser.Parser_State;
    end Get_Parser_State;

    function Get_Recursion_Level (Syntax_Analyser : Syntax_Analyser_Type)
                      return Natural is
    begin
        return Syntax_Analyser.Recursion_Level;
    end Get_Recursion_Level;

    function Is_Base_IRI_Ending_Correctly
      (Analyser : in out Syntax_Analyser_Type)
      return Boolean is
    begin
        return Analyser.Parser_State.Is_Base_IRI_Ending_Correctly;
    end Is_Base_IRI_Ending_Correctly;

    function Is_Base_IRI_Relative
      (Analyser : in out Syntax_Analyser_Type)
      return Boolean is
    begin
        return Analyser.Parser_State.Is_Base_IRI_Relative;
    end Is_Base_IRI_Relative;

    function Is_Base_IRI_Valid
      (Analyser : in out Syntax_Analyser_Type)
      return Boolean is
    begin
        return Analyser.Parser_State.Is_Base_IRI_Relative;
    end Is_Base_IRI_Valid;

    function Is_End_Of_Source (Syntax_Analyser : in out Syntax_Analyser_Type)
                              return Boolean is
    begin
        return Syntax_Analyser.Lexer.Get_Source.Is_End_Of_Source;
    end Is_End_Of_Source;

    function Peek_Token (Syntax_Analyser : in out Syntax_Analyser_Type)
                        return Token_Type is
    begin
        return Syntax_Analyser.Lexer.Peek_Token;
    end Peek_Token;

    procedure Remove_Recursion_Level
      (Syntax_Analyser : in out Syntax_Analyser_Type) is
    begin
        if Syntax_Analyser.Recursion_Level > 0 then
            Syntax_Analyser.Recursion_Level :=
              Syntax_Analyser.Recursion_Level - 1;
        end if;
    end Remove_Recursion_Level;

    procedure Restore_Curpredicate (Analyser : in out Syntax_Analyser_Type) is
        Predicate : Universal_String;
    begin
        Predicate := Analyser.Predicate_Heap.First_Element;
        Analyser.Predicate_Heap.Delete_First;

        Analyser.Parser_State.Set_Cur_Predicate (Predicate);
    end Restore_Curpredicate;

    procedure Restore_Cursubject (Analyser : in out Syntax_Analyser_Type) is
        Subject_Element : Subject_Element_Type;
    begin
        Subject_Element := Analyser.Subject_Heap.First_Element;
        Analyser.Subject_Heap.Delete_First;

        Analyser.Parser_State.Set_Cur_Subject (Subject_Element.Subject_Value,
                                               Subject_Element.Subject_Type);
    end Restore_Cursubject;

    procedure Save_Curpredicate (Analyser : in out Syntax_Analyser_Type) is
    begin
        Analyser.Predicate_Heap.Prepend
          (Analyser.Parser_State.Get_Cur_Predicate);
    end Save_Curpredicate;

    procedure Save_Cursubject (Analyser : in out Syntax_Analyser_Type) is
        Subject_Element : Subject_Element_Type;
    begin
        Subject_Element.Subject_Value := Analyser.Parser_State.Get_Cur_Subject;
        Subject_Element.Subject_Type :=
          Analyser.Parser_State.Get_Cur_Subject_Type;
        Analyser.Subject_Heap.Prepend (Subject_Element);
    end Save_Cursubject;

    procedure Set_Debug_Mode (Syntax_Analyser : in out Syntax_Analyser_Type;
                              Debug_Mode : Debug_Mode_Type) is
    begin
        Syntax_Analyser.Debug_Mode := Debug_Mode;
    end Set_Debug_Mode;

    procedure Set_Lexer (Syntax_Analyser : in out Syntax_Analyser_Type;
                         Lexer : Lexer_Type) is
    begin
        Syntax_Analyser.Lexer := Lexer;
    end Set_Lexer;

    procedure Set_Parser_State (Syntax_Analyser : in out Syntax_Analyser_Type;
                                Parser_State : Parser_State_Type) is
    begin
        Syntax_Analyser.Parser_State := Parser_State;
    end Set_Parser_State;

    function Substitute_Prefix (Analyser : in out Syntax_Analyser_Type;
                                Pname_Ns : Universal_String)
                               return Universal_String is
    begin
        return Analyser.Parser_State.Substitute_Prefix (Pname_Ns);
    end Substitute_Prefix;

    function Take_Token (Syntax_Analyser : in out Syntax_Analyser_Type)
                        return Token_Type is
    begin
        return Syntax_Analyser.Lexer.Take_Token;
    end Take_Token;
end Syntactical.Analyser;
