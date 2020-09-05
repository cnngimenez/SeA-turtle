--  turtle-parser_states.adb ---

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

with League.IRIs;
use League.IRIs;

package body Turtle.Parser_States is

    procedure Assign_Namespace (Parser_State : in out Parser_State_Type;
                                Prefix, Iri : Universal_String) is
    begin
        Parser_State.Namespaces.Assign_Namespace (Prefix, Iri);
    end Assign_Namespace;

    function Get_Base_URI (Parser_State : Parser_State_Type)
                          return Universal_String is
    begin
        return Parser_State.Base_URI;
    end Get_Base_URI;

    function Get_BnodeLabels (Parser_State : Parser_State_Type)
                      return Blank_Node_Labels_Type is
    begin
        return Parser_State.BnodeLabels;
    end Get_BnodeLabels;

    function Get_Cur_Predicate (Parser_State : Parser_State_Type)
                      return Universal_String is
    begin
        return Parser_State.Cur_Predicate;
    end Get_Cur_Predicate;

    function Get_Cur_Subject (Parser_State : Parser_State_Type)
                             return Universal_String is
    begin
        return Parser_State.Cur_Subject;
    end Get_Cur_Subject;

    function Get_Namespaces (Parser_State : Parser_State_Type)
                      return Namespaces_Type is
    begin
        return Parser_State.Namespaces;
    end Get_Namespaces;

    function Is_Base_IRI_Ending_Correctly
      (Parser_State : in out Parser_State_Type)
      return Boolean is
    begin
        return Parser_State.Base_URI.Ends_With ("#") or else
          Parser_State.Base_URI.Ends_With ("/");
    end Is_Base_IRI_Ending_Correctly;

    function Is_Base_IRI_Relative
      (Parser_State : in out Parser_State_Type)
      return Boolean is
        IRIObj : constant IRI :=
          From_Universal_String (Parser_State.Base_URI);
    begin
        return Parser_State.Base_URI.Index ("/.") > 0 or else
          not IRIObj.Is_Absolute;
    end Is_Base_IRI_Relative;

    function Is_Base_IRI_Valid
      (Parser_State : in out Parser_State_Type)
      return Boolean is
        --  IRIObj : constant IRI :=
        --    From_Universal_String (Parser_State.Base_URI);
    begin
        pragma Compile_Time_Warning
          (True, "Matreshka has not implemented Is_Valid!");
        --  return IRIObj.Is_Valid;
        return True;
    end Is_Base_IRI_Valid;

    procedure Set_Base_URI (Parser_State : in out Parser_State_Type;
                            Base_URI : Universal_String) is
    begin
        Parser_State.Base_URI := Base_URI;
    end Set_Base_URI;

    procedure Set_BnodeLabels (Parser_State : in out Parser_State_Type;
                               BnodeLabels : Blank_Node_Labels_Type) is
    begin
        Parser_State.BnodeLabels := BnodeLabels;
    end Set_BnodeLabels;

    procedure Set_Cur_Predicate (Parser_State : in out Parser_State_Type;
                                 Cur_Predicate : Universal_String) is
    begin
        Parser_State.Cur_Predicate := Cur_Predicate;
    end Set_Cur_Predicate;

    procedure Set_Cur_Subject (Parser_State : in out Parser_State_Type;
                               Cur_Subject : Universal_String) is
    begin
        Parser_State.Cur_Subject := Cur_Subject;
    end Set_Cur_Subject;

    procedure Set_Namespaces (Parser_State : in out Parser_State_Type;
                              Namespaces : Namespaces_Type) is
    begin
        Parser_State.Namespaces := Namespaces;
    end Set_Namespaces;

    function Substitute_Prefix (Parser_State : in out Parser_State_Type;
                                Pname_Ns : Universal_String)
                               return Universal_String is
    begin
        return Parser_State.Namespaces.Substitute_Prefix (Pname_Ns);
    end Substitute_Prefix;

end Turtle.Parser_States;
