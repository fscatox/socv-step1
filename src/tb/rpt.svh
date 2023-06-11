/**
 * Copyright (c) 2023 Politecnico di Torino
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * File              : rpt.svh
 * Author            : Fabio Scatozza <s315216@studenti.polito.it>
 * Date              : 10.06.2023
 * Last Modified Date: 10.06.2023
 * Reference         : SystemVerilog for Verification: A Guide to Learning
 *                     the Testbench Language Features,
 *                     by Chris Spear, Greg Tumbush
 * ---------------------------------------------------------------------------
 * Collection of macros for complaining
 */

`define SV_RAND_CHECK(r) \
  do begin \
    if (!(r)) begin \
      $display("%s:%0d: Randomization failed \"%s\"", \
      `__FILE__, `__LINE__, `"r`"); \
      $finish; \
    end \
  end while (0)
