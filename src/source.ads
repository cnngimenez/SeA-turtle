--  source.ads ---

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

with Ada.Strings.Wide_Wide_Unbounded;
use Ada.Strings.Wide_Wide_Unbounded;

--  The Turtle source.
--  A source could be a string or a file. Despite how a source of the text
--  is implemented it should have some predefined functions.
package Source is

    type Source_Type is tagged private;

    procedure Initialize (Source : in out Source_Type;
                         Data : Wide_Wide_String);
    procedure Next (Source : in out Source_Type;
                    Symbol : out Wide_Wide_Character);
    procedure Previous (Source : in out Source_Type;
                        Symbol : out Wide_Wide_Character);
    function End_Of_Source (Source : Source_Type) return Boolean;
private
    type Source_Type is tagged record
        Buffer : Unbounded_Wide_Wide_String;
        Current_Position : Natural;
    end record;
end Source;
