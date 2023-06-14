/**
 * Copyright (c) 2023 Politecnico di Torino
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * File              : acc_test.sv
 * Author            : Fabio Scatozza <s315216@studenti.polito.it>
 * Date              : 13.06.2023
 * Last Modified Date: 14.06.2023
 * ---------------------------------------------------------------------------
 * The program steps through all the phases of the simulation, as defined by
 * the AluEnvironment.
 */

`include "AccEnvironment.sv"

program automatic acc_test (acc_if ifci, input event dut_ready);
  AccEnvironment env;

  initial begin
    // instantiate the environment
    env = new(ifc.tb);

    // build the transactors
    env.build();

    // start the transactors
    @dut_ready;
    env.run();

    // terminate
    env.wrap_up();

    $stop;
  end

endprogram

