/**
 * Copyright (c) 2023 Politecnico di Torino
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * File              : walu_pkg.sv
 * Author            : Fabio Scatozza <s315216@studenti.polito.it>
 * Date              : 10.06.2023
 * Last Modified Date: 12.06.2023
 * ---------------------------------------------------------------------------
 * Data types and configuration parameters for the SystemVerilog wrapper
 * of the VHDL alu under test.
 *
 * These parameters must be available at compile-time, therefore it's not
 * possible to randomize them trivially: it would be required to write a class
 * that randomizes the parameter and the export it in a package.
 */

`ifndef WALU_PKG_SV
`define WALU_PKG_SV

package walu_pkg;

  // Data parallelism configuration
  parameter int unsigned DATA_WIDTH = 32;
  typedef logic [DATA_WIDTH-1:0] data_t;

endpackage

`endif
