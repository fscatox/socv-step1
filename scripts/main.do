# Copyright (c) 2023 Politecnico di Torino
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. 

# Author            : Fabio Scatozza <s315216@studenti.polito.it>
# Date              : 02.06.2023
# Last Modified Date: 10.06.2023

###############################
# QuestaSIM AUTOMATION SCRIPT #
###############################
transcript quietly

# locate project directory
set proj_dir        $::env(TCL_PROJ_DIR)
set args            $::env(TCL_ARGS)

set src_dir         $proj_dir/src
set script_dir      $proj_dir/scripts

# the output directory is named joining relevant
# information about the simulation to be run
set out_dir         $proj_dir/out/[join $args _]
set artifacts_dir   $out_dir/artifacts_sim

# clean the workspace
file delete -force $artifacts_dir
file mkdir $artifacts_dir 

# create project and map work library
project new $artifacts_dir proj  

# collect all hdl sources to be compiled
source $script_dir/findFiles.tcl

# start with vhdl sources (for mixed language support)
set hdl_sources [findFiles $src_dir "*.vhd"]

# add sources to current project
foreach hdl $hdl_sources {
  project addfile $hdl
}

# compile to solve dependencies
project calculateorder

# enable mixed language support
foreach hdl [project compileorder] {
  vcom -mixedsvvh $hdl
  project removefile $hdl
}

# then verilog and systemverilog
set hdl_extensions {v sv}
set hdl_sources {} 

foreach ext $hdl_extensions {
  lappend hdl_sources [findFiles $src_dir "*.$ext"]
}
set hdl_sources [join $hdl_sources]

# add sources to current project
foreach hdl $hdl_sources {
  project addfile $hdl
}

# compile and solve dependencies
project calculateorder

# $args starts with 'top-module'
puts "\n############################  SIMULATION  STARTS  ##############################\n"
vsim -sv_seed random $args 
run -all
puts "\n############################  SIMULATION  ENDS    ##############################\n"

# report coverage
set src_opt {}
if {[regexp {vsim ([0-9]{4})\.[0-9]{1,2}} [vsim -version] match year] && $year < 2020 } {
  set src_opt "-byfile"
}

# -all
# When reporting toggles, creates a report that lists both toggled
# and untoggled signals. Reports counts of all enumeration values.
# Not a valid option when reporting on a functional coverage database.

# -cvg 
# Adds covergroup coverage data to the report.

# -details
# Includes details associated with each coverage item in the output (FEC).
# By default, details are not provided. You cannot use this argument with -recursive.

# -directive
# Reports only cover directive coverage data.

# -srcfile=<filename>[+<filename>]
# Reports the coverage data for the specified source files. By default, all source
# information is included. You can use wildcards (*).

coverage report -all -cvg -details -directive -output $out_dir/func_cover.rpt $src_opt

# save log
set log_file [transcript path]
transcript file ""
file rename -force $log_file $out_dir/vsim.log

# quit 
quit -sim
project close
file delete -force $artifacts_dir

exit

