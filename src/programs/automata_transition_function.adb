--  automata_transition_function.adb ---

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

with Ada.Wide_Wide_Text_IO;
use Ada.Wide_Wide_Text_IO;
with Lexical.Finite_Automata;
use Lexical.Finite_Automata;
with Lexical.Symbol_Sets;
use Lexical.Symbol_Sets;

procedure Automata_Transition_Function is
    procedure Print_Transition (From_State : State_Type;
                                Symbol : Symbol_Set_Type;
                                To_State : State_Type);

    procedure Print_Transition (From_State : State_Type;
                                Symbol : Symbol_Set_Type;
                                To_State : State_Type) is
    begin
        Put ("(");
        Put (From_State'Wide_Wide_Image);
        Put (", ");
        if Symbol.Is_Unitary then
            Put ("'" & Symbol.Get_Symbol & "'");
        else
            Put (Symbol.Get_Name'Wide_Wide_Image);
        end if;
        Put (") -> ");
        Put_Line (To_State'Wide_Wide_Image);
    end Print_Transition;

begin
    Walk_Function (Print_Transition'Access);
end Automata_Transition_Function;
