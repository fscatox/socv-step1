/**
 * Copyright (c) 2023 Politecnico di Torino
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * File              : AluScoreboard.sv
 * Author            : Fabio Scatozza <s315216@studenti.polito.it>
 * Date              : 11.06.2023
 * Last Modified Date: 11.06.2023
 * ---------------------------------------------------------------------------
 * The Scoreboard connects via callbacks to the driver and the monitor. It
 * collects the expected and actual DUT's reponses, then it performs a
 * comparison check.
 */

`ifndef ALUSCOREBOARD_SV
`define ALUSCOREBOARD_SV

`include "AluConfig.sv"
`include "AluPacket.sv"

class AluScoreboard;
  AluConfig cfg;
  AluPacket xpected[$];

  int unsigned n_xpected, n_actual;

  function new(AluConfig cfg);
    this.cfg = cfg;
  endfunction

  function void save_xpected(input AluPacket pk);
    pk.display($sformatf("@%0t: AluScoreboard save: ", $time));

    // save the packet the driver is going to use
    xpected.push_back(pk);
    n_xpected++;
  endfunction : save_xpected

  function void check_actual(input AluPacket other);
    AluPacket xpk; // host the expected packet

    other.display($sformatf("@%0t: AluScoreboard check: ", $time));

    // packet lost ?
    if (!xpected.size()) begin
      $display("@%0t: ERROR: %m expected queue is empty", $time);
      cfg.n_errors++;
      return;
    end

    xpk = xpected.pop_front();
    xpk.display($sformatf("                  against: "));
    n_actual++;

    if (!xpk.compare(other)) begin
      $display("@%0t: ERROR: packets mismatch", $time);
      cfg.n_errors++;
      return;
    end

    // match
    $display("@%0t: OK: packets match", $time);
    return;

  endfunction : check_actual

  function void wrap_up();
    $display("@%0t: %m %0d expected packets, %0d received packets", $time, n_xpected, n_actual);

    if (xpected.size()) begin
      cfg.n_errors++;
      foreach (xpected[i]) begin
        xpected[i].display("Unclaimed: ");
      end
    end

  endfunction : wrap_up

endclass;

`endif
