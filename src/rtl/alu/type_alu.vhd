-- Authors           : Fabio Scatozza   <s315216@studenti.polito.it>
--                     Isacco Delpero   <s314713@studenti.polito.it>
--                     Leonardo Cerruti <s317664@studenti.polito.it>
-- Date              : 21.03.2023
-- Last Modified Date: 21.03.2023
--
-- Copyright (c) 2023 Politecnico di Torino
--
-- This source code is licensed under the BSD-style license found in the
-- LICENSE file in the root directory of this source tree. 

package type_alu is
  type type_op is (add, sub, mult, bitand, bitor, bitxor, funclsl, funclsr, funcrl, funcrr);
end package;
