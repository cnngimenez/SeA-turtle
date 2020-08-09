--  lexical-symbol_sets.adb ---

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

package body Lexical.Symbol_Sets is
    function "<" (Symbol_A, Symbol_B : Symbol_Set_Type) return Boolean is
    begin
        if Symbol_A.Unitary and then Symbol_B.Unitary then
            return Symbol_A.Symbol < Symbol_B.Symbol;
        else
            return Symbol_A.Set_Name < Symbol_B.Set_Name;
        end if;
    end "<";

    overriding function "=" (Symbol_A, Symbol_B : Symbol_Set_Type)
                            return Boolean is
    begin
        if Symbol_A.Unitary and then Symbol_B.Unitary then
            return Symbol_A.Symbol = Symbol_B.Symbol;
        else
            return Symbol_A.Set_Name = Symbol_B.Set_Name;
        end if;
    end "=";

    function Find_Set (Possible_Sets : Possible_Symbol_Sets_Type;
                       Test_Function : not null access
                         function (Set : Symbol_Set_Type)
                         return Boolean)
                      return Symbol_Set_Type'Class is
        use Group_Sets;

        Index : Group_Sets.Cursor;
        Founded : Boolean := False;
    begin
        if Possible_Sets.Set.Is_Empty then
            return Invalid_Symbol_Set;
        end if;

        Index := Possible_Sets.Set.First;
        Founded := Test_Function (Element (Index));
        while not Founded and then Index /= Possible_Sets.Set.Last loop
            Next (Index);
            Founded := Test_Function (Element (Index));
        end loop;

        if Founded then
            return Element (Index);
        else
            return Invalid_Symbol_Set;
        end if;
    end Find_Set;

    function Get_Name (Symbol_Set : Symbol_Set_Type)
                      return Symbol_Set_Name_Type is
    begin
        return Symbol_Set.Set_Name;
    end Get_Name;

    function Get_Possible_Sets (Symbol : Wide_Wide_Character)
                               return Possible_Symbol_Sets_Type is
        Possible_Sets : Possible_Symbol_Sets_Type;
        Symbol_Set : Symbol_Set_Type;

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
        Char_X22 :  constant Wide_Wide_Character :=
          Wide_Wide_Character'Val (16#22#);
        Char_X27 :  constant Wide_Wide_Character :=
          Wide_Wide_Character'Val (16#27#);
        Char_X5c :  constant Wide_Wide_Character :=
          Wide_Wide_Character'Val (16#5C#);
        Char_X0a :  constant Wide_Wide_Character :=
          Wide_Wide_Character'Val (16#0A#);
        Char_X0d :  constant Wide_Wide_Character :=
          Wide_Wide_Character'Val (16#0D#);
    begin
        case Symbol is
        when 'a' .. 'f' | 'F' .. 'F' =>
            Symbol_Set.Initialize (Letter);
            Possible_Sets.Set.Insert (Symbol_Set);
            Symbol_Set.Initialize (Hexadecimal_Digit);
            Possible_Sets.Set.Insert (Symbol_Set);
            Symbol_Set.Initialize (Pn_Char_Base_Without_Tf);
            Possible_Sets.Set.Insert (Symbol_Set);
            Symbol_Set.Initialize (Pn_Chars_U);
            Possible_Sets.Set.Insert (Symbol_Set);
            Symbol_Set.Initialize (Pn_Chars);
            Possible_Sets.Set.Insert (Symbol_Set);
        when 'g' .. 'z' | 'G' .. 'Z' =>
            Symbol_Set.Initialize (Letter);
            Possible_Sets.Set.Insert (Symbol_Set);
            Symbol_Set.Initialize (Pn_Char_Base_Without_Tf);
            Possible_Sets.Set.Insert (Symbol_Set);
            Symbol_Set.Initialize (Pn_Chars_U);
            Possible_Sets.Set.Insert (Symbol_Set);
            Symbol_Set.Initialize (Pn_Chars);
            Possible_Sets.Set.Insert (Symbol_Set);
        when '0' .. '9' =>
            Symbol_Set.Initialize (Decimal_Digit);
            Possible_Sets.Set.Insert (Symbol_Set);
            Symbol_Set.Initialize (Hexadecimal_Digit);
            Possible_Sets.Set.Insert (Symbol_Set);
            Symbol_Set.Initialize (Pn_Chars);
            Possible_Sets.Set.Insert (Symbol_Set);
        when ' ' | Tab_Char | New_Line_Char | Carriage_Char =>
            Symbol_Set.Initialize (WS);
            Possible_Sets.Set.Insert (Symbol_Set);
        when '.' =>
            Symbol_Set.Initialize (Dot);
            Possible_Sets.Set.Insert (Symbol_Set);
            Symbol_Set.Initialize (Pn_Local_Esc);
            Possible_Sets.Set.Insert (Symbol_Set);
        when '_' =>
            Symbol_Set.Initialize (Pn_Chars);
            Possible_Sets.Set.Insert (Symbol_Set);
            Symbol_Set.Initialize (Pn_Chars_U);
            Possible_Sets.Set.Insert (Symbol_Set);
            Symbol_Set.Initialize (Pn_Local_Esc);
            Possible_Sets.Set.Insert (Symbol_Set);
        when '-' =>
            Symbol_Set.Initialize (Pn_Chars);
            Possible_Sets.Set.Insert (Symbol_Set);
            Symbol_Set.Initialize (Pn_Local_Esc);
            Possible_Sets.Set.Insert (Symbol_Set);
        when '~' | ''' | '!' | '$' | '&' | '('
          | ')' | '*' | '+' | ',' | ';' | '=' | '/'
          | '?' | '#' | '@' | '%' =>
            Symbol_Set.Initialize (Pn_Local_Esc);
            Possible_Sets.Set.Insert (Symbol_Set);
        when others =>
            null;
        end case;

        Symbol_Set.Initialize (Symbol);
        Possible_Sets.Set.Insert (Symbol_Set);

        --  PN_CHAR_BASE - tf
        --  [#x00C0-#x00D6] | [#x00D8-#x00F6] | [#x00F8-#x02FF]
        --  | [#x0370-#x037D] | [#x037F-#x1FFF] | [#x200C-#x200D]
        --  | [#x2070-#x218F] | [#x2C00-#x2FEF] | [#x3001-#xD7FF]
        --  | [#xF900-#xFDCF] | [#xFDF0-#xFFFD] | [#x10000-#xEFFFF]
        --  if Symbol in   then
        --
        --  end if;

        --  PN_CHARS
        --  #x00B7 | [#x0300-#x036F] | [#x203F-#x2040]

        --  It is too difficult to add a "not" in the above "case" statement.
        if not (Symbol in Null_Char .. Space_Char or else Symbol = '<'
                  or else Symbol = '>' or else Symbol = '"'
                  or else Symbol = '{' or else Symbol = '}'
                  or else Symbol = '|' or else Symbol = '^'
                  or else Symbol = '^' or else Symbol = '`'
                  or else Symbol = '\')
        then
            Symbol_Set.Initialize (Iriref_Chars);
            Possible_Sets.Set.Insert (Symbol_Set);
        end if;

        if Symbol = 't' or else Symbol = 'b' or else Symbol = 'n'
          or else Symbol = 'r' or else Symbol = 'f'
          or else Symbol = '"' or else Symbol = '''
          or else Symbol = '\'
        then
            Symbol_Set.Initialize (ECHAR_Chars);
            Possible_Sets.Set.Insert (Symbol_Set);
        end if;

        if Symbol /= '"' and then Symbol /= '\' then
            Symbol_Set.Initialize (Non_Isllq_Chars);
            Possible_Sets.Set.Insert (Symbol_Set);
        end if;

        if Symbol /= ''' and then Symbol /= '\' then
            Symbol_Set.Initialize (Non_Isllsq_Chars);
            Possible_Sets.Set.Insert (Symbol_Set);
        end if;

        if Symbol /= New_Line_Char and then Symbol /= Carriage_Char then
            Symbol_Set.Initialize (Comment_Chars);
            Possible_Sets.Set.Insert (Symbol_Set);
        end if;

        if not (Symbol = Char_X22 or else Symbol = Char_X5c
                  or else Symbol = Char_X0a or else Symbol = Char_X0d)
        then
            Symbol_Set.Initialize (Non_SLQ_Chars);
            Possible_Sets.Set.Insert (Symbol_Set);
        end if;

        if not (Symbol = Char_X27 or else Symbol = Char_X5c
                  or else Symbol = Char_X0a or else Symbol = Char_X0d)
        then
            Symbol_Set.Initialize (Non_SLSQ_Chars);
            Possible_Sets.Set.Insert (Symbol_Set);
        end if;

        return Possible_Sets;
    end Get_Possible_Sets;

    function Get_Symbol (Symbol_Set : Symbol_Set_Type)
                        return Wide_Wide_Character is
    begin
        return Symbol_Set.Symbol;
    end Get_Symbol;

    procedure Initialize (Symbol_Set : in out Symbol_Set_Type;
                          Symbol : Wide_Wide_Character) is
    begin
        Symbol_Set.Symbol := Symbol;
        Symbol_Set.Unitary := True;
        Symbol_Set.Set_Name := Unitary;
    end Initialize;

    procedure Initialize (Symbol_Set : in out Symbol_Set_Type;
                          Set_Name : Symbol_Set_Name_Type) is
    begin
        Symbol_Set.Symbol := ' ';
        Symbol_Set.Unitary := False;
        Symbol_Set.Set_Name := Set_Name;
    end Initialize;

    function Is_Empty (Possible_Sets : Possible_Symbol_Sets_Type)
                      return Boolean is
    begin
        return Possible_Sets.Set.Is_Empty;
    end Is_Empty;

    function Is_Unitary (Symbol_Set : Symbol_Set_Type) return Boolean is
    begin
        return Symbol_Set.Unitary;
    end Is_Unitary;

    function Symbol_In_Set (Symbol_Set : Symbol_Set_Type;
                            Symbol : Wide_Wide_Character)
                             return Boolean is
        Possible_Sets : constant Possible_Symbol_Sets_Type :=
          Get_Possible_Sets (Symbol);
    begin
        return Symbol_Set_In_Possible_Sets (Symbol_Set, Possible_Sets);
    end Symbol_In_Set;

    function Symbol_Set_In_Possible_Sets
      (Symbol_Set : Symbol_Set_Type;
       Possible_Sets : Possible_Symbol_Sets_Type'Class)
      return Boolean is
    begin
        return Possible_Sets.Set.Contains (Symbol_Set);
    end Symbol_Set_In_Possible_Sets;
end Lexical.Symbol_Sets;
