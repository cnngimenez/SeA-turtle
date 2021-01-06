--  lexical-token.adb ---

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

package body Lexical.Token is

    function Get_Class (Token : Token_Type) return Token_Class_Type is
    begin
        return Token.Class;
    end Get_Class;

    function Get_Value (Token : Token_Type) return Universal_String is
    begin
        return Token.Value;
    end Get_Value;

    procedure Initialize (Token : in out Token_Type;
                         Class : Token_Class_Type;
                         Value : Universal_String) is
    begin
        Token.Class := Class;
        Token.Value := Value;
    end Initialize;

    procedure Initialize (Token : in out Token_Type;
                         Class : State_Type;
                         Value : Universal_String) is
    begin
        Token.Class := State_To_Token (Class);
        Token.Value := Value;
    end Initialize;

    function State_To_Token (State : State_Type) return Token_Class_Type is
    begin
        case State is
        when E_Langtag | I_Langtag =>
            return Language_Tag;
        when WS =>
            return Whitespace;
        when Pname_Ns =>
            return Prefix_Namespace;
        when Pname_Ln =>
            return Prefix_With_Local;
        when Dot =>
            return Reserved_Word;
        when Comma =>
            return Reserved_Word;
        when Semicolon =>
            return Reserved_Word;
        when Bracket_Open =>
            return Reserved_Word;
        when Bracket_Close =>
            return Reserved_Word;
        when E_Iriref =>
            return IRI_Reference;
        when E_String_Literal_Quote | E_String_Literal_Quote1  =>
            return String_Literal_Quote;
        when E_Sllq  =>
            return String_Literal_Long_Quote;
        when E_String_Literal_Single_Quote | E_String_Literal_Single_Quote1 =>
            return String_Literal_Single_Quote;
        when E_Sllsq =>
            return String_Literal_Long_Single_Quote;
        when Anon =>
            return Anon;
        when Comment =>
            return Comment;
        when Boolean_Tf =>
            return Boolean_Literal;
        when Prefix_Declaration =>
            return Reserved_Word;
        when Base_Declaration =>
            return Reserved_Word;
        when others =>
            if Is_Final_State (State) then
                return Not_Mapped;
            else
                return Invalid;
            end if;
        end case;
    end State_To_Token;

end Lexical.Token;
