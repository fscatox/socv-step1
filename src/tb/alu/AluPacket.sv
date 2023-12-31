/**
 * Copyright (c) 2023 Politecnico di Torino
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * File              : AluPacket.sv
 * Author            : Fabio Scatozza <s315216@studenti.polito.it>
 * Date              : 10.06.2023
 * Last Modified Date: 13.06.2023
 * ---------------------------------------------------------------------------
 * Refinement of what "transaction" means for the "walu" testbench
 */

`ifndef ALUPACKET_SV
`define ALUPACKET_SV

import walu_pkg::*;
import type_alu::*;

`include "../BaseTransaction.sv"

class AluPacket extends BaseTransaction;

  rand data_t a, b;
  rand type_op op;
  data_t r;

  // flag for specifying the validity of the data fields.
  bit is_response;

  constraint ab_dist_c {
    a dist {
      0                         := 10,
      [1:(64'd1<<DATA_WIDTH)-2] :/ 1,
      (64'd1<<(DATA_WIDTH-1))-1 := 10,
      (64'd1<<DATA_WIDTH)-1     := 10
      };
    b dist {
      0                         := 10,
      [1:(64'd1<<DATA_WIDTH)-2] :/ 1,
      (64'd1<<(DATA_WIDTH-1))-1 := 10,
      (64'd1<<DATA_WIDTH)-1     := 10
    };
  };

  function new(input bit is_response=0);
    this.is_response = is_response;
  endfunction

  virtual function bit compare(input BaseTransaction to);
    AluPacket other;
    $cast(other, to);

    return (this.r == other.r);
  endfunction : compare

  virtual function BaseTransaction copy(input BaseTransaction to=null);
    AluPacket dst;

    if (to == null)
      dst = new();
    else
      $cast(dst, to);

    dst.a = this.a;
    dst.b = this.b;
    dst.r = this.r;
    dst.op = this.op;

    return dst;
  endfunction : copy

  virtual function void display(input string prefix="");
    if (is_response)
      $display("%sPacket id=%0d: { r=%x }", prefix, id, r);
    else
      $display("%sPacket id=%0d: { a=%x, b=%x, r=%x, op=%s }", prefix, id, a, b, r, op.name());
  endfunction : display

endclass

`endif
