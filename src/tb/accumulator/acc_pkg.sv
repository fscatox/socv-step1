/**
 * Copyright (c) 2023 Politecnico di Torino
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * File              : acc_pkg.sv
 * Author            : Fabio Scatozza <s315216@studenti.polito.it>
 * Date              : 13.06.2023
 * Last Modified Date: 13.06.2023
 * ---------------------------------------------------------------------------
 * "acc"-related data types and configuration parameters.
 *
 * These parameters must be available at compile-time, therefore it's not
 * possible to randomize them trivially: it would be required to write a class
 * that randomizes the parameter and the export it in a package.
 */

`ifndef ACC_PKG_SV
`define ACC_PKG_SV

package acc_pkg;

  // Data parallelism configuration
  parameter int unsigned DATA_WIDTH = 32;
  typedef logic [DATA_WIDTH-1:0] data_t;

endpackage

`endif

