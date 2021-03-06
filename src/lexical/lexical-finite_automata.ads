--  lexical-finite_automata.ads ---

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
with Ada.Containers.Ordered_Maps;
with Lexical.Symbol_Sets;
use Lexical.Symbol_Sets;

--  A finite deterministic automata implementation for the turtle lexical
--  analyzer.
--
--  Blocking state
--  ---------------
--
--  The state-transition function have its (State, Symbol) defined to a
--  blocking state by default. It is a non-final (non-acceptance) state
--  that change to itself when any character is readed.
--
--  This default mapping is changed when Add_Delta is executed.
--
--  Symbol grouping and state-transition function
--  -------------------------------------------------
--
--  The state-transition function is implemented as follows :
--  (State_Type, Wide_Wide_Character) -> State_Type.
--
--  Symbols groups are represented as a Wide_Wide_Characters. Those that are
--  not defined as part of a symbol group, is considered as a symbol group
--  itself.
--  For example : [a-zA-Z] is represented as 'a', [0-9] as '0'. The symbol '>'
--  is not part of any group, then it is represented as '>'.
--
--  The state-transition map (Start, 'a') -> Letter means the following :
--  Given the automata in the Start state, and reads a letter part of the group
--  'a' (i.e. the letter is in [a-zA-Z]), then change the state into Letter.
--
--  *Warning :* A symbol could be part of two groups : the symbol 'a' could be
--  in [a-zA-Z] group called 'a'-group and [0-9a-fA-F] group called 'x'-group
--  (hexadecimal digits). In this case, there should not be a mapping with
--  both group labels as the Wide_Wide_Character parameter. For example :
--  (Start, 'a') -> Letter and (Start, 'x') -> Hexadecimal_Number should not be
--  part of the state-transition function.
--  If this happens, then the automata would not be deterministic because
--  there are more than one transition poth for the same symbol.
--  Therefore, the first rule is applied and the second ignored when any
--  symbol for [a-fA-F] is red (not when [0-9] symbols are red unless there
--  are other rules before these).
package Lexical.Finite_Automata is
    --  The possible states of the automata.
    type State_Type is
      (
       Start,
       Arroba, I_Langtag, Langtag1, E_Langtag,
       WS,
       Dot, Comma, Semicolon,
       Pname_Ns, Pn_Prefix, Pn_Prefix1,
       Pname_Ln, Pn_Local1,
       I_Percent,
       I_Pn_Local_Esc,
       Hex1,
       Under, Comment, Bracket_Open, Bracket_Close, Anon, Symbol,
       I_Blank_Node_Label, Blank_Node_Label, Blank_Node_Label1,
       Sign, Ie_Integer, E_Decimal, E_Decimal2, I_Decimal, I_Decimal2,
       Exponent, Exponent1, Ex_Digit,
       I_Iriref, E_Iriref,
       Invalid_State, Blocked,

       --  Doublequoted string states
       Doublequote, I_String_Literal_Quote, Slq_Backslash,
       E_String_Literal_Quote1, E_String_Literal_Quote,
       I_Sllq, Sllq_Quote, Sllq_Backslash, Sllq_Quote2,
       E_Sllq, Sllq_Echar,

       --  Singlequoted string states
       Singlequote, I_String_Literal_Single_Quote, Slsq_Backslash,
       E_String_Literal_Single_Quote1, E_String_Literal_Single_Quote,
       I_Sllsq, Sllsq_Quote, Sllsq_Backslash, Sllsq_Quote2,
       Sllsq_Echar, E_Sllsq,

       --  UCHARs
       Uchar, Uchar_End, Uchar1a, Uchar1b, Uchar1c, Uchar1d,
       Uchar2a, Uchar2b, Uchar2c, Uchar2d, Uchar2e, Uchar2f, Uchar2g, Uchar2h,

       Slq_Uchar, Slq_Echar, Slq_E_Uchar, Sllq_E_Uchar,
       Slq_Uchar1b, Slq_Uchar1c, Slq_Uchar1d,
       Slq_Uchar2a, Slq_Uchar2b, Slq_Uchar2c, Slq_Uchar2d, Slq_Uchar2e,
       Slq_Uchar2f, Slq_Uchar2g, Slq_Uchar2h,

       Sllq_Uchar,
       Sllq_Uchar1b, Sllq_Uchar1c, Sllq_Uchar1d,
       Sllq_Uchar2a, Sllq_Uchar2b, Sllq_Uchar2c, Sllq_Uchar2d, Sllq_Uchar2e,
       Sllq_Uchar2f, Sllq_Uchar2g, Sllq_Uchar2h,

       Slsq_Uchar, Slsq_Echar, Slsq_E_Uchar, Sllsq_E_Uchar,
       Slsq_Uchar1b, Slsq_Uchar1c, Slsq_Uchar1d,
       Slsq_Uchar2a, Slsq_Uchar2b, Slsq_Uchar2c, Slsq_Uchar2d, Slsq_Uchar2e,
       Slsq_Uchar2f, Slsq_Uchar2g, Slsq_Uchar2h,

       Sllsq_Uchar,
       Sllsq_Uchar1b, Sllsq_Uchar1c, Sllsq_Uchar1d,
       Sllsq_Uchar2a, Sllsq_Uchar2b, Sllsq_Uchar2c, Sllsq_Uchar2d,
       Sllsq_Uchar2e, Sllsq_Uchar2f, Sllsq_Uchar2g, Sllsq_Uchar2h,

       --  BASE and PREFIX declarations
       Base_Declaration, Base_Declaration1, Base_Declaration2,
       Base_Declaration3,
       Prefix_Declaration, Prefix_Declaration1, Prefix_Declaration2,
       Prefix_Declaration3, Prefix_Declaration4, Prefix_Declaration5,

       --  "true" and "false" boolean literals
       Boolean_Tf, Booleant1, Booleant2, Booleant3,
       Booleanf1, Booleanf2, Booleanf3, Booleanf4
      );

    function Is_Final_State (State : State_Type) return Boolean;

    type Automata_Type is tagged private;

    --  Initialize the automata.
    --
    --  Fill the state-transition funcition. Do a reset.
    procedure Initialize (Automata : in out Automata_Type);

    --  Restart the automata.
    --
    --  Set Start as the current state.
    procedure Reset (Automata : in out Automata_Type);

    --  Step to the next state.
    procedure Next (Automata : in out Automata_Type;
                    Symbol : Wide_Wide_Character);

    --  Move one preious state.
    --
    --  The automata can save up to one state before. Therefore, one call to
    --  this procedure is allowed. More than one will change to the same state.
    procedure Previous_State (Automata : in out Automata_Type);

    --  What is the current state of the automata?
    function Get_Current_State (Automata : Automata_Type) return State_Type;

    --  Has the automata accepted the entry?
    function Is_Accepted (Automata : Automata_Type) return Boolean;

    --  Has the automata been blocked?
    --
    --  A blocked automata is an automata in a non-final state in which with
    --  any entry it will change into the same non-filan state.
    function Is_Blocked (Automata : Automata_Type) return Boolean;

    procedure Walk_Function
      (Test_Procedure : not null access
         procedure (From_State : State_Type; Symbol : Symbol_Set_Type;
                    To_State : State_Type));
private

    --  This is the set of final or acceptable states.
    package State_Set is new Ada.Containers.Ordered_Sets
      (Element_Type => State_Type);

    Acceptable_States : State_Set.Set;

    --  The state-transition function delta (S, E) -> S is represented as
    --  an ordered map between a Domain_Tuple_Type -> State.
    --  In other words : a (S, E) tuple is represented as a Domain_Tuple_Type
    --  instance.
    type Domain_Tuple_Type is record
        Current_State : State_Type;
        Symbols : Symbol_Set_Type;
    end record;

    --  The ordered map requires an order specified.
    function "<" (Tuple_A : Domain_Tuple_Type;
                  Tuple_B : Domain_Tuple_Type) return Boolean;
    overriding function "=" (Tuple_A, Tuple_B : Domain_Tuple_Type)
                 return Boolean;

    Invalid_Domain_Tuple : constant Domain_Tuple_Type :=
      (
       Current_State => Invalid_State,
       Symbols => Invalid_Symbol_Set
      );

    --  The transition function type.
    package Transition_Pack is new Ada.Containers.Ordered_Maps
      (
       Key_Type => Domain_Tuple_Type,
       Element_Type => State_Type
      );

    --  The state-transition function. Usually associated with a delta symbol.
    --  This function is the same for all the finite automatas created by this
    --  package.
    Transition_Function : Transition_Pack.Map;

    type Automata_Type is tagged record
        --  The current state of the automata.
        Current_State : State_Type;
        Previous_State : State_Type;
    end record;

    --  Add a (state, symbol_set) -> next_state association to the
    --  transition_function.
    procedure Add_Delta (Current_State : State_Type;
                         Symbol : Wide_Wide_Character;
                         Next_State : State_Type);
    procedure Add_Delta (Current_State : State_Type;
                         Set_Name : Symbol_Set_Name_Type;
                         Next_State : State_Type);

    --  A set of symbols are grouped and labelled. For instance, symbols
    --  from 'a' to 'z' are grouped into the label 'a'. This helps to create
    --  the transition function of the automata : (I_Iriref, 'a') -> (I_Iriref)
    --  means that if the automata is in I_Iriref state and reads any symbol
    --  from 'a' to 'z', then change the state into I_Iriref.
    --
    --  Reduce_Symbol maps the symbol to the group label used in the
    --  transition function.
    --  One symbol can be in more than one group, this means that the return
    --  value is a string with more than one possible group label.
    --
    --  Recall that the automata is a finite deterministic one. For this
    --  reason, there should not be one symbol and state associated with
    --  multiple resulting states. If there is such sitation, only the
    --  first association is used.

    --  Get the transition that correspond to the current state and the symbol.
    --  The symbol provided is not the symbol group.
    --  This transition is (State, Symbol) tuple that is in the domain of the
    --  state-transition function of the automata and is mapped to a state
    --  different from the blocked one.
    --
    --  Return an Invalid_Transition if the (state, symbol) is not mapped
    --  which it means that the automata is blocked.
    function Get_Domain_Tuple (State : State_Type;
                               Symbol : Wide_Wide_Character)
                              return Domain_Tuple_Type;
end Lexical.Finite_Automata;
