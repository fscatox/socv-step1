/**
 * Copyright (c) 2023 Politecnico di Torino
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * File              : AluEnvironment.sv
 * Author            : Fabio Scatozza <s315216@studenti.polito.it>
 * Date              : 11.06.2023
 * Last Modified Date: 13.06.2023
 * ---------------------------------------------------------------------------
 * Child of "BaseEnvironment" abstract class.
 * BaseEnvironment templates are defined based on the actual testbench
 * components. Thus BaseEnvironment::build() is now meaningful.
 */

`ifndef ALUENVIRONMENT_SV
`define ALUENVIRONMENT_SV

`include "../BaseEnvironment.sv"
`include "AluPacket.sv"
`include "AluDriver.sv"
`include "AluMonitor.sv"
`include "AluCoverage.sv"
`include "AluScoreboardCallbacks.sv"
`include "alu_if.svh"

class AluEnvironment
  extends BaseEnvironment #(AluPacket, AluDriver, AluMonitor, v_alutb_if);

  AluCoverage cov;

  AluScbDriverCb scb_drv_cb;
  AluScbMonitorCb scb_mon_cb;
  AluCovDriverCb cov_drv_cb;

  // load the configuration from command line
  function new(input v_alutb_if tb);

    // instantiated in the top module
    this.tb = tb;

    cfg = new(DATA_WIDTH);
    cfg.display();
  endfunction : new

  // build the environment
  virtual function void build();
    gen2drv = new();
    cov = new();

    gen = new(gen2drv, drv2gen, cfg.n_packets);
    drv = new(gen2drv, drv2gen, tb);
    mon = new(tb);
    scb = new(cfg);

    scb_drv_cb = new(scb);
    scb_mon_cb = new(scb);
    cov_drv_cb = new(cov);

    // register the scoreboard callbacks
    drv.cbq.push_back(scb_drv_cb);
    mon.cbq.push_back(scb_mon_cb);

    // register the coverage callback
    drv.cbq.push_back(cov_drv_cb);

  endfunction : build

endclass

`endif

