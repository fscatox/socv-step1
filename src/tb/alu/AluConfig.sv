/**
 * Copyright (c) 2023 Politecnico di Torino
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * File              : AluConfig.sv
 * Author            : Fabio Scatozza <s315216@studenti.polito.it>
 * Date              : 11.06.2023
 * Last Modified Date: 11.06.2023
 * ---------------------------------------------------------------------------
 * Central configuration descriptor for the testbench
 */

`ifndef ALUCONFIG_SV
`define ALUCONFIG_SV

class AluConfig;
  int n_errors; // errors during the simulation

  // copy of configuration parameters
  int data_width;
  int n_packets;

  function new(input int data_width);
    this.data_width = data_width;

    if (!$value$plusargs("n_packets%d", n_packets))
      n_packets = 10;

    n_errors = 0;
  endfunction

  function void display(input string prefix="");
    $display("%sConfig: data_width=%0d, n_packets=%0d", prefix, data_width, n_packets);
  endfunction

endclass

`endif
