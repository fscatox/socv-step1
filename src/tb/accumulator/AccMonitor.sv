/**
 * Copyright (c) 2023 Politecnico di Torino
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * File              : AccMonitor.sv
 * Author            : Fabio Scatozza <s315216@studenti.polito.it>
 * Date              : 13.06.2023
 * Last Modified Date: 13.06.2023
 * ---------------------------------------------------------------------------
 * Class in charge of capturing the response of the DUT, packing it in
 * a high-level transaction.
 */

`ifndef ACCMONITOR_SV
`define ACCMONITOR_SV

`include "../Callback.svh"
`include "AccPacket.sv"
`include "acc_if.svh"

class AccMonitor;
  v_acctb_if tb;               // Interface to the DUT
  Callback#(AccPacket) cbq[$]; // queue of callback objects

  function new(input v_acctb_if tb);
    this.tb = tb;
  endfunction

  // capture the response
  task capture(output AccPacket pk);
    // allocate the packet where to store the response
    pk = new(.is_response(1));

    @(tb.cb); // synchronize
    pk.y = tb.y;

  endtask

  // capture the response and pack it in a transaction
  task run();
    AccPacket pk;

    forever begin

      capture(pk);
      pk.display($sformatf("@%0t: Monitor: ", $time));

      // run post-callbacks
      foreach (cbq[i])
        cbq[i].post(this, pk);

    end
  endtask : run

endclass

`endif


