/**
 * Copyright (c) 2023 Politecnico di Torino
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * File              : AluMonitor.sv
 * Author            : Fabio Scatozza <s315216@studenti.polito.it>
 * Date              : 11.06.2023
 * Last Modified Date: 14.06.2023
 * ---------------------------------------------------------------------------
 * Class in charge of capturing the response of the DUT, packing it in
 * a high-level transaction.
 */

`ifndef ALUMONITOR_SV
`define ALUMONITOR_SV

`include "../Callback.svh"
`include "AluPacket.sv"
`include "alu_if.svh"


class AluMonitor;
  v_alutb_if tb;               // Interface to the DUT
  Callback#(AluPacket) cbq[$]; // queue of callback objects

  function new(input v_alutb_if tb);
    this.tb = tb;
  endfunction

  // capture the response
  task capture(output AluPacket pk);
    // allocate the packet where to store the response
    pk = new(.is_response(1));

    @(tb.cb); // synchronize
    pk.r = tb.r;

  endtask

  // capture the response and pack it in a transaction
  task run();
    AluPacket pk;

    forever begin
      // run pre-callbacks
      foreach (cbq[i])
        cbq[i].pre(pk);

      capture(pk);
      pk.display($sformatf("@%0t: Monitor: ", $time));

      // run post-callbacks
      foreach (cbq[i])
        cbq[i].post(pk);

    end
  endtask : run

endclass

`endif
