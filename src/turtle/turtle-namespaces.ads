--  turtle-namespaces.ads ---

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

with Ada.Containers.Hashed_Maps;
with League.Strings;
use League.Strings;
with League.Strings.Hash;

package Turtle.Namespaces is

    type Namespaces_Type is tagged private;

    --  Add a Prefix -> Iri association to the namespaces.
    procedure Assign_Namespace (Namespaces : in out Namespaces_Type;
                                Prefix : Universal_String;
                                Iri : Universal_String);

    --  Replace a "Prefix:Suffix" string into a complete IRI.
    function Substitute_Prefix (Namespaces : Namespaces_Type;
                                Pname_Ns : Universal_String)
                               return Universal_String;

private

    package Namespaces_Map_Package is new Ada.Containers.Hashed_Maps
      (Key_Type => Universal_String,
       Element_Type => Universal_String,
       Hash => League.Strings.Hash,
       Equivalent_Keys => "=");

    type Namespaces_Type is tagged record
        Hash : Namespaces_Map_Package.Map;
    end record;

end Turtle.Namespaces;
