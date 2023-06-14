/**
 * Copyright (c) 2023 Politecnico di Torino
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * File              : BaseEnvironment.sv
 * Author            : Fabio Scatozza <s315216@studenti.polito.it>
 * Date              : 13.06.2023
 * Last Modified Date: 13.06.2023
 * ---------------------------------------------------------------------------
 * The environment encapsulates all the blocks of the layered testbench. It
 * simulates evrything that is not inside the DUT, making it possible to run
 * a certain testbench program.
 */

`ifndef BASE_ENVIRONMENT_SV
`define BASE_ENVIRONMENT_SV

`include "BaseTransaction.sv"
`include "Generator.sv"
`include "Scoreboard.sv"

class BaseDriver; endclass
class BaseMonitor; endclass
class VirtualInterface; endclass

virtual class BaseEnvironment #(
    type T = BaseTransaction,
    type D = BaseDriver,
    type M = BaseMonitor,
    type I = VirtualInterface
);

  I tb;
  Config cfg;

  mailbox gen2drv;
  event drv2gen;

  Generator #(T) gen;
  D drv;
  M mon;
  Scoreboard #(T) scb;

  // build the environment
  pure virtual function void build();

  // start all transactors in the environment
  task run();
    int num_gen_running = 1;

    // each tansactor in its own thread
    fork
      begin
        gen.run();
        num_gen_running--;
      end

      drv.run();

      // one-cycle delay
      begin
        @(tb.cb);
        mon.run();
      end
    join_none

    // wait for generators to finish or time-out
    fork : timeout_block
      wait (num_gen_running == 0);
      begin
        repeat (100 * cfg.n_packets) @(tb.cb);
        $display("@%0t: %m ERROR: Timeout elapsed while waiting for the generator to finish",
                 $time);
        cfg.n_errors++;
      end
    join_any

    disable timeout_block;

    // wait for data to flow through the environment
    @(tb.cb);
  endtask : run

  function void wrap_up();
    const string prefix = $sformatf("@%0t: ", $time);
    scb.wrap_up();

    $display({prefix, "END OF SIMULATION"});
    $display({{prefix.len{" "}}, $sformatf("  * %0d error(s)", cfg.n_errors)});
    $display({{prefix.len{" "}}, $sformatf("  * total functional coverage: %.2f%%", $get_coverage)});
    $display;

  endfunction : wrap_up

endclass

`endif
