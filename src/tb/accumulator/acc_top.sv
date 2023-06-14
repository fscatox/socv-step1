/**
 * Copyright (c) 2023 Politecnico di Torino
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * File              : acc_top.sv
 * Author            : Fabio Scatozza <s315216@studenti.polito.it>
 * Date              : 13.06.2023
 * Last Modified Date: 14.06.2023
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

module acc_top;
  logic clk;
  event dut_ready; // tell acc_test when reset is done

  initial begin

    // system reset
    clk = 0;
    ifc.rst_n = 0;

    #5 clk = 1; // make the dut sample the reset
    #5 ->dut_ready; // safe to start the environment

    // clock generator
    forever
      #5 clk = ~clk;
  end

  // instantiations
  acc_if ifc(clk);

  acc#(acc_pkg::DATA_WIDTH) acc_i (
    .a(ifc.a),
    .b(ifc.b),
    .clk(ifc.clk),
    .rst_n(ifc.rst_n),
    .accumulate(ifc.acc),
    .acc_en_n(ifc.acc_en_n),
    .y(ifc.y)
  );

  acc_test tb(.ifci(ifc), .dut_ready(dut_ready));

endmodule

