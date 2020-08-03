--  symbol_set.adb ---

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
with Lexical.Symbol_Sets;
use Lexical.Symbol_Sets;

procedure Symbol_Set is
    procedure Print_Possible_Sets
      (Possible_Sets : Possible_Symbol_Sets_Type);

    procedure Print_Possible_Sets
      (Possible_Sets : Possible_Symbol_Sets_Type) is
        function Test_Set (Set : Symbol_Set_Type) return Boolean;        
        
        function Test_Set (Set : Symbol_Set_Type) return Boolean is
        begin
            Put ("Possible Set: '");
            if Set.Is_Unitary then
                Put (Set.Get_Symbol);
                Put_Line ("' (Unitary set).");
            else
                Put (Set.Get_Name'Wide_Wide_Image);
                Put_Line ("'");
            end if;
            return False;
        end Test_Set;
        
        Set : Symbol_Set_Type;
    begin
        Set := Symbol_Set_Type (Find_Set (Possible_Sets, Test_Set'Access));
    end Print_Possible_Sets;

    New_Line_Char : constant Wide_Wide_Character :=
      Wide_Wide_Character'Val (13);
    Input_Symbol : Wide_Wide_Character;
    Possible_Sets : Possible_Symbol_Sets_Type;
begin
    Put_Line ("Search the symbol sets");

    loop
        Put_Line ("Enter a character");
        Get (Input_Symbol);

        Possible_Sets := Get_Possible_Sets (Input_Symbol);
        Print_Possible_Sets (Possible_Sets);

        exit when Input_Symbol = New_Line_Char;
    end loop;
end Symbol_Set;
