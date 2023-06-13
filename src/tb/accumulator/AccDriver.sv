/**
 * Copyright (c) 2023 Politecnico di Torino
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * File              : AccDriver.sv
 * Author            : Fabio Scatozza <s315216@studenti.polito.it>
 * Date              : 13.06.2023
 * Last Modified Date: 13.06.2023
 * ---------------------------------------------------------------------------
 * Class in charge of applying the stimulus to the DUT, translating from the
 * high-level transactions received.
 *
 * Callbacks are used to inject new behavior in the driver, without having to
 * change its code. They are processed before and after a transaction is
 * sent to the DUT.
 */

`ifndef ACCDRIVER_SV
`define ACCDRIVER_SV

`include "../Callback.svh"
`include "AccPacket.sv"
`include "acc_if.svh"

class AccDriver;
  mailbox gen2drv;    // Channel for incoming transactions
  event drv2gen;      // Let the generator know when the driver's done with the transaction

  v_acctb_if tb;                   // Interface to the DUT
  Callback#(AccPacket) cbq[$]; // queue of callback objects

  function new(input mailbox gen2drv, input event drv2gen, input v_acctb_if tb);
    this.gen2drv = gen2drv;
    this.drv2gen = drv2gen;
    this.tb = tb;
  endfunction : new

  // apply the stimulus
  task apply(input AccPacket pk);

    // synchronize
    @(tb.cb);

    tb.cb.a <= pk.a;
    tb.cb.b <= pk.b;
    tb.cb.acc <= pk.acc;
    tb.cb.acc_en_n <= pk.acc_en_n;
    tb.cb.rst_n <= pk.rst_n;

  endtask : apply

  // get a transaction from the generator and apply it to the DUT
  task run();
    AccPacket pk;

    forever begin
      // look in the mailbox
      gen2drv.peek(pk);

      begin : apply_pk
        // run pre-callbacks
        foreach (cbq[i])
          cbq[i].pre(pk);

        pk.display($sformatf("@%0t: Driver: ", $time));
        apply(pk);

        // run post-callbacks
        foreach (cbq[i])
          cbq[i].post(pk);
      end : apply_pk

      // remove transaction from the mailbox
      gen2drv.get(pk);
      // let the generator know
      ->drv2gen;
    end
  endtask : run

endclass

`endif
