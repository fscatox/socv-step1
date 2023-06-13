/**
 * Copyright (c) 2023 Politecnico di Torino
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * File              : Scoreboard.sv
 * Author            : Fabio Scatozza <s315216@studenti.polito.it>
 * Date              : 11.06.2023
 * Last Modified Date: 13.06.2023
 * ---------------------------------------------------------------------------
 * The Scoreboard connects via callbacks to the driver and the monitor. It
 * collects the expected and actual DUT's reponses, then it performs a
 * comparison check.
 */

`ifndef SCOREBOARD_SV
`define SCOREBOARD_SV

`include "Config.sv"
`include "BaseTransaction.sv"

class Scoreboard
  #(type T = BaseTransaction);

  Config cfg;
  T xpected[$];

  int unsigned n_xpected, n_actual;

  function new(Config cfg);
    this.cfg = cfg;
  endfunction

  function void save_xpected(input T tr);
    const string prefix = $sformatf("@%0t: Scoreboard: ", $time);
    tr.display({prefix, "save: "});

    // save the packet the driver used
    xpected.push_back(tr);
    n_xpected++;
  endfunction : save_xpected

  function void check_actual(input T other);
    const string prefix = $sformatf("@%0t: Scoreboard: ", $time);
    T xtr; // host the expected packet

    other.display({prefix, "check: "});

    // packet lost ?
    if (!xpected.size()) begin
      $display({{{prefix.len(){" "}}, "ERROR: expected queue is empty"}});
      $display;

      cfg.n_errors++;
      return;
    end

    xtr = xpected.pop_front();
    xtr.display({{prefix.len(){" "}}, "against: "});
    n_actual++;

    if (!xtr.compare(other)) begin
      $display({{prefix.len(){" "}}, "ERROR MISMATCH"});
      $display;

      cfg.n_errors++;
      return;
    end

    $display({{prefix.len(){" "}}, "MATCH"});
    $display;
    return;

  endfunction : check_actual

  function void wrap_up();
    const string prefix = $sformatf("@%0t: Scoreboard: ", $time);

    $write(prefix);
    $display("%0d expected packets, %0d received packets", n_xpected, n_actual);
    $display;

    if (xpected.size()) begin
      cfg.n_errors++;
      foreach (xpected[i]) begin
        xpected[i].display({{prefix.len(){" "}}, "unclaimed: "});
      end
    end

  endfunction : wrap_up

endclass;

`endif
