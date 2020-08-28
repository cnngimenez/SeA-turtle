--  elements-triples.adb ---

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

package body Elements.Triples is

    function Get_Object (Triple : Triple_Type) return Universal_String is
    begin
        return Triple.Object;
    end Get_Object;

    function Get_Object_Type (Triple : Triple_Type)
                             return Object_Type_Type is
    begin
        return Triple.Object_Type;
    end Get_Object_Type;

    function Get_Predicate (Triple : Triple_Type) return Universal_String is
    begin
        return Triple.Predicate;
    end Get_Predicate;

    function Get_Subject (Triple : Triple_Type) return Universal_String is
    begin
        return Triple.Subject;
    end Get_Subject;

    function Get_Subject_Type (Triple : Triple_Type)
                              return Subject_Type_Type is
    begin
        return Triple.Subject_Type;
    end Get_Subject_Type;

    procedure Initialize (Triple : in out Triple_Type;
                          Subject : Universal_String;
                          Predicate : Universal_String;
                          Object : Universal_String;
                          Subject_Type : Subject_Type_Type;
                          Object_Type : Object_Type_Type) is
    begin
        Triple.Subject := Subject;
        Triple.Predicate := Predicate;
        Triple.Object := Object;

        --  Triple.Object_Literal_Type :=

        Triple.Subject_Type := Subject_Type;
        Triple.Object_Type := Object_Type;
    end Initialize;

    procedure Set_Object (Triple : in out Triple_Type;
                          Object : Universal_String;
                          Object_Type : Object_Type_Type) is
    begin
        Triple.Object := Object;
        Triple.Object_Type := Object_Type;
    end Set_Object;

    procedure Set_Predicate (Triple : in out Triple_Type;
                             Predicate : Universal_String) is
    begin
        Triple.Predicate := Predicate;
    end Set_Predicate;

    procedure Set_Subject (Triple : in out Triple_Type;
                           Subject : Universal_String;
                           Subject_Type : Subject_Type_Type) is
    begin
        Triple.Subject := Subject;
        Triple.Subject_Type := Subject_Type;
    end Set_Subject;

end Elements.Triples;
