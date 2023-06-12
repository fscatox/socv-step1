/**
 * Copyright (c) 2023 Politecnico di Torino
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * File              : AluMonitor.sv
 * Author            : Fabio Scatozza <s315216@studenti.polito.it>
 * Date              : 11.06.2023
 * Last Modified Date: 11.06.2023
 * ---------------------------------------------------------------------------
 * Class in charge of capturing the response of the DUT, packing it in
 * a high-level transaction.
 *
 * Callbacks are used to inject new behavior in the monitor, without having to
 * change its code. They are processed after a transaction is packed.
 */

`ifndef ALUMONITOR_SV
`define ALUMONITOR_SV

`include "AluPacket.sv"
`include "walu_if.svh"

typedef class AluMonitor; // cyclic compilation dependency

class AluMonitorCallback;

  virtual task post(input AluMonitor drv, input AluPacket pk);
  endtask : post

endclass

class AluMonitor;
  vtb_if tb;                 // Interface to the DUT
  AluMonitorCallback cbq[$]; // queue of callback objects

  function new(input vtb_if tb);
    this.tb = tb;
  endfunction

  // capture the response
  task capture(output AluPacket pk);

    @(tb.cb); // synchronize
    pk.r = tb.cb.r;

  endtask

  // capture the response and pack it in a transaction
  task run();
    AluPacket pk;

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
