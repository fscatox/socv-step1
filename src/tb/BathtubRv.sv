/**
 * Copyright (c) 2023 Politecnico di Torino
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * File              : BathtubRv.sv
 * Author            : Fabio Scatozza <s315216@studenti.polito.it>
 * Date              : 10.06.2023
 * Last Modified Date: 10.06.2023
 * Reference         : Chris Spear, Greg Tumbush.
 *                     SystemVerilog for Verification. Springer
 * ---------------------------------------------------------------------------
 * Extension of the probability density functions inherited from verilog:
 * bathtub distribution, so to skew the stimulus towards corner cases.
 */

`ifndef BATHTUBRV_SV
`define BATHTUBRV_SV

class BathtubRv
  #(parameter int unsigned WIDTH=32,
    parameter int unsigned MEAN=20); // P((max_value/2-1)/12) = 0.5

  logic [WIDTH-1:0] value;
  int unsigned seed;

  function new();
    $display("%0d", MEAN);
    seed = $urandom;
  endfunction

  function void pre_randomize();
    value = $dist_exponential(seed, MEAN);

    // randomly flip curve
    if ($urandom_range(1))
      value = ((64'd1<<WIDTH)-1) - value; // unsigned computation
  endfunction
endclass

`endif

