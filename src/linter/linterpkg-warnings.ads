--  linterpkg-warnings.ads ---

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

with Syntactical.Analyser;
use Syntactical.Analyser;
with SeA.Namespaces.Prefixes;
use SeA.Namespaces.Prefixes;

generic

    with procedure Warning_Callback (Message : Universal_String);

package Linterpkg.Warnings is

    type Linter_State_Type is tagged private;

    --  Warning: It is recommended to use @base instead of BASE
    procedure Warn_Base_Used (Analyser : in out Syntax_Analyser_Type);

    --  Warning: It is recommended to use @prefix instead of PREFIX
    procedure Warn_Prefix_Used (Analyser : in out Syntax_Analyser_Type);

    --  Warning: Base IRI is not a valid IRI.
    --  Warning: Base IRI should end with slash or numeral
    --  Warning: Base IRI should not be a relative IRI
    procedure Check_Base_Iri (Analyser : in out Syntax_Analyser_Type);

    --  Warning: Prefix IRI is not a valid IRI.
    --  Warning: Base IRI should end with slash or numeral
    --  Warning: Base IRI should not be a relative IRI
    procedure Check_Prefix_Iri (Analyser : in out Syntax_Analyser_Type;
                                Prefix : Prefix_Type);

private

    type Linter_State_Type is tagged record
        Header_Declared : Boolean := False;
    end record;

end Linterpkg.Warnings;
