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
                                  IRI : Universal_String) is
    begin
        Analyser.Parser_State.Set_Cur_Subject (IRI);
    end Assign_Cur_Subject;

    procedure Assign_Namespace (Analyser : in out Syntax_Analyser_Type;
                                Prefix : Universal_String;
                                Iri : Universal_String) is
    begin
        Analyser.Parser_State.Assign_Namespace (Prefix, Iri);
    end Assign_Namespace;

    function Emit_RDF_Triple (Analyser : in out Syntax_Analyser_Type;
                              Object_IRI : Universal_String)
                             return Triple_Type is
        A_Triple : Triple_Type;
    begin
        A_Triple.Initialize
          (Analyser.Parser_State.Get_Cur_Subject,
           Analyser.Parser_State.Get_Cur_Predicate,
           Object_IRI,
           Subject_Type => IRI,
           Object_Type => IRI);

        return A_Triple;
    end Emit_RDF_Triple;

    function Get_Base_URI (Analyser : in out Syntax_Analyser_Type)
                      return Universal_String is
    begin
        return Analyser.Parser_State.Get_Base_URI;
    end Get_Base_URI;

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
