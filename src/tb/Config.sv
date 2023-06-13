/**
 * Copyright (c) 2023 Politecnico di Torino
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * File              : Config.sv
 * Author            : Fabio Scatozza <s315216@studenti.polito.it>
 * Date              : 13.06.2023
 * Last Modified Date: 13.06.2023
 * ---------------------------------------------------------------------------
 * Central configuration descriptor for the testbench. It parses the
 * command-line argument that specifies the number of packets to generate.
 */

`ifndef CONFIG_SV
`define CONFIG_SV

class Config;
  int unsigned n_errors; // errors during the simulation

  // copy of configuration parameters
  int unsigned data_width;
  int unsigned n_packets;

  function new(input int unsigned data_width);
    this.data_width = data_width;
    n_errors = 0;

    if (!$value$plusargs("n_packets%d", n_packets))
      n_packets = 10;
  endfunction

  function void display(input string prefix="");
    $display("%sConfig: data_width=%0d, n_packets=%0d", prefix, data_width, n_packets);
    $display;
  endfunction

endclass

`endif
