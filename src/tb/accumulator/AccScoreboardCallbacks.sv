/**
 * Copyright (c) 2023 Politecnico di Torino
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * File              : AccScoreboardCallbacks.sv
 * Author            : Fabio Scatozza <s315216@studenti.polito.it>
 * Date              : 13.06.2023
 * Last Modified Date: 13.06.2023
 * ---------------------------------------------------------------------------
 * Callback classes used to connect driver and monitor to the scoreboard
 */

`ifndef ACCSCOREBOARDCALLBACKS_SV
`define ACCSCOREBOARDCALLBACKS_SV

`include "../Scoreboard.sv"
`include "AccDriver.sv"
`include "AccMonitor.sv"

class AccScbDriverCb
  extends Callback#(AccPacket);

  Scoreboard#(AccPacket) scb;

  // memory element for replicating locally DUT's behavior
  data_t mem_y;

  function new (Scoreboard#(AccPacket) scb);
    this.scb = scb;
    mem_y = 0;
  endfunction

  // Generate the result, fill the packet and save it in the scoreboard
  virtual task post(input AccPacket tr);

    if (!tr.rst_n)
      tr.y = 0;
    else if (tr.acc_en_n)
      tr.y = mem_y;
    else begin
      if (tr.acc) tr.y = tr.a + mem_y;
      else        tr.y = tr.a + tr.b;
    end

    mem_y = tr.y;         // update local memory element
    scb.save_xpected(tr); // save transaction
  endtask : post

endclass : AccScbDriverCb

class AccScbMonitorCb
  extends Callback#(AccPacket);

  Scoreboard#(AccPacket) scb;

  function new(Scoreboard#(AccPacket) scb);
    this.scb = scb;
  endfunction

  // send response packet to the scoreboard
  virtual task post(input AccPacket tr);
    scb.check_actual(tr);
  endtask : post

endclass : AccScbMonitorCb

`endif

