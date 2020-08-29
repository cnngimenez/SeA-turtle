--  elements-prefixes.adb ---

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

package body Elements.Prefixes is

    function Get_IRI (Prefix : Prefix_Type) return Universal_String is
    begin
        return Prefix.IRI;
    end Get_IRI;

    function Get_Name (Prefix : Prefix_Type) return Universal_String is
    begin
        return Prefix.Name;
    end Get_Name;

    procedure Initialize (Prefix : in out Prefix_Type;
                          Name, IRI : Universal_String) is
    begin
        Prefix.Name := Name;
        Prefix.IRI := IRI;
    end Initialize;

    function Is_IRI_Ending_Correctly (Prefix : Prefix_Type)
                                     return Boolean is
    begin
        return Prefix.IRI.Ends_With ("#") or else
          Prefix.IRI.Ends_With ("/");
    end Is_IRI_Ending_Correctly;

    procedure Set_IRI (Prefix : in out Prefix_Type;
                       IRI : Universal_String) is
    begin
        Prefix.IRI := IRI;
    end Set_IRI;

    procedure Set_Name (Prefix : in out Prefix_Type;
                        Name : Universal_String) is
    begin
        Prefix.Name := Name;
    end Set_Name;

end Elements.Prefixes;
