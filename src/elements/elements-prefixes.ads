--  elements-prefixes.ads ---

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

with League.Strings;
use League.Strings;

--
--  Prefixes Package: Representation of Prefix-IRI associations.
--
--  Types and functions to represent a Prefix-IRI association in memory.
--  According to [1], this is the *namespace prefix* and *namespace IRI*
--  association.
--
--  [1] https://www.w3.org/TR/rdf11-concepts/#vocabularies
--
--  TODO: Check for well formed namespace IRI (must end in "/" or "#").
--
package Elements.Prefixes is

    --
    --  The namespace prefix-IRI association type.
    --
    type Prefix_Type is tagged private;

    --
    --  Initialize a Prefix record.
    --
    --  Name: The namespace prefix.
    --  IRI: The namespace IRI.
    --
    procedure Initialize (Prefix : in out Prefix_Type;
                          Name, IRI : Universal_String);

    --
    --  Return the namespace IRI
    --
    function Get_IRI (Prefix : Prefix_Type) return Universal_String;
    --
    --  Return the namespace prefix.
    --
    function Get_Name (Prefix : Prefix_Type) return Universal_String;
    procedure Set_IRI (Prefix : in out Prefix_Type; IRI : Universal_String);
    procedure Set_Name (Prefix : in out Prefix_Type; Name : Universal_String);

    function Is_IRI_Ending_Correctly (Prefix : Prefix_Type) return Boolean;
    function Is_Relative_IRI (Prefix : Prefix_Type) return Boolean;
    function Is_IRI_Valid (Prefix : Prefix_Type) return Boolean;

private

    type Prefix_Type is tagged record
        --  The namespace prefix
        Name : Universal_String;
        --  The namespace IRI
        IRI : Universal_String;
    end record;

end Elements.Prefixes;
