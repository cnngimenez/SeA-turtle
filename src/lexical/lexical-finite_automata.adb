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
    Acceptable_States.Insert (E_Langtag);
    Acceptable_States.Insert (I_Langtag);
    Acceptable_States.Insert (E_Iriref);
    Acceptable_States.Insert (WS);
    Acceptable_States.Insert (Dot);
    Acceptable_States.Insert (Pname_Ns);

    Add_Delta (Start, '@', Arroba);
    Add_Delta (Arroba, Letter, I_Langtag);
    Add_Delta (I_Langtag, Letter, I_Langtag);
    Add_Delta (I_Langtag, '-', Langtag1);
    Add_Delta (Langtag1, Letter, E_Langtag);
    Add_Delta (Langtag1, Decimal_Digit, E_Langtag);
    Add_Delta (E_Langtag, '-', Langtag1);

    Add_Delta (Start, '<', I_Iriref);
    Add_Delta (I_Iriref, Iriref_Chars, I_Iriref);
    Add_Delta (I_Iriref, '>', E_Iriref);
    Add_Delta (I_Iriref, '\', Uchar);
    Add_Delta (Uchar_End, Iriref_Chars, I_Iriref);
    Add_Delta (Uchar_End, '>', E_Iriref);

    Add_Delta (Uchar, 'u', Uchar1a);
    Add_Delta (Uchar1a, Hexadecimal_Digit, Uchar1b);
    Add_Delta (Uchar1b, Hexadecimal_Digit, Uchar1c);
    Add_Delta (Uchar1c, Hexadecimal_Digit, Uchar1d);
    Add_Delta (Uchar1d, Hexadecimal_Digit, Uchar_End);

    Add_Delta (Uchar, 'U', Uchar2a);
    Add_Delta (Uchar2a, Hexadecimal_Digit, Uchar2b);
    Add_Delta (Uchar2b, Hexadecimal_Digit, Uchar2c);
    Add_Delta (Uchar2c, Hexadecimal_Digit, Uchar2d);
    Add_Delta (Uchar2d, Hexadecimal_Digit, Uchar2e);
    Add_Delta (Uchar2e, Hexadecimal_Digit, Uchar2f);
    Add_Delta (Uchar2f, Hexadecimal_Digit, Uchar2g);
    Add_Delta (Uchar2g, Hexadecimal_Digit, Uchar2h);
    Add_Delta (Uchar2h, Hexadecimal_Digit, Uchar_End);

    Add_Delta (Start, WS, WS);
    Add_Delta (WS, WS, WS);

    Add_Delta (Start, Dot, Dot);

    Add_Delta (Start, ':', Pname_Ns);
    Add_Delta (Start, Pn_Char_Base_Without_Tf, Pn_Prefix);
    Add_Delta (Pn_Prefix, Pn_Chars, Pn_Prefix);
    Add_Delta (Pn_Prefix, ':', Pname_Ns);
    Add_Delta (Pn_Prefix, '.', Pn_Prefix1);
    Add_Delta (Pn_Prefix1, Pn_Chars, Pn_Prefix);
end Lexical.Finite_Automata;
