/**
 * Copyright (c) 2023 Politecnico di Torino
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * File              : AluPacket.sv
 * Author            : Fabio Scatozza <s315216@studenti.polito.it>
 * Date              : 10.06.2023
 * Last Modified Date: 10.06.2023
 * ---------------------------------------------------------------------------
 * Refined transaction considering the "walu" as DUT
 */

`ifndef ALUPACKET_SV
`define ALUPACKET_SV

import walu_pkg::*;
`include "../BaseTransaction.sv"
`include "../BathtubRv.sv"


class AluPacket extends BaseTransaction;

  // Payload
  data_t a, b, r; // randomization is customized to achieve a bathtub distribution
  rand op_t op;

  // randomization helpers
  BathtubRv#(.WIDTH(DATA_WIDTH)) bathtub_rv;

  // Constraint for skewing the stimulus towards corner cases
  function void pre_randomize();
    bathtub_rv.randomize();
    a = bathtub_rv.value;

    bathtub_rv.randomize();
    b = bathtub_rv.value;
  endfunction

  function new();
    bathtub_rv = new();
  endfunction

  virtual function bit compare(input BaseTransaction to);
    AluPacket other;
    $cast(other, to);

    return (this.r == other.r);
  endfunction : compare

  virtual function void display(input string prefix="");
    $display("%sAluPacket id:%0d | a=%x, b=%x, r=%x, op=%s",
      prefix, id, a, b, r, op.name());
    $display;
  endfunction : display

endclass

`endif
