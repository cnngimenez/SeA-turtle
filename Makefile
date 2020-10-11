### Makefile --- 

## Author: cnngimenez
## Version: $Id: Makefile,v 0.0 2020/09/04 14:23:54  Exp $
## Keywords: 
## X-URL: 

# Copyright 2020 cnngimenez

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

### Makefile ends here

-include makefile.setup

## What type of library should I compile (dynamic, static or static-pic)?
ifndef LIBRARY_KIND
  LIBRARY_KIND=all
endif
## Where are the .ads files?
# ifndef ADA_INCLUDE_PATH
#   ADA_INCLUDE_PATH=
# endif
## Where are the .gpr files?
# ifndef GPR_PROJECT_PATH
#   GPR_PROJECT_PATH=
# endif
## Where should I install the files
ifndef prefix
  prefix=/usr/share/local
endif



all: compile

compile: compile_library compile_programs

install: install_programs install_library 

clean: clean_library clean_programs

uninstall: uninstall_library uninstall_program

## Programs

compile_programs:
ifeq ($(LIBRARY_KIND),all)
	gprbuild -p -P SeA_turtle_binaries.gpr -XLIBRARY_KIND=static -XOBJECT_DIR="library_static_objs"
else
	gprbuild -p -P SeA_turtle_binaries.gpr -XLIBRARY_KIND=$(LIBRARY_KIND)
endif

install_programs:
	gprinstall -p SeA_turtle_binaries.gpr --prefix=$(prefix)

clean_programs:
	gprclean SeA_turtle_binaries.gpr

uninstall_programs:
	gprinstall --uninstall --prefix=$(prefix) turtle

## Library

compile_library:
ifeq ($(LIBRARY_KIND),all)
	gprbuild -p -P SeA_turtle.gpr -XLIBRARY_KIND=static -XOBJECT_DIR="library_static_objs"
	gprbuild -p -P SeA_turtle.gpr -XLIBRARY_KIND=relocatable -XOBJECT_DIR="library_relocatable_objs"
else
	gprbuild -p -P SeA_turtle.gpr -XLIBRARY_KIND=$(LIBRARY_KIND)
endif

clean_library:
	gprclean SeA_turtle.gpr -XLIBRARY_KIND=static -XOBJECT_DIR="library_static_objs"
	gprclean SeA_turtle.gpr -XLIBRARY_KIND=relocatable -XOBJECT_DIR="library_relocatable_objs"
	gprclean SeA_turtle.gpr

install_library:
	gprinstall -p -P SeA_turtle.gpr --prefix=$(prefix)

uninstall_library:
	gprinstall --uninstall --prefix=$(prefix) turtle_lib

## Rules that uses no echoing
## .SILENT: setup

setup:
	echo "Creating makefile.setup file with current settings..."
	echo

	echo "## ## Makefile personal setup ##" > makefile.setup
	echo "## Edit this file with your own settings" >> makefile.setup

	echo "## Type of library to create." >> makefile.setup
	echo "## Value \"all\" = relocatable and static" >> makefile.setup
	echo "## Values: relocatable, static, static-pic or all" >> makefile.setup
	echo "LIBRARY_KIND=$(LIBRARY_KIND)" >> makefile.setup
	echo "## Where are the .ads files?" >> makefile.setup
	echo "ADA_INCLUDE_PATH=$(ADA_INCLUDE_PATH)" >> makefile.setup
	echo "GPR_PROJECT_PATH=$(GPR_PROJECT_PATH)" >> makefile.setup

	echo "## ## Install Parameters ##" >> makefile.setup
	echo "## Where should I install the files?" >> makefile.setup
	echo "prefix=$(prefix)" >> makefile.setup

	echo
	echo "Edit the makefile.setup file with your personal parameters."
	echo "Makefile will use it as long as it exists."
