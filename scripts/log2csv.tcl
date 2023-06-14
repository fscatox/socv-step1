#!/usr/bin/env tclsh
#
# Copyright (c) 2023 Politecnico di Torino
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. 
#
# File              : log2csv.tcl
# Author            : Fabio Scatozza <s315216@studenti.polito.it>
# Date              : 14.06.2023
# Last Modified Date: 14.06.2023
# ----------------------------------------------------------------------------
# Procedure for parsing the simulation logs and extract the stimulus vector
# in comma-separated format.

proc log2csv {in_file out_file} {
  set patterns      {{Sv_Seed = [0-9]+} {Config: .+}} 
  set stim_pattern  {# +against[^{]+\{ ([^}]+) \}}
  set pattern_idx 0

  set in_chan [open "$in_file"] 
  set out_chan [open "$out_file" "w"]

  # save seed and configuration
  while {$pattern_idx < 2 && [gets $in_chan line] >= 0} {
    if {[regexp [lindex $patterns $pattern_idx] $line match]} {
      puts $out_chan $match
      incr pattern_idx
    } 
  }
  puts $out_chan {}

  set print_header true
  set field_pattern {(?:, )?([^ ]+)=}
  while {[gets $in_chan line] >= 0} {
    if {[regexp $stim_pattern $line match packet_content]} {
      if {$print_header} {
        # print the names of variables inside the packet
        set field_names [lmap {i ii} [regexp -all -inline $field_pattern $packet_content] {list $ii}]
        lappend field_names MISMATCH

        puts $out_chan [join $field_names ,]
        set print_header false
      }

      # parse the variables value
      set csv_packet_content [regsub -all $field_pattern $packet_content ,]
      # parse the comparison result and print 
      puts $out_chan [string trimleft $csv_packet_content ,],[regexp {ERROR MISMATCH} [gets $in_chan]]
    }
  }

  close $in_chan
  close $out_chan
}
