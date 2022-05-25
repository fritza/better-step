# ``mommk``

A command-line tool for populating a Core Data store with `DASIQuestion`s. 

**FIXME**: how do I describe the preconditions? The one below: "Only links are allowed in task group items." -- "Remove ### Preconditions"

## Overview

Run `mommk` given object model, a list of DASI questions, and a target `*.sqlite` store.

## Topics

### Preconditions

- A `.mom` file (not a `.momd` directory) describing the object model for the store. (`-m`) 
- A source `.json` file for the questions. (`-s`)
- A path `.sqlite` database to receive the generated questions. Attempting to use an existing file is an error unless the `-f` (force) switch is set (tool parameter)

All file paths are absolute or relative to `pwd`.

### MOM

The build process will yield a `.momd` directory including the plain `.mom` data model file. This will be copied from the build directory into `SRCROOT` (the source directory).
