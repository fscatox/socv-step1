/**
 * Copyright (c) 2023 Politecnico di Torino
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * File              : AluDriver.sv
 * Author            : Fabio Scatozza <s315216@studenti.polito.it>
 * Date              : 11.06.2023
 * Last Modified Date: 11.06.2023
 * ---------------------------------------------------------------------------
 * Class in charge of applying the stimulus to the DUT, translating from the
 * high-level transactions received.
 *
 * Callbacks are used to inject new behavior in the driver, without having to
 * change its code. They are processed before and after a transaction is
 * sent to the DUT.
 */

`ifndef ALUDRIVER_SV
`define ALUDRIVER_SV

`include "AluPacket.sv"
`include "walu_if.svh"

typedef class AluDriver; // cyclic compilation dependency

class AluDriverCallback;

  virtual task pre(input AluDriver drv, input AluPacket pk);
  endtask : pre

  virtual task post(input AluDriver drv, input AluPacket pk);
  endtask : post

endclass

class AluDriver;
  mailbox gen2drv;    // Channel for incoming transactions
  event drv2gen;      // Let the generator know when the driver's done with the transaction

  vtb_if tb;                // Interface to the DUT
  AluDriverCallback cbq[$]; // queue of callback objects

  function new(input mailbox gen2drv, input event drv2gen, input vtb_if tb);
    this.gen2drv = gen2drv;
    this.drv2gen = drv2gen;
    this.tb = tb;
  endfunction : new

  // apply the stimulus
  task apply(input AluPacket pk);

    // synchronize
    @(tb.cb);

    tb.cb.op <= pk.op;
    tb.cb.a <= pk.a;
    tb.cb.b <= pk.b;

  endtask : apply

  // get a transaction from the generator and apply it to the DUT
  task run();
    AluPacket pk;

    forever begin
      // look in the mailbox
      gen2drv.peek(pk);

      begin : apply_pk
        // run pre-callbacks
        foreach (cbq[i])
          cbq[i].pre(this, pk);

        pk.display($sformatf("@%0t: Driver: ", $time));
        apply(pk);

        // run post-callbacks
        foreach (cbq[i])
          cbq[i].post(this, pk);
      end : apply_pk

      // remove transaction from the mailbox
      gen2drv.get(pk);
      // let the generator know
      ->drv2gen;
    end
  endtask : run

endclass

`endif
