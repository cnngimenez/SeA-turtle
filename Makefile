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

## What type of library should I compile (dynamic, static or static-pic)?
LIBRARY_TYPE=relocatable
## Where are the .ads files?
# ADA_INCLUDE_PATH=
## Where are the .gpr files?
# GPR_PROJECT_PATH=
## Where should I install the files
ifndef prefix
  prefix=/usr/share/local
endif

-include makefile.setup

all: compile

compile:
	gprbuild -p -P turtle.gpr 

install:
	gprinstall -p turtle.gpr --prefix=$(prefix)

## Rules that uses no echoing
## .SILENT: setup

setup:
	echo "Creating makefile.setup file with current settings..."
	echo

	echo "## ## Makefile personal setup ##" > makefile.setup
	echo "## Edit this file with your own settings" >> makefile.setup

	echo "## Type of library to create:" >> makefile.setup
	echo "## Values: relocatable or static" >> makefile.setup
	echo "LIBRARY_TYPE=$(LIBRARY_TYPE)" >> makefile.setup
	echo "## Where are the .ads files?" >> makefile.setup
	echo "ADA_INCLUDE_PATH=$(ADA_INCLUDE_PATH)" >> makefile.setup
	echo "GPR_PROJECT_PATH=$(GPR_PROJECT_PATH)" >> makefile.setup

	echo "## ## Install Parameters ##" >> makefile.setup
	echo "## Where should I install the files?" >> makefile.setup
	echo "prefix=$(prefix)" >> makefile.setup

	echo
	echo "Edit the makefile.setup file with your personal parameters."
	echo "Makefile will use it as long as it exists."
