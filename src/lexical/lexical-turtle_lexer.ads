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
--  The lexicar analyser package for a Turtle file.
--
package Lexical.Turtle_Lexer is

    --
    --  A Lexical analyser type of object/record.
    --
    type Lexer_Type is tagged private;

    --
    --  Initialize a Lexer Type.
    --
    procedure Create (Lexer : in out Lexer_Type; Source : Source_Type);

    --
    --  Take a token from the file consuming it.
    --
    --  If there is a token in the buffer, consume it and empty the buffer.
    --  Else, take another token from the source.
    --
    function Take_Token (Lexer : in out Lexer_Type;
                         Ignore_Whitespaces : Boolean := True;
                         Ignore_Comments : Boolean := True)
                        return Token_Type;

    --
    --  Peek the next token from the file without consuming it.
    --
    --  Use the buffered token if there exist one, if not, take the next token
    --  and store it into the buffer for subsequent peeks.
    --
    function Peek_Token (Lexer : in out Lexer_Type;
                         Ignore_Whitespaces : Boolean := True;
                         Ignore_Comments : Boolean := True)
                        return Token_Type;

    --
    --  Getter: Get the associated Source_Type.
    --
    function Get_Source (Lexer : Lexer_Type) return Source_Type;

    function Get_Column_Number (Lexer : Lexer_Type) return Natural;
    function Get_Line_Number (Lexer : Lexer_Type) return Natural;
private

    type Lexer_Type is tagged record
        --  The token buffered for the Peek_Token function.
        Token_Buffer : Token_Type;
        --  Is the token buffer being used? If it is empty this is False.
        Token_Buffered : Boolean;
        --  Source data (file, string, stream, etc.) to take tokens from it.
        Source : Source_Type;
    end record;

    --
    --  Start the finite deterministic automata to parse the next token.
    --
    procedure Start (Lexer : in out Lexer_Type; Token : out Token_Type);
end Lexical.Turtle_Lexer;
