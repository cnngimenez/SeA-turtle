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

with Ada.Strings.Wide_Wide_Unbounded;
use Ada.Strings.Wide_Wide_Unbounded;

package body Lexical.Finite_Automata is

    function "<" (Transition_A : Transition_Type;
                  Transition_B : Transition_Type) return Boolean is
    begin
        return Transition_A.Current_State < Transition_B.Current_State or else
          Transition_A.Symbol < Transition_B.Symbol;
    end "<";

    procedure Add_Delta (Current_State : State_Type;
                         Symbol : Wide_Wide_Character;
                         Next_State : State_Type) is
        Transition : Transition_Type;
    begin
        Transition.Current_State := Current_State;
        Transition.Symbol := Symbol;
        Transition_Function.Insert (Transition, Next_State);
    end Add_Delta;

    function Get_Current_State (Automata : Automata_Type) return State_Type is
    begin
        return Automata.Current_State;
    end Get_Current_State;

    function Get_Symbol_Group (Symbol : Wide_Wide_Character)
                              return Wide_Wide_String is
        Possible_Reductions : Unbounded_Wide_Wide_String;
        Tab_Char : constant Wide_Wide_Character :=
          Wide_Wide_Character'Val (9);
        Carriage_Char : constant Wide_Wide_Character :=
          Wide_Wide_Character'Val (13);
        New_Line_Char : constant Wide_Wide_Character :=
          Wide_Wide_Character'Val (10);
        Null_Char : constant Wide_Wide_Character :=
          Wide_Wide_Character'Val (0);
        Space_Char : constant Wide_Wide_Character :=
          Wide_Wide_Character'Val (16#20#);
    begin
        case Symbol is
        when 'a' .. 'f' | 'F' .. 'F' =>
            Append (Possible_Reductions, 'a');
            Append (Possible_Reductions, 'x');
        when 'g' .. 'z' | 'G' .. 'Z' =>
            Append (Possible_Reductions, 'a');
        when '0' .. '9' =>
            Append (Possible_Reductions, '0');
            Append (Possible_Reductions, 'x');
        when ' ' | Tab_Char | New_Line_Char | Carriage_Char =>
            Append (Possible_Reductions, ' ');
        when others =>
            Append (Possible_Reductions, Symbol);
        end case;

        --  It is too difficult to add a "not" in the above "case" statement.
        if not (Symbol in Null_Char .. Space_Char or else Symbol /= '<'
                  or else Symbol /= '>' or else Symbol /= '"'
                  or else Symbol /= '{' or else Symbol /= '}'
                  or else Symbol /= '|' or else Symbol /= '^'
                  or else Symbol /= '^' or else Symbol /= '`'
                  or else Symbol /= '\')
        then
            Append (Possible_Reductions, '^');
        end if;

        return To_Wide_Wide_String (Possible_Reductions);
    end Get_Symbol_Group;

    function Get_Transition (State : State_Type; Symbol : Wide_Wide_Character)
                            return Transition_Type is
        Transition : Transition_Type;
        I : Natural;
        Possible_Groups : constant Wide_Wide_String :=
          Get_Symbol_Group (Symbol);
    begin
        if Possible_Groups = "" then
            --  It couldn't find any possible groups, this means that there's
            --  no mapping on this symbol or just a problem in the programming.
            return Invalid_Transition;
        end if;

        Transition.Current_State := State;
        I := Possible_Groups'First;

        Transition.Symbol := Possible_Groups (I);
        while I <= Possible_Groups'Length and then
          not Transition_Function.Contains (Transition)
        loop
            I := I + 1;
            if I <= Possible_Groups'Length then
                Transition.Symbol := Possible_Groups (I);
            end if;
        end loop;

        if I > Possible_Groups'Length then
            return Invalid_Transition;
        else
            return Transition;
        end if;

    end Get_Transition;

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
        Transition : Transition_Type;
    begin
        if Automata.Current_State = Blocked then
            return;
        end if;

        Transition := Get_Transition (Automata.Current_State, Symbol);

        Automata.Previous_State := Automata.Current_State;
        if Transition /= Invalid_Transition then
            Automata.Current_State := Transition_Function.Element (Transition);
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

begin
    Acceptable_States.Insert (E_Langtag);
    Acceptable_States.Insert (I_Langtag);
    Acceptable_States.Insert (E_Iriref);
    Acceptable_States.Insert (WS);

    --  Group of characters :
    --  a := [a-zA-Z]
    --  0 := [0-9]
    --  x := [0-9a-fA-F] (hexadecimal digits)
    --  ^ := [^#x00-#x20<>"{}|^`\] (#x00 and #x20 are the UTF-8
    --       00 to 20 codes).
    --  ' ' := [ \t\n\r] (whitespaces)

    Add_Delta (Start, '@', Arroba);
    Add_Delta (Arroba, 'a', I_Langtag);
    Add_Delta (I_Langtag, 'a', I_Langtag);
    Add_Delta (I_Langtag, '-', Langtag1);
    Add_Delta (Langtag1, 'a', E_Langtag);
    Add_Delta (Langtag1, '0', E_Langtag);
    Add_Delta (E_Langtag, '-', Langtag1);

    Add_Delta (Start, '<', I_Iriref);
    Add_Delta (I_Iriref, '^', I_Iriref);
    Add_Delta (I_Iriref, '>', E_Iriref);
    Add_Delta (I_Iriref, '\', Uchar);
    Add_Delta (Uchar_End, '^', I_Iriref);
    Add_Delta (Uchar_End, '>', E_Iriref);

    Add_Delta (Uchar, 'u', Uchar1a);
    Add_Delta (Uchar1a, 'x', Uchar1b);
    Add_Delta (Uchar1b, 'x', Uchar1c);
    Add_Delta (Uchar1c, 'x', Uchar1d);
    Add_Delta (Uchar1d, 'x', Uchar_End);

    Add_Delta (Uchar, 'U', Uchar2a);
    Add_Delta (Uchar2a, 'x', Uchar2b);
    Add_Delta (Uchar2b, 'x', Uchar2c);
    Add_Delta (Uchar2c, 'x', Uchar2d);
    Add_Delta (Uchar2d, 'x', Uchar2e);
    Add_Delta (Uchar2e, 'x', Uchar2f);
    Add_Delta (Uchar2f, 'x', Uchar2g);
    Add_Delta (Uchar2g, 'x', Uchar2h);
    Add_Delta (Uchar2h, 'x', Uchar_End);

    Add_Delta (Start, ' ', WS);
    Add_Delta (WS, ' ', WS);
end Lexical.Finite_Automata;
