/**
 * Copyright (c) 2023 Politecnico di Torino
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * File              : test.sv
 * Author            : Fabio Scatozza <s315216@studenti.polito.it>
 * Date              : 11.06.2023
 * Last Modified Date: 11.06.2023
 * ---------------------------------------------------------------------------
 * The program steps through all the phases of the simulation, as defined by
 * the Environment.
 */

`include "AluEnvironment.sv"

program automatic test (alu_if ifc);
  AluEnvironment env;

  initial begin
    // instantiate the environment
    env = new(ifc.tb);

    // build the transactors
    env.build();

    // start the transactors
    env.run();

    // terminate
    env.wrap_up();
  end

endprogram
