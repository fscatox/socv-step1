/**
 * Copyright (c) 2023 Politecnico di Torino
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * File              : walu.sv
 * Author            : Fabio Scatozza <s315216@studenti.polito.it>
 * Date              : 10.06.2023
 * Last Modified Date: 12.06.2023
 * ---------------------------------------------------------------------------
 * Wrapper for the ALU described in the VHDL entity "alu".
 */

`ifndef WALU_SV
`define WALU_SV

`include "alu_if.sv"

  module walu
    (alu_if.alu p);

    alu #(DATA_WIDTH) alu_i (
      .func(p.op),
      .data1(p.a),
      .data2(p.b),
      .outalu(p.r)
    );

  endmodule

`endif
