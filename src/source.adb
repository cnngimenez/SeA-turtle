--  source.adb ---

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

package body Source is
    function End_Of_Source (Source : Source_Type) return Boolean is
    begin
        return Source.Current_Position >= Length (Source.Buffer);
    end End_Of_Source;

    procedure Initialize (Source : in out Source_Type;
                         Data : Wide_Wide_String) is
    begin
        Source.Buffer := To_Unbounded_Wide_Wide_String (Data);
        Source.Current_Position := 0;
    end Initialize;

    procedure Next (Source : in out Source_Type;
                    Symbol : out Wide_Wide_Character) is
    begin
        if Source.Current_Position < Length (Source.Buffer) then
            Source.Current_Position := Source.Current_Position + 1;
        end if;
        Symbol := Element (Source.Buffer, Source.Current_Position);
    end Next;

    procedure Previous (Source : in out Source_Type;
                        Symbol : out Wide_Wide_Character) is
    begin
        if Source.Current_Position > 0 then
            Source.Current_Position := Source.Current_Position - 1;
        end if;
        Symbol := Element (Source.Buffer, Source.Current_Position);
    end Previous;

end Source;
