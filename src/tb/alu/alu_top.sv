/**
 * Copyright (c) 2023 Politecnico di Torino
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * File              : AluTop.sv
 * Author            : Fabio Scatozza <s315216@studenti.polito.it>
 * Date              : 11.06.2023
 * Last Modified Date: 11.06.2023
 * ---------------------------------------------------------------------------
 * Highest testbench layer, containing:
 *  - clock generator. The clock is in general more closely tied to the design
 *  rather than to the testbench, thus it's generated here.
 *
 *  - DUT.
 *
 *  - The testbench program block, which ensures separation between the design
 *  events (elaborated in the active region of the time slot) and the
 *  testbench events (elaborated in the reactive region).
 *
 *  - The interface between the two.
 */

// set time unit and resolution
`timescale 1ns/1ns

module alu_top;
  logic clk;

  // clock generator
  initial begin
    clk = 1;

    forever
      #5 clk = ~clk;
  end

  // instantiations
  alu_if ifc(clk);
  walu dut(ifc.alu);
  alu_test tb(ifc);

endmodule

