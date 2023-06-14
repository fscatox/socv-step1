/**
* Copyright (c) 2023 Politecnico di Torino
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree.
*
* File              : acc_if.sv
* Author            : Fabio Scatozza <s315216@studenti.polito.it>
* Date              : 13.06.2023
* Last Modified Date: 14.06.2023
* ---------------------------------------------------------------------------
* The interface encapsulates connectivity and synchronization between the
* DUT and the testbench environment.
*/

`ifndef ACC_IF_SV
`define ACC_IF_SV

import acc_pkg::*;

interface acc_if
  (input bit clk);

  data_t a, b, y;
  bit acc;
  bit acc_en_n, rst_n;

  // synchronizer between the DUT and the testbench
  //  - sample DUT outputs upon design activity completion (postponed region)
  //  - drive DUT inputs with #0 skew

  clocking cb @(posedge clk);
    output a, b, acc, acc_en_n, rst_n;
  endclocking

  modport tb (clocking cb, input y);

endinterface

`endif

