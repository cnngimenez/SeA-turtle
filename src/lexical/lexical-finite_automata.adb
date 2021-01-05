--  lexical-finite_automata.adb ---
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

package body Lexical.Finite_Automata is

    function "<" (Tuple_A : Domain_Tuple_Type;
                  Tuple_B : Domain_Tuple_Type) return Boolean is
    begin
        if Tuple_A.Current_State = Tuple_B.Current_State then
            return Tuple_A.Symbols < Tuple_B.Symbols;
        else
            return Tuple_A.Current_State < Tuple_B.Current_State;
        end if;
    end "<";

    overriding function "=" (Tuple_A, Tuple_B : Domain_Tuple_Type)
                            return Boolean is
    begin
        return Tuple_A.Current_State = Tuple_B.Current_State
          and then Tuple_A.Symbols = Tuple_B.Symbols;
    end "=";

    procedure Add_Delta (Current_State : State_Type;
                         Symbol : Wide_Wide_Character;
                         Next_State : State_Type) is
        Domain_Tuple : Domain_Tuple_Type;
        Set : Symbol_Set_Type;
    begin
        Set.Initialize (Symbol);
        Domain_Tuple.Current_State := Current_State;
        Domain_Tuple.Symbols := Set;
        Transition_Function.Insert (Domain_Tuple, Next_State);
    end Add_Delta;

    procedure Add_Delta (Current_State : State_Type;
                         Set_Name : Symbol_Set_Name_Type;
                         Next_State : State_Type) is
        Domain_Tuple : Domain_Tuple_Type;
        Set : Symbol_Set_Type;
    begin
        Set.Initialize (Set_Name);
        Domain_Tuple.Current_State := Current_State;
        Domain_Tuple.Symbols := Set;
        Transition_Function.Insert (Domain_Tuple, Next_State);
    end Add_Delta;

    function Get_Current_State (Automata : Automata_Type) return State_Type is
    begin
        return Automata.Current_State;
    end Get_Current_State;

    function Get_Domain_Tuple (State : State_Type;
                               Symbol : Wide_Wide_Character)
                              return Domain_Tuple_Type is

        --  Test if the given group with the current state is in the domain
        --  of the state-transition function.
        --
        --  Set is a symbol group where the Symbol is in.
        function Test_Set (Symbol_Set : Symbol_Set_Type) return Boolean;

        function Test_Set (Symbol_Set : Symbol_Set_Type) return Boolean is
            Tuple : Domain_Tuple_Type;

            --  --  This is a debugging contain function... Do not use!
            --  function Contains (Tuple : Domain_Tuple_Type) return Boolean is
            --      Founded : Boolean := False;
            --      Index : Transition_Pack.Cursor;
            --      use Transition_Pack;
            --  begin
            --      if Transition_Function.Is_Empty then
            --          return False;
            --      end if;

            --      Index := Transition_Function.First;
            --      Founded := Tuple = Key (Index);
            --      while not Founded and then
            --        Index /= Transition_Function.Last loop
            --          Next (Index);
            --          Founded := Tuple = Key (Index);
            --      end loop;

            --      return Founded;
            --  end Contains;

        begin
            Tuple.Current_State := State;
            Tuple.Symbols := Symbol_Set;
            return Transition_Function.Contains (Tuple);
            --  return Contains (Tuple);
        end Test_Set;

        Possible_Sets : constant Possible_Symbol_Sets_Type :=
          Get_Possible_Sets (Symbol);
        Symbol_Set : Symbol_Set_Type;
        Return_Domain_Tuple : Domain_Tuple_Type;
    begin
        if Possible_Sets.Is_Empty then
            --  It couldn't find any possible groups, this means that there's
            --  no mapping on this symbol or just a problem in the programming.
            return Invalid_Domain_Tuple;
        end if;

        --  Search for the tuple (State, Symbol_Set_Type) that is associated
        --  to the given symbol and the current state, and it is in the domain
        --  of the Transition_Function.
        Symbol_Set :=
          Symbol_Set_Type (Possible_Sets.Find_Set (Test_Set'Access));

        if Symbol_Set = Invalid_Symbol_Set then
            --  It searched all the transitions and found no other than
            --  (State, Symbol_Set_Type) -> Blocked associations.
            return Invalid_Domain_Tuple;
        else
            Return_Domain_Tuple.Current_State := State;
            Return_Domain_Tuple.Symbols := Symbol_Set;
            return Return_Domain_Tuple;
        end if;
    end Get_Domain_Tuple;

    procedure Initialize (Automata : in out Automata_Type) is
    begin
        Automata.Current_State := Start;
        Automata.Previous_State := Start;
    end Initialize;

    function Is_Accepted (Automata : Automata_Type) return Boolean is
    begin
        return Acceptable_States.Contains (Automata.Current_State);
    end Is_Accepted;

    function Is_Blocked (Automata : Automata_Type) return Boolean is
    begin
        return Automata.Current_State = Blocked;
    end Is_Blocked;

    function Is_Final_State (State : State_Type) return Boolean is
    begin
        return Acceptable_States.Contains (State);
    end Is_Final_State;

    procedure Next (Automata : in out Automata_Type;
                    Symbol : Wide_Wide_Character) is
        Domain_Tuple : Domain_Tuple_Type;
    begin
        if Automata.Current_State = Blocked then
            return;
        end if;

        Domain_Tuple := Get_Domain_Tuple (Automata.Current_State, Symbol);

        Automata.Previous_State := Automata.Current_State;
        if Domain_Tuple /= Invalid_Domain_Tuple then
            Automata.Current_State := Transition_Function.Element
              (Domain_Tuple);
        else
            Automata.Current_State := Blocked;
        end if;
    end Next;

    procedure Previous_State (Automata : in out Automata_Type) is
    begin
        Automata.Current_State := Automata.Previous_State;
    end Previous_State;

    procedure Reset (Automata : in out Automata_Type) is
    begin
        Automata.Current_State := Start;
        Automata.Previous_State := Start;
    end Reset;

    procedure Walk_Function
      (Test_Procedure : not null access
         procedure (From_State : State_Type; Symbol : Symbol_Set_Type;
                    To_State : State_Type)) is

        Tuple : Domain_Tuple_Type;
        To_State : State_Type;
        Index : Transition_Pack.Cursor;
        use Transition_Pack;
    begin
        if Transition_Function.Is_Empty then
            return;
        end if;

        Index := Transition_Function.First;
        Tuple := Key (Index);
        To_State := Element (Index);
        Test_Procedure (Tuple.Current_State, Tuple.Symbols, To_State);

        while Index /= Transition_Function.Last loop
            Next (Index);
            Tuple := Key (Index);
            To_State := Element (Index);
            Test_Procedure (Tuple.Current_State, Tuple.Symbols, To_State);
        end loop;
    end Walk_Function;

begin
    Acceptable_States.Insert (E_Iriref);
    Acceptable_States.Insert (E_Langtag);
    Acceptable_States.Insert (I_Langtag);
    Acceptable_States.Insert (Ie_Integer);
    Acceptable_States.Insert (E_Decimal);
    Acceptable_States.Insert (E_Decimal2);
    Acceptable_States.Insert (Ex_Digit);
    Acceptable_States.Insert (Pname_Ns);
    Acceptable_States.Insert (Pname_Ln);
    Acceptable_States.Insert (Anon);
    Acceptable_States.Insert (Blank_Node_Label);
    Acceptable_States.Insert (Comment);
    Acceptable_States.Insert (Dot);
    Acceptable_States.Insert (Comma);
    Acceptable_States.Insert (Semicolon);
    Acceptable_States.Insert (Bracket_Open);
    Acceptable_States.Insert (Bracket_Close);
    Acceptable_States.Insert (Symbol);
    Acceptable_States.Insert (I_Percent);
    Acceptable_States.Insert (I_Pn_Local_Esc);
    Acceptable_States.Insert (WS);
    Acceptable_States.Insert (E_String_Literal_Quote);
    Acceptable_States.Insert (E_String_Literal_Quote1);
    Acceptable_States.Insert (E_Sllq);
    Acceptable_States.Insert (E_String_Literal_Single_Quote);
    Acceptable_States.Insert (E_String_Literal_Single_Quote1);
    Acceptable_States.Insert (E_Sllsq);
    Acceptable_States.Insert (Base_Declaration);
    Acceptable_States.Insert (Prefix_Declaration);

    Add_Delta (Start, '@', Arroba);
    Add_Delta (Start, '<', I_Iriref);
    Add_Delta (Start, WS, WS);
    Add_Delta (Start, Dot, Dot);
    Add_Delta (Start, ',', Comma);
    Add_Delta (Start, ';', Semicolon);
    Add_Delta (Start, ':', Pname_Ns);
    Add_Delta (Start, Pn_Char_Base_Without_Tfbp, Pn_Prefix);
    Add_Delta (Start, 'B', Base_Declaration1);
    Add_Delta (Start, 'b', Base_Declaration1);
    Add_Delta (Start, 'P', Prefix_Declaration1);
    Add_Delta (Start, 'p', Prefix_Declaration1);
    Add_Delta (Start, '_', Under);
    Add_Delta (Start, '#', Comment);
    Add_Delta (Start, '[', Bracket_Open);
    Add_Delta (Start, ']', Bracket_Close);
    Add_Delta (Start, '+', Sign);
    Add_Delta (Start, '-', Sign);
    Add_Delta (Start, Decimal_Digit, Ie_Integer);
    Add_Delta (Start, ''', Singlequote);
    Add_Delta (Start, '"', Doublequote);

    Add_Delta (Arroba, Letter, I_Langtag);

    Add_Delta (I_Langtag, Letter, I_Langtag);
    Add_Delta (I_Langtag, '-', Langtag1);

    Add_Delta (Langtag1, Letter, E_Langtag);
    Add_Delta (Langtag1, Decimal_Digit, E_Langtag);

    Add_Delta (E_Langtag, '-', Langtag1);

    Add_Delta (I_Iriref, Iriref_Chars, I_Iriref);
    Add_Delta (I_Iriref, '>', E_Iriref);
    Add_Delta (I_Iriref, '\', Uchar);

    Add_Delta (Uchar_End, Iriref_Chars, I_Iriref);
    Add_Delta (Uchar_End, '>', E_Iriref);

    Add_Delta (Uchar, 'u', Uchar1a);
    Add_Delta (Uchar, 'U', Uchar2a);

    Add_Delta (Uchar1a, Hexadecimal_Digit, Uchar1b);
    Add_Delta (Uchar1b, Hexadecimal_Digit, Uchar1c);
    Add_Delta (Uchar1c, Hexadecimal_Digit, Uchar1d);
    Add_Delta (Uchar1d, Hexadecimal_Digit, Uchar_End);

    Add_Delta (Uchar2a, Hexadecimal_Digit, Uchar2b);
    Add_Delta (Uchar2b, Hexadecimal_Digit, Uchar2c);
    Add_Delta (Uchar2c, Hexadecimal_Digit, Uchar2d);
    Add_Delta (Uchar2d, Hexadecimal_Digit, Uchar2e);
    Add_Delta (Uchar2e, Hexadecimal_Digit, Uchar2f);
    Add_Delta (Uchar2f, Hexadecimal_Digit, Uchar2g);
    Add_Delta (Uchar2g, Hexadecimal_Digit, Uchar2h);
    Add_Delta (Uchar2h, Hexadecimal_Digit, Uchar_End);

    Add_Delta (WS, WS, WS);

    Add_Delta (Dot, Decimal_Digit, E_Decimal2);

    --  Prefixes namespaces and local namespaces
    Add_Delta (Pn_Prefix, Pn_Chars, Pn_Prefix);
    Add_Delta (Pn_Prefix, ':', Pname_Ns);
    Add_Delta (Pn_Prefix, '.', Pn_Prefix1);

    Add_Delta (Pn_Prefix1, Pn_Chars, Pn_Prefix);

    Add_Delta (Pname_Ns, Pn_Chars_U, Pname_Ln);
    Add_Delta (Pname_Ns, ':', Pname_Ln);
    Add_Delta (Pname_Ns, Decimal_Digit, Pname_Ln);
    Add_Delta (Pname_Ns, '%', I_Percent);
    Add_Delta (Pname_Ns, '\', I_Pn_Local_Esc);

    Add_Delta (Pname_Ln, Pn_Chars, Pname_Ln);
    Add_Delta (Pname_Ln, ':', Pname_Ln);
    Add_Delta (Pname_Ln, '.', Pn_Local1);
    Add_Delta (Pname_Ln, '%', I_Percent);
    Add_Delta (Pname_Ln, '\', I_Pn_Local_Esc);

    Add_Delta (Pn_Local1, Pn_Chars, Pname_Ln);
    Add_Delta (Pn_Local1, ':', Pname_Ln);
    Add_Delta (Pn_Local1, '%', I_Percent);
    Add_Delta (Pn_Local1, '\', I_Pn_Local_Esc);

    Add_Delta (I_Pn_Local_Esc, Pn_Local_Esc, Pname_Ln);

    Add_Delta (I_Percent, Hexadecimal_Digit, Hex1);

    Add_Delta (Hex1, Hexadecimal_Digit, Pname_Ln);

    --  Blank nodes
    Add_Delta (Under, ':', I_Blank_Node_Label);
    Add_Delta (Under, Pn_Chars, Pn_Prefix);

    Add_Delta (I_Blank_Node_Label, Pn_Chars_U, Blank_Node_Label);
    Add_Delta (I_Blank_Node_Label, Decimal_Digit, Blank_Node_Label);

    Add_Delta (Blank_Node_Label, Pn_Chars, Blank_Node_Label);
    Add_Delta (Blank_Node_Label, '.', Blank_Node_Label1);

    Add_Delta (Blank_Node_Label1, Pn_Chars, Blank_Node_Label);

    --  Comments

    Add_Delta (Comment, Comment_Chars, Comment);

    --  Anon
    Add_Delta (Bracket_Open, WS, Bracket_Open);
    Add_Delta (Bracket_Open, ']', Anon);

    --  Numbers

    Add_Delta (Sign, Decimal_Digit, Ie_Integer);
    Add_Delta (Sign, '.', I_Decimal2);

    Add_Delta (Ie_Integer, Decimal_Digit, Ie_Integer);
    Add_Delta (Ie_Integer, '.', I_Decimal);
    Add_Delta (Ie_Integer, 'e', Exponent);
    Add_Delta (Ie_Integer, 'E', Exponent);

    Add_Delta (I_Decimal, Decimal_Digit, E_Decimal);
    Add_Delta (I_Decimal, 'e', Exponent);
    Add_Delta (I_Decimal, 'E', Exponent);

    Add_Delta (E_Decimal, Decimal_Digit, E_Decimal);
    Add_Delta (E_Decimal, 'e', Exponent);
    Add_Delta (E_Decimal, 'E', Exponent);

    Add_Delta (I_Decimal2, Decimal_Digit, E_Decimal2);

    Add_Delta (E_Decimal2, Decimal_Digit, E_Decimal2);
    Add_Delta (E_Decimal2, 'e', Exponent);
    Add_Delta (E_Decimal2, 'E', Exponent);

    Add_Delta (Exponent, Decimal_Digit, Ex_Digit);
    Add_Delta (Exponent, '+', Exponent1);
    Add_Delta (Exponent, '-', Exponent1);

    Add_Delta (Exponent1, Decimal_Digit, Ex_Digit);

    Add_Delta (Ex_Digit, Decimal_Digit, Ex_Digit);

    --  Doublequoted String
    --
    Add_Delta (Doublequote, Non_SLQ_Chars, I_String_Literal_Quote);
    Add_Delta (Doublequote, '\', Slq_Backslash);
    Add_Delta (Doublequote, '"', E_String_Literal_Quote1);

    Add_Delta (I_String_Literal_Quote, Non_SLQ_Chars, I_String_Literal_Quote);
    Add_Delta (I_String_Literal_Quote, '"', E_String_Literal_Quote);

    Add_Delta (Slq_Backslash, 'u', Slq_Uchar);
    Add_Delta (Slq_Backslash, ECHAR_Chars, Slq_Echar);

    Add_Delta (Slq_Echar, Non_SLQ_Chars, I_String_Literal_Quote);
    Add_Delta (Slq_Echar, '"', E_String_Literal_Quote);
    Add_Delta (Slq_Echar, '\', Slq_Backslash);

    Add_Delta (Slq_E_Uchar, Non_SLQ_Chars, I_String_Literal_Quote);
    Add_Delta (Slq_E_Uchar, '"', E_String_Literal_Quote);
    Add_Delta (Slq_E_Uchar, '\', Slq_Backslash);

    Add_Delta (E_String_Literal_Quote1, '"', I_Sllq);

    --  Non_Isllq_Chars ::= [^"\]
    Add_Delta (I_Sllq, Non_Isllq_Chars, I_Sllq);
    Add_Delta (I_Sllq, '"', Sllq_Quote);
    Add_Delta (I_Sllq, '\', Sllq_Backslash);

    Add_Delta (Sllq_Quote, Non_Isllq_Chars, I_Sllq);
    Add_Delta (Sllq_Quote, '"', Sllq_Quote2);
    Add_Delta (Sllq_Quote, '\', Sllq_Backslash);

    Add_Delta (Sllq_Quote2, Non_Isllq_Chars, I_Sllq);
    Add_Delta (Sllq_Quote2, '"', E_Sllq);
    Add_Delta (Sllq_Quote2, '\', Sllq_Backslash);

    Add_Delta (Sllq_Backslash, ECHAR_Chars, Sllq_Echar);
    Add_Delta (Sllq_Backslash, 'u', Sllq_Uchar);

    Add_Delta (Sllq_E_Uchar, '\', Sllq_Backslash);
    Add_Delta (Sllq_E_Uchar, '"', Sllq_Quote);
    Add_Delta (Sllq_E_Uchar, Non_Isllq_Chars, I_Sllq);

    Add_Delta (Sllq_Echar, '\', Sllq_Backslash);
    Add_Delta (Sllq_Echar, '"', Sllq_Quote);
    Add_Delta (Sllq_Echar, Non_Isllq_Chars, I_Sllq);

    Add_Delta (Slq_Uchar, Hexadecimal_Digit, Slq_Uchar1b);
    Add_Delta (Slq_Uchar1b, Hexadecimal_Digit, Slq_Uchar1c);
    Add_Delta (Slq_Uchar1c, Hexadecimal_Digit, Slq_Uchar1d);
    Add_Delta (Slq_Uchar1d, Hexadecimal_Digit, Slq_E_Uchar);

    Add_Delta (Sllq_Uchar, Hexadecimal_Digit, Sllq_Uchar1b);
    Add_Delta (Sllq_Uchar1b, Hexadecimal_Digit, Sllq_Uchar1c);
    Add_Delta (Sllq_Uchar1c, Hexadecimal_Digit, Sllq_Uchar1d);
    Add_Delta (Sllq_Uchar1d, Hexadecimal_Digit, Sllq_E_Uchar);

    --  Singlequoted strings
    --
    Add_Delta (Singlequote, Non_SLSQ_Chars, I_String_Literal_Single_Quote);
    Add_Delta (Singlequote, '\', Slsq_Backslash);
    Add_Delta (Singlequote, ''', E_String_Literal_Single_Quote1);

    Add_Delta (I_String_Literal_Single_Quote, Non_SLSQ_Chars,
               I_String_Literal_Single_Quote);
    Add_Delta (I_String_Literal_Single_Quote, ''',
               E_String_Literal_Single_Quote);

    Add_Delta (Slsq_Backslash, 'u', Slq_Uchar);
    Add_Delta (Slsq_Backslash, ECHAR_Chars, Slsq_Echar);

    Add_Delta (Slsq_Echar, Non_SLSQ_Chars, I_String_Literal_Single_Quote);
    Add_Delta (Slsq_Echar, ''', E_String_Literal_Single_Quote);
    Add_Delta (Slsq_Echar, '\', Slsq_Backslash);

    Add_Delta (Slsq_E_Uchar, Non_SLSQ_Chars, I_String_Literal_Single_Quote);
    Add_Delta (Slsq_E_Uchar, ''', E_String_Literal_Single_Quote);
    Add_Delta (Slsq_E_Uchar, '\', Slsq_Backslash);

    Add_Delta (E_String_Literal_Single_Quote1, ''', I_Sllsq);

    --  Non_Isllsq_Chars ::= [^"\]
    Add_Delta (I_Sllsq, Non_Isllsq_Chars, I_Sllsq);
    Add_Delta (I_Sllsq, ''', Sllsq_Quote);
    Add_Delta (I_Sllsq, '\', Sllsq_Backslash);

    Add_Delta (Sllsq_Quote, Non_Isllsq_Chars, I_Sllsq);
    Add_Delta (Sllsq_Quote, ''', Sllsq_Quote2);
    Add_Delta (Sllsq_Quote, '\', Sllsq_Backslash);

    Add_Delta (Sllsq_Quote2, Non_Isllsq_Chars, I_Sllsq);
    Add_Delta (Sllsq_Quote2, ''', E_Sllsq);
    Add_Delta (Sllsq_Quote2, '\', Sllsq_Backslash);

    Add_Delta (Sllsq_Backslash, ECHAR_Chars, Sllsq_Echar);
    Add_Delta (Sllsq_Backslash, 'u', Sllsq_Uchar);

    Add_Delta (Sllsq_E_Uchar, '\', Sllsq_Backslash);
    Add_Delta (Sllsq_E_Uchar, ''', Sllsq_Quote);
    Add_Delta (Sllsq_E_Uchar, Non_Isllsq_Chars, I_Sllsq);

    Add_Delta (Sllsq_Echar, '\', Sllsq_Backslash);
    Add_Delta (Sllsq_Echar, ''', Sllsq_Quote);
    Add_Delta (Sllsq_Echar, Non_Isllsq_Chars, I_Sllsq);

    Add_Delta (Slsq_Uchar, Hexadecimal_Digit, Slsq_Uchar1b);
    Add_Delta (Slsq_Uchar1b, Hexadecimal_Digit, Slsq_Uchar1c);
    Add_Delta (Slsq_Uchar1c, Hexadecimal_Digit, Slsq_Uchar1d);
    Add_Delta (Slsq_Uchar1d, Hexadecimal_Digit, Slsq_E_Uchar);

    Add_Delta (Sllsq_Uchar, Hexadecimal_Digit, Sllsq_Uchar1b);
    Add_Delta (Sllsq_Uchar1b, Hexadecimal_Digit, Sllsq_Uchar1c);
    Add_Delta (Sllsq_Uchar1c, Hexadecimal_Digit, Sllsq_Uchar1d);
    Add_Delta (Sllsq_Uchar1d, Hexadecimal_Digit, Sllsq_E_Uchar);

    Add_Delta (Base_Declaration1, 'a', Base_Declaration2);
    Add_Delta (Base_Declaration1, 'A', Base_Declaration2);
    Add_Delta (Base_Declaration1, '.', Pn_Prefix1);
    Add_Delta (Base_Declaration1, ':', Pname_Ns);
    Add_Delta (Base_Declaration1, Pn_Char_Base_Without_Aa, Pn_Prefix);

    Add_Delta (Base_Declaration2, 's', Base_Declaration3);
    Add_Delta (Base_Declaration2, 'S', Base_Declaration3);
    Add_Delta (Base_Declaration2, '.', Pn_Prefix1);
    Add_Delta (Base_Declaration2, ':', Pname_Ns);
    Add_Delta (Base_Declaration2, Pn_Char_Base_Without_Ss, Pn_Prefix);

    Add_Delta (Base_Declaration3, 'e', Base_Declaration);
    Add_Delta (Base_Declaration3, 'E', Base_Declaration);
    Add_Delta (Base_Declaration3, '.', Pn_Prefix1);
    Add_Delta (Base_Declaration3, ':', Pname_Ns);
    Add_Delta (Base_Declaration3, Pn_Char_Base_Without_Ee, Pn_Prefix);

    Add_Delta (Base_Declaration, '.', Pn_Prefix1);
    Add_Delta (Base_Declaration, ':', Pname_Ns);
    Add_Delta (Base_Declaration, Pn_Chars, Pn_Prefix);

    Add_Delta (Prefix_Declaration1, 'r', Prefix_Declaration2);
    Add_Delta (Prefix_Declaration1, 'R', Prefix_Declaration2);
    Add_Delta (Prefix_Declaration1, '.', Pn_Prefix1);
    Add_Delta (Prefix_Declaration1, ':', Pname_Ns);
    Add_Delta (Prefix_Declaration1, Pn_Char_Base_Without_Rr, Pn_Prefix);

    Add_Delta (Prefix_Declaration2, 'e', Prefix_Declaration3);
    Add_Delta (Prefix_Declaration2, 'E', Prefix_Declaration3);
    Add_Delta (Prefix_Declaration2, '.', Pn_Prefix1);
    Add_Delta (Prefix_Declaration2, ':', Pname_Ns);
    Add_Delta (Prefix_Declaration2, Pn_Char_Base_Without_Ee, Pn_Prefix);

    Add_Delta (Prefix_Declaration3, 'f', Prefix_Declaration4);
    Add_Delta (Prefix_Declaration3, 'F', Prefix_Declaration4);
    Add_Delta (Prefix_Declaration3, '.', Pn_Prefix1);
    Add_Delta (Prefix_Declaration3, ':', Pname_Ns);
    Add_Delta (Prefix_Declaration3, Pn_Char_Base_Without_Ff, Pn_Prefix);

    Add_Delta (Prefix_Declaration4, 'i', Prefix_Declaration5);
    Add_Delta (Prefix_Declaration4, 'I', Prefix_Declaration5);
    Add_Delta (Prefix_Declaration4, '.', Pn_Prefix1);
    Add_Delta (Prefix_Declaration4, ':', Pname_Ns);
    Add_Delta (Prefix_Declaration4, Pn_Char_Base_Without_Ii, Pn_Prefix);

    Add_Delta (Prefix_Declaration5, 'x', Prefix_Declaration);
    Add_Delta (Prefix_Declaration5, 'X', Prefix_Declaration);
    Add_Delta (Prefix_Declaration5, '.', Pn_Prefix1);
    Add_Delta (Prefix_Declaration5, ':', Pname_Ns);
    Add_Delta (Prefix_Declaration5, Pn_Char_Base_Without_Xx, Pn_Prefix);

    Add_Delta (Prefix_Declaration, '.', Pn_Prefix1);
    Add_Delta (Prefix_Declaration, ':', Pname_Ns);
    Add_Delta (Prefix_Declaration, Pn_Chars, Pn_Prefix);

end Lexical.Finite_Automata;
