--  turtle-parser_states.ads ---

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

with SeA.RDF.Triples;
use SeA.RDF.Triples;
with Turtle.Blank_Node_Labels;
use Turtle.Blank_Node_Labels;
with SeA.Namespaces.Namespaces;
use SeA.Namespaces.Namespaces;

--  The parser state is defined at the RDF 1.1 Turtle W3C standard (see [1]).
--  It defines the needed items for parsing triples from turtle statements.
--
--  [1] https://www.w3.org/TR/turtle/#sec-parsing-state
package Turtle.Parser_States is

    type Parser_State_Type is tagged private;

    function Get_Base_URI (Parser_State : Parser_State_Type)
                          return Universal_String;
    function Get_Namespaces (Parser_State : Parser_State_Type)
                            return Namespaces_Type;
    function Get_Bnode_Labels (Parser_State : Parser_State_Type)
                             return Blank_Node_Labels_Type;
    function Get_Cur_Subject (Parser_State : Parser_State_Type)
                             return Universal_String;
    function Get_Cur_Predicate (Parser_State : Parser_State_Type)
                               return Universal_String;

    procedure Set_Base_URI (Parser_State : in out Parser_State_Type;
                            Base_URI : Universal_String);
    procedure Set_Namespaces (Parser_State : in out Parser_State_Type;
                              Namespaces : Namespaces_Type);
    procedure Set_Bnode_Labels (Parser_State : in out Parser_State_Type;
                               Bnode_Labels : Blank_Node_Labels_Type);
    procedure Set_Cur_Subject (Parser_State : in out Parser_State_Type;
                               Cur_Subject : Universal_String;
                               Cur_Subject_Type : Subject_Type_Type :=
                                 SeA.RDF.Triples.IRI);
    procedure Set_Cur_Predicate (Parser_State : in out Parser_State_Type;
                                 Cur_Predicate : Universal_String);

    procedure Assign_Namespace (Parser_State : in out Parser_State_Type;
                                Prefix, Iri : Universal_String);

    function Substitute_Prefix (Parser_State : in out Parser_State_Type;
                                Pname_Ns : Universal_String)
                               return Universal_String;

    --  Add a blank node to the map.
    --  Blanknode_Value is a Universal_String with the token value
    --  (i.e. "_:LABEL", in RDF 1.1 TR section 3.4 the label is called
    --  Blank node identifier).
    --
    --  According to section 7.2 of the Turtle TR, the key of the BNodeLabels
    --  map is the LABEL string.
    --
    --  This function returns False if the blank node exists already.
    function Add_Blanknode (Parser_State : in out Parser_State_Type;
                            Blanknode_Value : Universal_String)
                           return Boolean;

    --  Register a new blank node label different from the one registered
    --  before and return it. This is used to give a new label to ANON blank
    --  nodes.
    function Get_New_Anon_Value (Parser_State : in out Parser_State_Type)
                                return Universal_String;

    function Is_Base_IRI_Ending_Correctly
      (Parser_State : in out Parser_State_Type)
      return Boolean;

    function Is_Base_IRI_Relative
      (Parser_State : in out Parser_State_Type)
      return Boolean;

    function Is_Base_IRI_Valid
      (Parser_State : in out Parser_State_Type)
      return Boolean;

    --  Return a new RDF triple Triple_Type using the current subject and
    --  current predicate.
    function Get_New_Triple (Parser_State : Parser_State_Type;
                             Object_Value : Universal_String;
                             Object_Type : Object_Type_Type :=
                               SeA.RDF.Triples.IRI)
                            return Triple_Type;

private

    type Parser_State_Type is tagged record
        Base_URI : Universal_String;
        Namespaces : Namespaces_Type;
        Bnode_Labels : Blank_Node_Labels_Type;
        Cur_Subject : Universal_String;
        Cur_Subject_Type : Subject_Type_Type := IRI;
        Cur_Predicate : Universal_String;

        Anon_Number : Natural := 1;
    end record;

end Turtle.Parser_States;
