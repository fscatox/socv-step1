/**
 * Copyright (c) 2023 Politecnico di Torino
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * File              : AluScoreboardCallbacks.sv
 * Author            : Fabio Scatozza <s315216@studenti.polito.it>
 * Date              : 11.06.2023
 * Last Modified Date: 11.06.2023
 * ---------------------------------------------------------------------------
 * Callback classes used to connect driver and monitor to the scoreboard
 */

`ifndef ALUSCOREBOARDCALLBACKS_SV
`define ALUSCOREBOARDCALLBACKS_SV

`include "AluScoreboard.sv"
`include "AluDriver.sv"
`include "AluMonitor.sv"

class AluScbDriverCb extends AluDriverCallback;
  localparam  int mULT_WIDTH = DATA_WIDTH/2;
  AluScoreboard scb;

  function new (AluScoreboard scb);
    this.scb = scb;
  endfunction

  // Fill the packet and save it in the scoreboard
  virtual task post(input AluDriver drv, input AluPacket pk);
    const int shift_diff = DATA_WIDTH - pk.b;

    case (pk.op)
      /* arithemtic operations */
      add     : pk.r = pk.a  + pk.b;
      sub     : pk.r = pk.a  - pk.b;
      mult    : pk.r = pk.a[mULT_WIDTH-1:0] * pk.b[mULT_WIDTH-1:0];

      /* bitwise operations */
      bitand  : pk.r = pk.a & pk.b;
      bitor   : pk.r = pk.a | pk.b;
      bitxor  : pk.r = pk.a ^ pk.b;

      /* logical shift operations */
      funclsl : pk.r = pk.a << pk.b;
      funclsr : pk.r = pk.a >> pk.b;

      /* rotate operations */
      funcrl  : begin
        pk.r = pk.a << pk.b;
        pk.r |= (shift_diff <= 0) ? 0 : (pk.a >> shift_diff);
      end
      funcrr  : begin
        pk.r = pk.a >> pk.b;
        pk.r |= (shift_diff <= 0) ? 0 : (pk.a << shift_diff);
      end

      // with other operations, return 0
      default : pk.r = 0;
    endcase

    scb.save_xpected(pk);
  endtask : post
endclass

class AluScbMonitorCb extends AluMonitorCallback;
  AluScoreboard scb;

  function new(AluScoreboard scb);
    this.scb = scb;
  endfunction

  // send packet to the scoreboard
  virtual task post(input AluMonitor drv, input AluPacket pk);
    scb.check_actual(pk);
  endtask : post

endclass

`endif

