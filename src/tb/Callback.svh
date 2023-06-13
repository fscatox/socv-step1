/**
 * Copyright (c) 2023 Politecnico di Torino
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * File              : Callback.svh
 * Author            : Fabio Scatozza <s315216@studenti.polito.it>
 * Date              : 13.06.2023
 * Last Modified Date: 13.06.2023
 * ---------------------------------------------------------------------------
 * Callbacks are used to inject new behavior into a class, without having to
 * change its code.
 */

`ifndef CALLBACK_SVH
`define CALLBACK_SVH

`include "BaseTransaction.sv"

class Callback
  #(type TRANSACTION = BaseTransaction);

  virtual task pre(input TRANSACTION tr);
  endtask : pre

  virtual task post(input TRANSACTION tr);
  endtask : post

endclass

`endif
