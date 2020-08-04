--  lexical-symbol_sets.ads ---

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

with Ada.Containers.Ordered_Sets;

--
--  A symbol set represent a set of symbols used by the automata.
--  This package provide the sets used by the automata.
--  The symbol set can be unitary, which only a character is required to
--  initialize it, or non-unitary.
--
--  A symbol can be in its own unitary set, in two set or more. For
--  instance, the symbol "a" can be in its own unitary set, in the Letter
--  set or in the Hexadecimal_Digit set.
--
package Lexical.Symbol_Sets is

    --  The symbol set name if it is not unitary. If it is unitary, the set
    --  name is the character representing the element of the set (thus, it
    --  would not be defined here).
    type Symbol_Set_Name_Type is (Unitary,
                                  WS, Decimal_Digit, Hexadecimal_Digit, Letter,
                                  Pn_Chars, Pn_Char_Base_Without_Tf,
                                  --  Iriref_Chars ::= [^#x00-#x20<>"{}|^`\]
                                  Iriref_Chars,
                                  Dot,
                                  Other,
                                  Invalid);

    --  The unitary or non-unitary symbol set.
    type Symbol_Set_Type is tagged private;

    function "<" (Symbol_A, Symbol_B : Symbol_Set_Type) return Boolean;
    --  Two Symbol_Set_Type are equal if they are:
    --  if unitary, they have the same symbol,
    --  if non-unitary, then they must have the same symbol set name.
    overriding function "=" (Symbol_A, Symbol_B : Symbol_Set_Type)
                            return Boolean;

    Invalid_Symbol_Set : constant Symbol_Set_Type;

    --  Create a unitary symbol.
    procedure Initialize (Symbol_Set : in out Symbol_Set_Type;
                          Symbol : Wide_Wide_Character);

    --  Create a non-unitary symbol.
    procedure Initialize (Symbol_Set : in out Symbol_Set_Type;
                          Set_Name : Symbol_Set_Name_Type);

    function Is_Unitary (Symbol_Set : Symbol_Set_Type) return Boolean;
    function Get_Name (Symbol_Set : Symbol_Set_Type)
                      return Symbol_Set_Name_Type;
    function Get_Symbol (Symbol_Set : Symbol_Set_Type)
                        return Wide_Wide_Character;

    function Symbol_In_Set (Symbol_Set : Symbol_Set_Type;
                            Symbol : Wide_Wide_Character)
                           return Boolean;

    --  A symbol can be in several Symbol_Set_Type instances: "a" can be in
    --  Letter, in Hexadecimal_Digit or in its own Unitary set.
    --
    --  Searching for the Symbol_Set_Type instance of "a" means that a set
    --  of possible names of Symbol_Set_Type.
    --
    --  Therefore, Possible_Symbol_Sets_Type is a set of sets: A set of
    --  Symbol_Set_Type.
    type Possible_Symbol_Sets_Type is tagged private;

    --  Is this Symbol_Set in the Possible_Sets?
    function Symbol_Set_In_Possible_Sets
      (Symbol_Set : Symbol_Set_Type;
       Possible_Sets : Possible_Symbol_Sets_Type'Class)
      return Boolean;

    --  Return the Symbol_Sets where the given Symbol is in.
    --
    --  For example: `Get_Possible_Sets ('a')` returns the following set:
    --    { Letter_Symbol_Set, Hexadecimal_Digit_Symbol_Set,
    --      Unitary_Symbol_Set }
    --  Where Letter_Symbol_Set represents [a..z][A..Z],
    --  Hexadecimal_Digit_Symbol represents [0..9][a..f][A..F] and
    --  Unitary_Symbol_Set is the set { a }
    function Get_Possible_Sets (Symbol : Wide_Wide_Character)
                               return Possible_Symbol_Sets_Type;

    --  Find a Symbol_Set_Type instance inside the given Possible_Sets.
    --  Execute Test_Function on each set and return the instance that this
    --  function returns true.
    function Find_Set (Possible_Sets : Possible_Symbol_Sets_Type;
                       Test_Function : not null access
                         function (Set : Symbol_Set_Type)
                         return Boolean)
                      return Symbol_Set_Type'Class;

    --  Is this Possible_Sets empty?
    function Is_Empty (Possible_Sets : Possible_Symbol_Sets_Type)
                      return Boolean;

private
    --  Tryed an inmutable variant record and it didn't work:
    --  One must declare the discriminant at the variable declaration but
    --  sometimes you don't know which one is! For example, when using
    --  Find_Set: what kind of Symbol_Set_Type would return, a
    --  Symbol_Set_Type (Unitary => True) or a
    --  Symbol_Set_Type (Unitary => False)?
    --  Mutable variant records cannot be tagged and this shouldn't mutate
    --  in execution time.
    type Symbol_Set_Type is tagged record
        Unitary : Boolean;
        Symbol : Wide_Wide_Character;
        Set_Name : Symbol_Set_Name_Type;
    end record;

    Invalid_Symbol_Set : constant Symbol_Set_Type :=
      (Unitary => False,
       Symbol => ' ',
       Set_Name => Invalid);

    package Group_Sets is new Ada.Containers.Ordered_Sets
      (Element_Type => Symbol_Set_Type,
       "<" => "<",
       "=" => "=");

    type Possible_Symbol_Sets_Type is tagged record
        Set : Group_Sets.Set;
    end record;

end Lexical.Symbol_Sets;
