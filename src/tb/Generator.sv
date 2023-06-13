/**
 * Copyright (c) 2023 Politecnico di Torino
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * File              : Generator.sv
 * Author            : Fabio Scatozza <s315216@studenti.polito.it>
 * Date              : 13.06.2023
 * Last Modified Date: 13.06.2023
 * ---------------------------------------------------------------------------
 * Generates the random transactions and dispatches them to the driver.
 * The class is templated so to support multiple transaction types.
 */

`ifndef GENERATOR_SV
`define GENERATOR_SV

`include "rpt.svh"
`include "BaseTransaction.sv"

class Generator
  #(type T = BaseTransaction);

  T blueprint;
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
    T tr; // host the cloned blueprint

    repeat (n_tr) begin
      `SV_RAND_CHECK(blueprint.randomize()); // so to keep randomization history
      $cast(tr, blueprint.copy()); // then, copy

      tr.display($sformatf("@%0t: Generator: ", $time));

      gen2drv.put(tr); // send the transaction
      @drv2gen;        // the driver has finished with it
    end;

  endtask : run
endclass

`endif

