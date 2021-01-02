--  lexical_analyser.adb ---

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

with Ada.Command_Line;
use Ada.Command_Line;
with Ada.Wide_Wide_Text_IO;
with Ada.Text_IO;
use Ada.Text_IO;
with Ada.Strings.Wide_Wide_Unbounded;
use Ada.Strings.Wide_Wide_Unbounded;
with Ada.Characters.Conversions;
use Ada.Characters.Conversions;

with Source;
use Source;
with Lexical.Token;
use Lexical.Token;
with Lexical.Turtle_Lexer;
use Lexical.Turtle_Lexer;
with League.Strings;
use League.Strings;

procedure Lexical_Analyser is

    procedure Print_Token (Token : Token_Type);
    function Read_File (Path : String) return Wide_Wide_String;

    procedure Print_Token (Token : Token_Type) is
    begin
        Put ("Token : <");
        Put (Token.Get_Class'Image);
        Put ("> : '");
        Ada.Wide_Wide_Text_IO.Put (To_Wide_Wide_String (Token.Get_Value));
        Put ("'");
        New_Line;

        case Token.Get_Class is
        when Not_Mapped =>
            Put ("Not_Mapped means that the automata state may return an "
                   & "acceptable state but it is not mapped into a "
                   & "Token_Class_Type (a token class name).");
            New_Line;
        when Invalid =>
            Put ("Invalid means that the automata has rejected the token.");
            Put (" This is a potential lexical error to be reported to the "
                   & " user.");
            New_Line;
        when others =>
            null;
        end case;
    end Print_Token;

    function Read_File (Path : String) return Wide_Wide_String is
        Buffer : Unbounded_Wide_Wide_String;
        File : File_Type;
        Symbol : Character;
    begin
        Open (File, In_File, Path);

        while not End_Of_File (File) loop
            Get_Immediate (File, Symbol);
            Append (Buffer, To_Wide_Wide_Character (Symbol));
        end loop;

        Close (File);

        return To_Wide_Wide_String (Buffer);
    end Read_File;

    Lexer : Lexer_Type;
    Token : Token_Type;
    Source : Source_Type;
begin
    if Argument_Count < 1 then
        Put_Line ("Synopsis :");
        Put_Line ("    ./lexical_analyser TURTLE_FILE");
        return;
    end if;

    Source.Initialize (Read_File (Argument (1)));

    Lexer.Create (Source);

    loop
        Token := Lexer.Take_Token;

        Put (Lexer.Get_Source.Get_Current_Position'Image);
        Put (" : ");
        Print_Token (Token);
        exit when Token = Invalid_Token or else
          Lexer.Get_Source.Is_End_Of_Source;
    end loop;
end Lexical_Analyser;
