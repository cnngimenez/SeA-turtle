--  lexical-turtle_lexer.adb ---

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

--  with Ada.Wide_Wide_Text_IO;
--  use Ada.Wide_Wide_Text_IO;
with League.Strings;
use League.Strings;
with Lexical.Finite_Automata;
use Lexical.Finite_Automata;

package body Lexical.Turtle_Lexer is

    procedure Create (Lexer : in out Lexer_Type; Source : Source_Type) is
    begin
        Lexer.Source := Source;
    end Create;

    --  function Peek_Token (Lexer : Lexer_Type) return Token_Type is
    --      use Direct_File;

    --      Current_Pos : Direct_File.Positive_Count;
    --      Token : Token_Type;
    --  begin
    --      Current_Pos := Index (Lexer.File);

    --      if not End_Of_File (Lexer.File) then
    --          Token := Lexer.Start;
    --      else
    --          return Invalid_Token;
    --      end if;

    --      Set_Index (Lexer.File, Current_Pos);
    --      return Token;
    --  end Peek_Token;

    function Reduce_Symbol (Symbol : Wide_Wide_Character)
                           return Wide_Wide_Character is
    begin
        if Symbol in 'a' .. 'z' or else Symbol in 'A' .. 'Z' then
            return 'a';
        end if;

        if Symbol in '0' .. '9' then
            return '0';
        end if;

        return Symbol;
    end Reduce_Symbol;

    --  First state of the automata.
    procedure Start (Lexer : in out Lexer_Type; Token : out Token_Type) is
        Automata : Automata_Type;
        Symbol : Wide_Wide_Character;
        Token_Str : Universal_String := Empty_Universal_String;
    begin
        Automata.Initialize;

        while not End_Of_Source (Lexer.Source) and then not Automata.Is_Blocked
        loop
            Lexer.Source.Next (Symbol);
            Token_Str.Append (Symbol);
            Automata.Next (Symbol);
        end loop;

        if Token_Str.Length > 0 then
            Token_Str := Token_Str.Head (Token_Str.Length - 1);
        end if;
        Lexer.Source.Previous (Symbol);

        if Automata.Is_Blocked then
            Automata.Previous_State;
        end if;

        if Automata.Is_Accepted then
            Token.Initialize (Automata.Get_Current_State, Token_Str);
        else
            Token := Invalid_Token;
        end if;
    end Start;

    function Take_Token (Lexer : in out Lexer_Type) return Token_Type is
        Token : Token_Type;
    begin
        if not End_Of_Source (Lexer.Source) then
            Lexer.Start (Token);
        else
            return Invalid_Token;
        end if;

        return Token;
    end Take_Token;

end Lexical.Turtle_Lexer;
