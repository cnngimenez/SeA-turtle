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
    EOF_Char : constant Wide_Wide_Character :=
      Wide_Wide_Character'Val (0);

    function Get_Current_Position (Source : Source_Type) return Natural is
    begin
        return Source.Current_Position;
    end Get_Current_Position;

    procedure Initialize (Source : in out Source_Type;
                         Data : Wide_Wide_String) is
    begin
        Source.Buffer := To_Unbounded_Wide_Wide_String (Data);
        Source.Current_Position := 0;
    end Initialize;

    function Is_End_Of_Source (Source : Source_Type) return Boolean is
    begin
        return Source.Current_Position >= Length (Source.Buffer);
    end Is_End_Of_Source;

    procedure Next (Source : in out Source_Type;
                    Symbol : out Wide_Wide_Character) is
    begin
        if Source.Is_End_Of_Source then
            Symbol := EOF_Char;
            return;
        end if;

        if Source.Current_Position < Length (Source.Buffer) then
            Source.Current_Position := Source.Current_Position + 1;
        end if;
        Symbol := Element (Source.Buffer, Source.Current_Position);
    end Next;

    procedure Previous (Source : in out Source_Type;
                        Symbol : out Wide_Wide_Character) is
    begin
        if Source.Is_End_Of_Source then
            Symbol := EOF_Char;
            return;
        end if;

        if Source.Current_Position > 0 then
            Source.Current_Position := Source.Current_Position - 1;
        end if;
        Symbol := Element (Source.Buffer, Source.Current_Position);
    end Previous;

end Source;
