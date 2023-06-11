/**
 * Copyright (c) 2023 Politecnico di Torino
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * File              : AluEnvironment.sv
 * Author            : Fabio Scatozza <s315216@studenti.polito.it>
 * Date              : 11.06.2023
 * Last Modified Date: 11.06.2023
 * ---------------------------------------------------------------------------
 * The environment encapsulates all the blocks of the layered testbench. It
 * simulates evrything that is not inside the DUT, making it possible to run
 * a certain testbench program.
 */

`ifndef ALU_ENVIRONMENT_PKG_SV
`define ALU_ENVIRONMENT_PKG_SV

`include "AluDriver.sv"
`include "AluMonitor.sv"
`include "AluScoreboard.sv"
`include "AluScoreboardCallbacks.sv"
`include "AluGenerator.sv"
`include "AluCoverage.sv"

class AluEnvironment;
  vtb_if tb;
  AluConfig cfg;

  mailbox gen2drv;
  event drv2gen;

  AluGenerator gen;
  AluDriver drv;
  AluMonitor mon;
  AluScoreboard scb;

  AluCoverage cov;

  // load the configuration from command line
  function new (input vtb_if tb);

    // instantiated in the top module
    this.tb = tb;

    cfg = new(DATA_WIDTH);
    cfg.display();
  endfunction : new

  // build the environment
  function void build();
    gen2drv = new();
    cov = new();

    gen = new(gen2drv, drv2gen, cfg.n_packets);
    drv = new(gen2drv, drv2gen, tb);
    mon = new(tb);
    scb = new(cfg);

    // register the scoreboard callbacks
    begin
      AluScbDriverCb scb_drv_cb = new(scb);
      AluScbMonitorCb scb_mon_cb = new(scb);
      drv.cbq.push_back(scb_drv_cb);
      mon.cbq.push_back(scb_mon_cb);
    end

    begin
      // register the coverage callback
      AluCovMonitorCb cov_mon_cb = new(cov);
      mon.cbq.push_back(cov_mon_cb);
    end
   endfunction : build

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
     mon.run();
   join_none

   // wait for generators to finish or time-out
   fork : timeout_block
     wait(num_gen_running == 0);
     begin
       repeat (100*cfg.n_packets) @(tb.cb);
       $display("@%0t: %m ERROR: Timeout elapsed while waiting for the generator to finish", $time);
       cfg.n_errors++;
     end
   join_any

   disable timeout_block;

   // wait for data to flow through the environment
   repeat (10*cfg.n_packets) @(tb.cb);
 endtask : run

 function void wrap_up();
   $display("@%0t: End of simulation: %0d error(s)", $time, cfg.n_errors);
   scb.wrap_up();
 endfunction : wrap_up

endclass

`endif
