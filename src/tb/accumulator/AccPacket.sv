/**
 * Copyright (c) 2023 Politecnico di Torino
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * File              : AccPacket.sv
 * Author            : Fabio Scatozza <s315216@studenti.polito.it>
 * Date              : 13.06.2023
 * Last Modified Date: 13.06.2023
 * ---------------------------------------------------------------------------
 * Refined transaction for "acc".
 */

`ifndef ACCPACKET_SV
`define ACCPACKET_SV

`include "../BaseTransaction.sv"
import acc_pkg::*;

class AccPacket extends BaseTransaction;

  rand data_t a, b;
  rand bit acc, acc_en_n, rst_n;
  data_t y;

  // flag for specifying the validity of the data fields.
  bit is_response;

  constraint acc_dist_c {
    // skew a, b towards corner cases
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

    // skew towards overflow
    acc dist {1 := 10, 0 := 1};
    acc_en_n dist {0 := 10, 1 := 1};
    rst_n dist {0 := 1, 1 := 50};
  };

  function new(input bit is_response=0);
    this.is_response = is_response;
  endfunction

  virtual function bit compare(input BaseTransaction to);
    AccPacket other;
    $cast(other, to);

    return (this.y == other.y);
  endfunction : compare

  virtual function BaseTransaction copy(input BaseTransaction to=null);
    AccPacket dst;

    if (to == null)
      dst = new();
    else
      $cast(dst, to);

    dst.a = this.a;
    dst.b = this.b;
    dst.y = this.y;
    dst.acc = this.acc;
    dst.acc_en_n = this.acc_en_n;
    dst.rst_n = this.rst_n;
    dst.is_response = this.is_response;

    return dst;
  endfunction : copy

  virtual function void display(input string prefix="");
    if (is_response)
      $display("%sPacket id=%0d: { y=%x }", prefix, id, y);
    else
      $display("%sPacket id=%0d: { a=%x, b=%x, y=%x, acc=%b, acc_en_n=%b, rst_n=%b }",
        prefix, id, a, b, y, acc, acc_en_n, rst_n);
  endfunction : display

endclass

`endif

