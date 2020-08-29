--  syntactical_analyser.adb ---

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
use Ada.Wide_Wide_Text_IO;
with Ada.Strings.Wide_Wide_Unbounded;
use Ada.Strings.Wide_Wide_Unbounded;

with Syntactical.Rules;
with Elements.Triples;
use Elements.Triples;
with Elements.Prefixes;
use Elements.Prefixes;
with Source;
use Source;
with Lexical.Turtle_Lexer;
use Lexical.Turtle_Lexer;
with Syntactical.Analyser;
use Syntactical.Analyser;

with League.Strings;
use League.Strings;

procedure Syntactical_Analyser is

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
        Put_Line ("Base IRI detected:");
        Put_Line (To_Wide_Wide_String (Base));
    end Print_Base;

    procedure Print_Prefix (Prefix : Prefix_Type) is
    begin
        Put_Line ("Prefix detected: ");
        Put_Line (To_Wide_Wide_String (Prefix.Get_Name)
               & " -> "
               & To_Wide_Wide_String (Prefix.Get_IRI));
    end Print_Prefix;

    procedure Print_Triple (Triple : Triple_Type) is
    begin
        Put_Line ("Triple detected: ");
        Put_Line ("<"
                    & To_Wide_Wide_String (Triple.Get_Subject)
                    & ">");
        Put_Line ("<"
                    & To_Wide_Wide_String (Triple.Get_Predicate)
                    & ">");
        Put_Line ("<"
                    & To_Wide_Wide_String (Triple.Get_Object)
                    & ">");
    end Print_Triple;

    procedure Print_Warning (Message : Universal_String) is
    begin
        Put_Line ("Warning: "
                    & To_Wide_Wide_String (Message));
    end Print_Warning;

    function Read_File (Path : String) return Wide_Wide_String is
        Buffer : Unbounded_Wide_Wide_String;
        File : File_Type;
        Symbol : Wide_Wide_Character;
    begin
        Open (File, In_File, Path);

        while not End_Of_File (File) loop
            Get (File, Symbol);
            Append (Buffer, Symbol);
        end loop;

        Close (File);

        return To_Wide_Wide_String (Buffer);
    end Read_File;

    Syntax_Analyser : Syntax_Analyser_Type;
    Lexer : Lexer_Type;
    Source : Source_Type;
begin
    if Argument_Count < 1 then
        Put_Line ("Synopsis :");
        Put_Line ("    ./syntactical_analyser TURTLE_FILE [DEBUG_MODE]");
        New_Line;
        Put_Line ("DEBUG_MODE: off | accepted | full");
        Put_Line ("  - accepted: Show only accepted tokens.");
        Put_Line
          ("  - full: Show all rules applied, even those ones that failed.");
        New_Line;
        Put_Line
          ("For example: ./syntactical_analyser my_turtle_file.ttl full");
        return;
    end if;

    Source.Initialize (Read_File (Argument (1)));

    Lexer.Create (Source);
    Syntax_Analyser.Set_Lexer (Lexer);

    if Argument_Count > 1 then
        if Argument (2) = "full" then
            Syntax_Analyser.Set_Debug_Mode (Full_Debug);
        elsif Argument (2) = "accepted" then
            Syntax_Analyser.Set_Debug_Mode (Only_Accepted_Tokens);
        end if;
    end if;

    if Analyser.Turtle_Doc (Syntax_Analyser) then
        Put_Line
          ("Syntactical analysis : This is a valid RDF/Turtle file.");
    else
        Put_Line
          ("Syntactical analysis : This is not a valid RDF/urtle file.");
    end if;
end Syntactical_Analyser;
