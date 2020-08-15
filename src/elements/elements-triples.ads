--  triples.ads ---

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

package Elements.Triples is
    type Triple_Type is tagged private;

    type Object_Type_Type is (IRI, Literal, Blank_Node);
    type Subject_Type_Type is (IRI, Blank_Node);

    procedure Initialize (Triple : in out Triple_Type;
                          Subject : Universal_String;
                          Predicate : Universal_String;
                          Object : Universal_String;
                          Subject_Type : Subject_Type_Type;
                          Object_Type : Object_Type_Type);

    function Get_Subject (Triple : Triple_Type) return Universal_String;
    function Get_Predicate (Triple : Triple_Type) return Universal_String;
    function Get_Object (Triple : Triple_Type) return Universal_String;

    procedure Set_Subject (Triple : in out Triple_Type;
                           Subject : Universal_String;
                           Subject_Type : Subject_Type_Type);
    procedure Set_Predicate (Triple : in out Triple_Type;
                             Predicate : Universal_String);
    procedure Set_Object (Triple : in out Triple_Type;
                          Object : Universal_String;
                          Object_Type : Object_Type_Type);

    function Get_Subject_Type (Triple : Triple_Type) return Subject_Type_Type;
    function Get_Object_Type (Triple : Triple_Type) return Object_Type_Type;

private

    type Triple_Type is tagged record
        Subject : Universal_String;
        Predicate : Universal_String;
        Object : Universal_String;

        Object_Literal_Type : Universal_String;

        Subject_Type : Subject_Type_Type;
        Object_Type : Object_Type_Type;
    end record;
end Elements.Triples;
