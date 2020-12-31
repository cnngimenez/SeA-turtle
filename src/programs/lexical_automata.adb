--  lexical_automata.adb ---

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

with Ada.Text_IO;
use Ada.Text_IO;
with Ada.Wide_Wide_Text_IO;
with Ada.Characters.Conversions;
use Ada.Characters.Conversions;
with Lexical.Finite_Automata;
use Lexical.Finite_Automata;

procedure Lexical_Automata is
    procedure Print_State;

    Input_Symbol : Character;
    Automata : Automata_Type;

    procedure Print_State is
    begin
        Put ("Automata: ");
        Ada.Wide_Wide_Text_IO.Put (Automata.Get_Current_State'Wide_Wide_Image);
        if Automata.Is_Accepted then
            Put (" (Accepted)");
        end if;
        if Automata.Is_Blocked then
            Put (" BLOCKED!");
        end if;
        New_Line;
    end Print_State;
begin
    Automata.Initialize;

    Print_State;
    loop
        Get (Input_Symbol);
        Automata.Next (To_Wide_Wide_Character (Input_Symbol));
        Print_State;

        exit when End_Of_File;
    end loop;
end Lexical_Automata;
