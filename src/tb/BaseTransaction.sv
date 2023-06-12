/**
 * Copyright (c) 2023 Politecnico di Torino
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * File              : BaseTransaction.sv
 * Author            : Fabio Scatozza <s315216@studenti.polito.it>
 * Date              : 10.06.2023
 * Last Modified Date: 12.06.2023
 * ---------------------------------------------------------------------------
 * Base class for transaction objects passed around in the testbench
 */

`ifndef BASETRANSACTION_SV
`define BASETRANSACTION_SV

  virtual class BaseTransaction;
    // number of transactions created
    static int unsigned count = 0;
    // unique identifier of the transaction
    int unsigned id;

    function new();
      id = count++;
    endfunction

    pure virtual function bit compare(input BaseTransaction to);
    pure virtual function BaseTransaction copy(input BaseTransaction to=null);
    pure virtual function void display(input string prefix="");

  endclass

`endif
