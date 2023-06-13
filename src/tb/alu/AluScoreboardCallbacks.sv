/**
 * Copyright (c) 2023 Politecnico di Torino
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * File              : AluScoreboardCallbacks.sv
 * Author            : Fabio Scatozza <s315216@studenti.polito.it>
 * Date              : 11.06.2023
 * Last Modified Date: 13.06.2023
 * ---------------------------------------------------------------------------
 * Callback classes used to connect driver and monitor to the scoreboard
 */

`ifndef ALUSCOREBOARDCALLBACKS_SV
`define ALUSCOREBOARDCALLBACKS_SV

`include "../Scoreboard.sv"
`include "AluDriver.sv"
`include "AluMonitor.sv"

class AluScbDriverCb
  extends Callback#(AluPacket);

  localparam  int MultWidth = DATA_WIDTH/2;
  Scoreboard#(AluPacket) scb;

  function new (Scoreboard#(AluPacket) scb);
    this.scb = scb;
  endfunction

  // Fill the packet and save it in the scoreboard
  virtual task post(input AluPacket tr);
    const int shift_norm = tr.b % DATA_WIDTH;

    case (tr.op)
      /* arithemtic operations */
      add     : tr.r = tr.a  + tr.b;
      sub     : tr.r = tr.a  - tr.b;
      mult    : tr.r = tr.a[MultWidth-1:0] * tr.b[MultWidth-1:0];

      /* bitwise operations */
      bitand  : tr.r = tr.a & tr.b;
      bitor   : tr.r = tr.a | tr.b;
      bitxor  : tr.r = tr.a ^ tr.b;

      /* logical shift operations */
      funclsl : tr.r = tr.a << tr.b;
      funclsr : tr.r = tr.a >> tr.b;

      /* rotate operations */
      funcrl  : begin
        tr.r = tr.a << shift_norm;
        tr.r |= tr.a >> (DATA_WIDTH - shift_norm);
      end
      funcrr  : begin
        tr.r = tr.a >> shift_norm;
        tr.r |= tr.a << (DATA_WIDTH - shift_norm);
      end

      // with other operations, return 0
      default : tr.r = 0;
    endcase

    scb.save_xpected(tr);
  endtask : post
endclass

class AluScbMonitorCb
  extends Callback#(AluPacket);

  Scoreboard#(AluPacket) scb;

  function new(Scoreboard#(AluPacket) scb);
    this.scb = scb;
  endfunction

  // send packet to the scoreboard
  virtual task post(input AluPacket tr);
    scb.check_actual(tr);
  endtask : post

endclass

`endif

