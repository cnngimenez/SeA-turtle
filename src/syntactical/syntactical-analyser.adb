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

    function Get_Debug_Mode (Syntax_Analyser : Syntax_Analyser_Type)
                      return Boolean is
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
                              Debug_Mode : Boolean) is
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

    function Take_Token (Syntax_Analyser : in out Syntax_Analyser_Type)
                        return Token_Type is
    begin
        return Syntax_Analyser.Lexer.Take_Token;
    end Take_Token;
end Syntactical.Analyser;
