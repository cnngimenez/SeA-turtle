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

    function Add_Blanknode (Parser_State : in out Parser_State_Type;
                            Blanknode_Value : Universal_String)
                           return Boolean is
        Label : Universal_String;
    begin
        Label := Blanknode_Value.Slice (3, Length (Blanknode_Value));
        if Parser_State.Bnode_Labels.Map.Contains (Label) then
            return False;
        else
            Parser_State.Bnode_Labels.Map.Insert (Label, Blanknode_Value);
            return True;
        end if;
    end Add_Blanknode;

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

    function Get_Bnode_Labels (Parser_State : Parser_State_Type)
                      return Blank_Node_Labels_Type is
    begin
        return Parser_State.Bnode_Labels;
    end Get_Bnode_Labels;

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

    function Get_New_Anon_Value (Parser_State : in out Parser_State_Type)
                                return Universal_String is
        Label : Universal_String;
    begin
        Label := To_Universal_String ("anon")
          & Parser_State.Anon_Number'Wide_Wide_Image;
        while Parser_State.Bnode_Labels.Map.Contains (Label) loop
            --  The label "anonN" already exists, try next one.
            Parser_State.Anon_Number := Parser_State.Anon_Number + 1;
            Label := To_Universal_String ("anon")
              & Parser_State.Anon_Number'Wide_Wide_Image;
        end loop;

        Parser_State.Bnode_Labels.Map.Insert
          (Label, To_Universal_String ("_:") & Label);
        return To_Universal_String ("_:") & Label;
    end Get_New_Anon_Value;

    function Get_New_Triple (Parser_State : Parser_State_Type;
                             Object_Value : Universal_String;
                             Object_Type : Object_Type_Type :=
                               SeA.RDF.Triples.IRI)
                            return Triple_Type is
        A_Triple : Triple_Type;
    begin
        A_Triple.Initialize (Parser_State.Cur_Subject,
                             Parser_State.Cur_Predicate,
                             Object_Value,
                             Subject_Type => Parser_State.Cur_Subject_Type,
                             Object_Type => Object_Type);
        return A_Triple;
    end Get_New_Triple;

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
        IRIObj : constant League.IRIs.IRI :=
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

    procedure Set_Bnode_Labels (Parser_State : in out Parser_State_Type;
                               Bnode_Labels : Blank_Node_Labels_Type) is
    begin
        Parser_State.Bnode_Labels := Bnode_Labels;
    end Set_Bnode_Labels;

    procedure Set_Cur_Predicate (Parser_State : in out Parser_State_Type;
                                 Cur_Predicate : Universal_String) is
    begin
        Parser_State.Cur_Predicate := Cur_Predicate;
    end Set_Cur_Predicate;

    procedure Set_Cur_Subject (Parser_State : in out Parser_State_Type;
                               Cur_Subject : Universal_String;
                               Cur_Subject_Type : Subject_Type_Type :=
                                 SeA.RDF.Triples.IRI) is
    begin
        Parser_State.Cur_Subject := Cur_Subject;
        Parser_State.Cur_Subject_Type := Cur_Subject_Type;
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
