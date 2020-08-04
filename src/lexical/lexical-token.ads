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
    type Token_Class is (Iriref, Pname_Ns, Pname_Ln,
                         String_Lsq, String_Lq, String, Llsq, String_Llq,
                         Langtag, Rdf_Literal,
                         Integer, Decimal, Double,
                         Boolean_Literal,
                         Blank_Node_Label,
                         Anon,
                         Blank_Node_Property_List,
                         Collection,
                         WS,
                         Reserved_Word,
                         Invalid);

    type Token_Type is tagged private;

    procedure Initialize (Token : in out Token_Type;
                          Class : Token_Class;
                          Value : Universal_String);
    procedure Initialize (Token : in out Token_Type;
                          Class : State_Type;
                          Value : Universal_String);

    function Get_Class (Token : Token_Type) return Token_Class;
    function Get_Value (Token : Token_Type) return Universal_String;

    function State_To_Token (State : State_Type) return Token_Class;

    Invalid_Token : constant Token_Type;

private

    type Token_Type is tagged record
        Class : Token_Class;
        Value : Universal_String;
    end record;

    Invalid_Token : constant Token_Type :=
      (
       Class => Invalid,
       Value => Empty_Universal_String
      );

end Lexical.Token;
