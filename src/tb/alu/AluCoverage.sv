/**
 * Copyright (c) 2023 Politecnico di Torino
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * File              : AluCoverage.sv
 * Author            : Fabio Scatozza <s315216@studenti.polito.it>
 * Date              : 11.06.2023
 * Last Modified Date: 13.06.2023
 * ---------------------------------------------------------------------------
 * Coverage class to gather information on how effective the generated
 * stimulus is for exercising the DUT's functionality.
 *
 * Covergroup sampling is injected as an additional functionality into the
 * monitor.
 */

`ifndef ALUCOVERAGE_SV
`define ALUCOVERAGE_SV

`include "AluPacket.sv"
`include "AluDriver.sv"

class AluCoverage;
  AluPacket pk;

  covergroup driver_packet_cg;
    op_cp : coverpoint pk.op; // automatically create bins for the enumerators

    a_cp : coverpoint pk.a {
      bins zero     = {0};
      bins max      = {(64'd1<<DATA_WIDTH)-1};
      bins others   = default; // ignored values for coverage
    }

    b_cp : coverpoint pk.b {
      bins zero     = {0};
      bins max      = {(64'd1<<DATA_WIDTH)-1};
      bins others   = default; // ignored values for coverage
    }
  endgroup

  // instantiate the covergroup
  function new();
    driver_packet_cg = new;
  endfunction

  // sample command
  function void sample(input AluPacket pk);
    pk.display($sformatf("@%0t: Coverage: ", $time));

    // grab object
    this.pk = pk;
    // sample locally
    driver_packet_cg.sample();
  endfunction : sample
endclass : AluCoverage

class AluCovDriverCb
 extends Callback#(AluPacket);

  AluCoverage cov;

  function new(AluCoverage cov);
    this.cov = cov;
  endfunction

  // send packet to coverage
  virtual task pre(input AluPacket tr);
    cov.sample(tr);
  endtask : pre
endclass : AluCovDriverCb

`endif
