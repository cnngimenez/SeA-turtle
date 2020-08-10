--  lexical-turtle_lexer.ads ---

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

with Source;
use Source;
with Lexical.Token;
use Lexical.Token;

--
--  The lexicar analizer package for a Turtle file.
--
package Lexical.Turtle_Lexer is

    type Lexer_Type is tagged private;

    procedure Create (Lexer : in out Lexer_Type; Source : Source_Type);

    --  Take a token from the file consuming it.
    function Take_Token (Lexer : in out Lexer_Type) return Token_Type;

    --  Peek the next token from the file without consuming it.
    --  function Peek_Token (Lexer : Lexer_Type) return Token_Type;

    function Get_Source (Lexer : Lexer_Type) return Source_Type;
private
    type Lexer_Type is tagged record
        --  Peek_Buffer : ?
        Source : Source_Type;
    end record;

    function Reduce_Symbol (Symbol : Wide_Wide_Character)
                           return Wide_Wide_Character;
    procedure Start (Lexer : in out Lexer_Type; Token : out Token_Type);
end Lexical.Turtle_Lexer;
