--  mapped_states.adb ---

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
with Ada.Command_Line;
use Ada.Command_Line;

with Lexical.Token;
use Lexical.Token;
with Lexical.Finite_Automata;
use Lexical.Finite_Automata;

procedure Mapped_States is
    Token_Type : Token_Class_Type;
    With_Invalids : Boolean := False;
begin
    Put_Line ("The following is a list of states and its mapped token class.");
    Put_Line ("Use the following to list states mapped to invalid tokens:");
    Put_Line ("    bin/mapped_states invalids");
    New_Line;

    With_Invalids := Argument_Count > 0 and then Argument (1) = "invalids";

    for State in State_Type loop
        Token_Type := State_To_Token (State);
        if With_Invalids or else Token_Type /= Invalid then
            if Is_Final_State (State) then
                Put_Line (State'Image & " (Acceptable) -> " & Token_Type'Image);
            else
                Put_Line (State'Image & " -> " & Token_Type'Image);
            end if;
        end if;
    end loop;

end Mapped_States;
