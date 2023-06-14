/**
* Copyright (c) 2023 Politecnico di Torino
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree.
*
* File              : alu_if.sv
* Author            : Fabio Scatozza <s315216@studenti.polito.it>
* Date              : 10.06.2023
* Last Modified Date: 14.06.2023
* ---------------------------------------------------------------------------
* The interface encapsulates connectivity and synchronization between the
* DUT and the testbench environment.
*/

`ifndef ALU_IF_SV
`define ALU_IF_SV

import walu_pkg::*;
import type_alu::*; // VHDL package

interface alu_if
  (input bit clk);

  data_t a, b, r;
  type_op op;

  // synchronizer between the DUT and the testbench
  //  - sample DUT outputs upon design activity completion (postponed region)
  //  - drive DUT inputs with #0 skew

  clocking cb @(posedge clk);
    output a, b, op;
  endclocking

  modport tb (clocking cb, input r);

  modport alu (
    input a, b, op,
    output r
  );
endinterface

`endif
