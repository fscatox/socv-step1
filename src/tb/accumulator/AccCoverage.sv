/**
 * Copyright (c) 2023 Politecnico di Torino
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * File              : AccCoverage.sv
 * Author            : Fabio Scatozza <s315216@studenti.polito.it>
 * Date              : 13.06.2023
 * Last Modified Date: 13.06.2023
 * ---------------------------------------------------------------------------
 * Coverage class for gathering information on how effective the generated
 * stimulus is for exercising the DUT's functionality.
 *
 * Covergroup sampling is injected as additional functionality into the
 * monitor.
 */

`ifndef ACCCOVERAGE_SV
`define ACCCOVERAGE_SV

`include "../Callback.svh"
`include "AccPacket.sv"
`include "AccDriver.sv"

class AccCoverage;
  AccPacket pk;

  covergroup driver_packet_cg;

    // accumulator inputs,
    // when out of reset and not in memory state
    a_cp : coverpoint pk.a iff (pk.rst_n && pk.acc_en_n) {
      bins zero     = {0};
      bins one      = {1};
      bins max      = {(64'd1<<DATA_WIDTH)-1};
      bins others   = default; // ignored values for coverage
    }

    b_cp : coverpoint pk.b iff (pk.rst_n && pk.acc_en_n) {
      bins zero     = {0};
      bins one      = {1};
      bins max      = {(64'd1<<DATA_WIDTH)-1};
      bins others   = default; // ignored values for coverage
    }

    rst_n_cp : coverpoint pk.rst_n {
      bins reset_sequence = (1 => 0 => 1);
    }

    // accumulator states
    acc_cp : coverpoint pk.acc iff (pk.rst_n) {
      option.weight = 0; // don't count this coverpoint alone
    }
    acc_en_n_cp : coverpoint pk.acc_en_n iff (pk.rst_n) {
      option.weight = 0; // don't count this coverpoint alone
    }

    cross acc_cp, acc_en_n_cp {
      bins memory_state     = binsof(acc_en_n_cp) intersect {1};

      bins sum_state        = binsof(acc_cp) intersect {0} &&
                              binsof(acc_en_n_cp) intersect {1};

      bins accumulate_state = binsof(acc_cp) intersect {1} &&
                              binsof(acc_en_n_cp) intersect {1};
    }

  endgroup

  // instantiate the covergroup
  function new();
    driver_packet_cg = new;
  endfunction

  // sample command
  function void sample(input AccPacket pk);
    pk.display($sformatf("@%0t: Coverage: ", $time));

    // grab object
    this.pk = pk;

    // sample locally
    driver_packet_cg.sample();
  endfunction : sample
endclass : AccCoverage

class AccCovDriverCb
  extends Callback#(AccPacket);

  AccCoverage cov;

  function new(AccCoverage cov);
    this.cov = cov;
  endfunction

  // send packet to coverage
  virtual task pre(input AccPacket tr);
    cov.sample(tr);
  endtask : pre
endclass : AccCovDriverCb

`endif

