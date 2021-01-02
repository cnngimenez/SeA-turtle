--  lexical-token.ads ---

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
with Lexical.Finite_Automata;
use Lexical.Finite_Automata;

package Lexical.Token is
    type Token_Class_Type is
      (IRI_Reference,
       Prefix_Namespace, Prefix_With_Local,
       String_Literal_Quote,
       String_Literal_Long_Quote,
       String_Literal_Single_Quote,
       String_Literal_Long_Single_Quote,
       Language_Tag, Rdf_Literal,
       Integer, Decimal, Double,
       Boolean_Literal,
       Blank_Node_Label,
       Anon,
       Blank_Node_Property_List,
       Collection,
       Comment,
       Whitespace,
       Reserved_Word,
       --  Not mapped state: a final state without a
       --  Token name
       Not_Mapped,
       --  Not a valid state (non-final state).
       Invalid);

    type Token_Type is tagged private;

    procedure Initialize (Token : in out Token_Type;
                          Class : Token_Class_Type;
                          Value : Universal_String);
    procedure Initialize (Token : in out Token_Type;
                          Class : State_Type;
                          Value : Universal_String);

    function Get_Class (Token : Token_Type) return Token_Class_Type;
    function Get_Value (Token : Token_Type) return Universal_String;

    function State_To_Token (State : State_Type) return Token_Class_Type;

    Invalid_Token : constant Token_Type;

private

    type Token_Type is tagged record
        Class : Token_Class_Type;
        Value : Universal_String;
    end record;

    Invalid_Token : constant Token_Type :=
      (
       Class => Invalid,
       Value => Empty_Universal_String
      );

end Lexical.Token;
