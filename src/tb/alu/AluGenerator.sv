/**
 * Copyright (c) 2023 Politecnico di Torino
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * File              : AluGenerator.sv
 * Author            : Fabio Scatozza <s315216@studenti.polito.it>
 * Date              : 10.06.2023
 * Last Modified Date: 10.06.2023
 * ---------------------------------------------------------------------------
 * The generator orchestrates all the steps within the environment.
 */

`ifndef ALUGENERATOR_SV
`define ALUGENERATOR_SV

`include "AluPacket.sv"
`include "../rpt.svh"

class AluGenerator;
  AluPacket blueprint;
  mailbox gen2drv;  // fifo to the driver for sending transactions
  event drv2gen;    // synchronization channel from the driver
  int n_tr;         // number of transactions to be generated

  function new(
    input mailbox gen2drv,
    input event drv2gen,
    input int n_tr);

    this.gen2drv = gen2drv;
    this.drv2gen = drv2gen;
    this.n_tr = n_tr;
    blueprint = new();
  endfunction : new

  task run();
    AluPacket pk; // host the cloned blueprint

    repeat (n_tr) begin
      `SV_RAND_CHECK(blueprint.randomize()); // so to keep randomization history
      pk = new blueprint;              // then, copy

      pk.display($sformatf("@%0t: Generator: ", $time));

      gen2drv.put(pk); // send the transaction
      @drv2gen;        // the driver has finished with it
    end;

  endtask : run
endclass

`endif
