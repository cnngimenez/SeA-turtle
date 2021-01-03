--  linter.adb ---

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
with Ada.Text_IO;
with Ada.Wide_Wide_Text_IO;
use Ada.Wide_Wide_Text_IO;
with Ada.Strings.Wide_Wide_Unbounded;
use Ada.Strings.Wide_Wide_Unbounded;
with Ada.Characters.Conversions;
use Ada.Characters.Conversions;

with Syntactical.Rules;
with SeA.RDF.Triples;
use SeA.RDF.Triples;
with SeA.Namespaces.Prefixes;
use SeA.Namespaces.Prefixes;
with Source;
use Source;
with Lexical.Turtle_Lexer;
use Lexical.Turtle_Lexer;
with Syntactical.Analyser;
use Syntactical.Analyser;

with League.Strings;
use League.Strings;

procedure Linter is

    procedure Print_Triple (Triple : Triple_Type);
    procedure Print_Prefix (Prefix : Prefix_Type);
    procedure Print_Base (Base : Universal_String);
    procedure Print_Warning (Message : Universal_String);
    function Read_File (Path : String) return Wide_Wide_String;

    package Analyser is new Syntactical.Rules
      (
       Triple_Readed_Callback => Print_Triple,
       Prefix_Directive_Callback => Print_Prefix,
       Base_Directive_Callback => Print_Base,
       Warning_Callback => Print_Warning
      );

    procedure Print_Base (Base : Universal_String) is
    begin
        null;
    end Print_Base;

    procedure Print_Prefix (Prefix : Prefix_Type) is
    begin
        null;
    end Print_Prefix;

    procedure Print_Triple (Triple : Triple_Type) is
    begin
        null;
    end Print_Triple;

    procedure Print_Warning (Message : Universal_String) is
    begin
        Put_Line ("Warning: "
                    & To_Wide_Wide_String (Message));
    end Print_Warning;

    function Read_File (Path : String) return Wide_Wide_String is
        Buffer : Unbounded_Wide_Wide_String;
        File : Ada.Text_IO.File_Type;
        Symbol : Character;
        LF_Char : constant Wide_Wide_Character :=
          Wide_Wide_Character'Val (10);
    begin
        Ada.Text_IO.Open (File, Ada.Text_IO.In_File, Path);

        while not Ada.Text_IO.End_Of_File (File) loop
            if Ada.Text_IO.End_Of_Line (File) then
                Append (Buffer, LF_Char);
            end if;
            Ada.Text_IO.Get_Immediate (File, Symbol);
            Append (Buffer, To_Wide_Wide_Character (Symbol));
        end loop;

        Ada.Text_IO.Close (File);

        --  for I in 1..Length (Buffer) loop
        --      if Element (Buffer, I) = LF_Char then
        --          Put ("|");
        --      else
        --          Put (Element (Buffer, I));
        --      end if;
        --  end loop;

        return To_Wide_Wide_String (Buffer);
    end Read_File;

    Syntax_Analyser : Syntax_Analyser_Type;
    Lexer : Lexer_Type;
    Source : Source_Type;
begin
    if Argument_Count < 1 then
        Put_Line ("Synopsis :");
        Put_Line ("    ./linter TURTLE_FILE");
        New_Line;
        Put_Line ("For example: ./linter my_turtle_file.ttl");
        return;
    end if;

    Source.Initialize (Read_File (Argument (1)));

    Lexer.Create (Source);
    Syntax_Analyser.Set_Lexer (Lexer);

    if Analyser.Turtle_Doc (Syntax_Analyser) then
        Put_Line
          ("Syntactical analysis : This is a valid RDF/Turtle file.");
    else
        Put_Line
          ("Syntactical analysis : This is not a valid RDF/Turtle file.");
    end if;
end Linter;
