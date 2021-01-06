--  linterpkg-warnings.adb ---

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

package body Linterpkg.Warnings is

    procedure Check_Base_Iri (Analyser : in out Syntax_Analyser_Type) is
    begin
        if not Analyser.Is_Base_IRI_Valid then
            Warning_Callback
              (Current_Position_Us (Analyser)
                 & To_Universal_String
                 ("The following base IRI is not a valid IRI: ")
                 & Analyser.Get_Base_URI);
        end if;
        if not Analyser.Is_Base_IRI_Ending_Correctly then
            Warning_Callback
              (Current_Position_Us (Analyser)
                 & To_Universal_String
                 ("The following base IRI should end with ""#"" or ""/"":")
                 & Analyser.Get_Base_URI);
        end if;
        if Analyser.Is_Base_IRI_Relative then
            Warning_Callback
              (Current_Position_Us (Analyser)
                 & To_Universal_String
                 ("The following base IRI should not be a relative IRI "
                    & "(Should not have ""/."" or ""/..""):")
                 & Analyser.Get_Base_URI);
        end if;
    end Check_Base_Iri;

    procedure Check_Prefix_Iri (Analyser : in out Syntax_Analyser_Type;
                                Prefix : Prefix_Type) is
    begin
        if not Prefix.Is_IRI_Valid then
            Warning_Callback
              (Current_Position_Us (Analyser)
                 & To_Universal_String
                 ("The following prefix has not a valid IRI: ")
                 & Prefix.Get_Name
                 & To_Universal_String (" -> ")
                 & Prefix.Get_IRI);
        end if;
        if not Prefix.Is_IRI_Ending_Correctly then
            Warning_Callback
              (Current_Position_Us (Analyser)
                 & To_Universal_String
                 ("The following prefix IRI should end with ""#"" or ""/"": ")
                 & Prefix.Get_Name
                 & To_Universal_String (" -> ")
                 & Prefix.Get_IRI);
        end if;
        if Prefix.Is_Relative_IRI then
            Warning_Callback
              (Current_Position_Us (Analyser)
                 & To_Universal_String
                 ("The prefix IRI should not be a relative IRI "
                    & "(Should not have ""/."" or ""/..""): ")
                 & Prefix.Get_Name
                 & To_Universal_String (" -> ")
                 & Prefix.Get_IRI);
        end if;
    end Check_Prefix_Iri;

    procedure Warn_Base_Used (Analyser : in out Syntax_Analyser_Type) is
    begin
        Warning_Callback
          (Current_Position_Us (Analyser)
             & To_Universal_String
             ("It is recommended to use @base instead of BASE"));
    end Warn_Base_Used;

    procedure Warn_Prefix_Used (Analyser : in out Syntax_Analyser_Type) is
    begin
        Warning_Callback
          (Current_Position_Us (Analyser)
             & To_Universal_String
             ("It is recommended to use @prefix instead of PREFIX"));
    end Warn_Prefix_Used;

end Linterpkg.Warnings;
