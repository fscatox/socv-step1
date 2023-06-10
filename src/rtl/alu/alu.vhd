-- Authors           : Fabio Scatozza   <s315216@studenti.polito.it>
--                     Isacco Delpero   <s314713@studenti.polito.it>
--                     Leonardo Cerruti <s317664@studenti.polito.it>
-- Date              : 21.03.2023
-- Last Modified Date: 10.06.2023
--
-- Copyright (c) 2023 Politecnico di Torino
--
-- This source code is licensed under the BSD-style license found in the
-- LICENSE file in the root directory of this source tree. 

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.type_alu.all;

entity alu is
  generic (n : integer);
  port ( 
    func:         in  type_op;
    data1, data2: in  std_logic_vector(n-1 downto 0);
    outalu:       out std_logic_vector(n-1 downto 0)
  );
end entity;

architecture behavioral of alu is
begin

  -- We check that the provided n generic is an even number
  assert (n rem 2 = 0)
  report "Alu parallelism should be a multiple of 2"
  severity failure;

  -- each function is described in a behavioral way, with proper data casting (to use the numeric_std package,
  -- which is the standard package, each operand must be either signed or unsigned)
  p_alu: process (func, data1, data2)
  begin
    case func is
      when add     =>
        outalu <= std_logic_vector(unsigned(data1) + unsigned(data2));
      when sub     =>
        outalu <= std_logic_vector(unsigned(data1) - unsigned(data2));
      when mult    =>
        outalu <= std_logic_vector(unsigned(data1(n/2-1 downto 0))*unsigned(data2(n/2-1 downto 0)));
      when bitand  =>
        outalu <= data1 and data2;
      when bitor   =>
        outalu <= data1 or data2;
      when bitxor  =>
        outalu <= data1 xor data2;
      when funclsl =>
        outalu <= std_logic_vector(shift_left(unsigned(data1), to_integer(unsigned(data2))));
      when funclsr =>
        outalu <= std_logic_vector(shift_right(unsigned(data1), to_integer(unsigned(data2))));
      when funcrl  =>
        outalu <= std_logic_vector(rotate_left(unsigned(data1), to_integer(unsigned(data2))));
      when funcrr  =>
        outalu <= std_logic_vector(rotate_right(unsigned(data1), to_integer(unsigned(data2))));
      when others  => null;
    end case; 
  end process;
end architecture;

