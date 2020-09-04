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

with Turtle.Blank_Node_Labels;
use Turtle.Blank_Node_Labels;
with Turtle.Namespaces;
use Turtle.Namespaces;

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
    function Get_BnodeLabels (Parser_State : Parser_State_Type)
                             return Blank_Node_Labels_Type;
    function Get_Cur_Subject (Parser_State : Parser_State_Type)
                             return Universal_String;
    function Get_Cur_Predicate (Parser_State : Parser_State_Type)
                               return Universal_String;

    procedure Set_Base_URI (Parser_State : in out Parser_State_Type;
                            Base_URI : Universal_String);
    procedure Set_Namespaces (Parser_State : in out Parser_State_Type;
                              Namespaces : Namespaces_Type);
    procedure Set_BnodeLabels (Parser_State : in out Parser_State_Type;
                               BnodeLabels : Blank_Node_Labels_Type);
    procedure Set_Cur_Subject (Parser_State : in out Parser_State_Type;
                               Cur_Subject : Universal_String);
    procedure Set_Cur_Predicate (Parser_State : in out Parser_State_Type;
                                 Cur_Predicate : Universal_String);

    procedure Assign_Namespace (Parser_State : in out Parser_State_Type;
                                Prefix, Iri : Universal_String);

    function Substitute_Prefix (Parser_State : in out Parser_State_Type;
                                Pname_Ns : Universal_String)
                               return Universal_String;

    function Is_Base_IRI_Ending_Correctly
      (Parser_State : in out Parser_State_Type)
      return Boolean;

    function Is_Base_IRI_Relative
      (Parser_State : in out Parser_State_Type)
      return Boolean;

private

    type Parser_State_Type is tagged record
        Base_URI : Universal_String;
        Namespaces : Namespaces_Type;
        BnodeLabels : Blank_Node_Labels_Type;
        Cur_Subject : Universal_String; --  What type should this be?
        Cur_Predicate : Universal_String; --  What type should this be?
    end record;

end Turtle.Parser_States;
