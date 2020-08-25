--  turtle-namespaces.adb ---

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
package body Turtle.Namespaces is

    procedure Assign_Namespace (Namespaces : in out Namespaces_Type;
                                Prefix : Universal_String;
                                Iri : Universal_String) is
    begin
        Namespaces.Hash.insert (Prefix, Iri);
    end Assign_Namespace;

    function Substitute_Prefix (Namespaces : Namespace_Type;
                                Pname_Ns : Universal_String)
                               return Universal_String is
        Dot_Pos : Natural;
        Prefix, Iri : Universal_String;
    begin
        Dot_Pos := Pname_Ns.Index (Ww2u (":"));
        Prefix := Pname_Ns.Head_To (Dot_Pos);

        Iri := Namespaces.Element (Prefix);

        return Pname_Ns.Replace (0, Dot_Pos, Iri);
    end Substitute_Prefix;

end Turtle.Namespaces;
