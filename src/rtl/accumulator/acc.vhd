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

entity acc is
  generic(
    numbit_g: positive
  );
  port (
    a:          in  std_logic_vector(numbit_g - 1 downto 0);
    b:          in  std_logic_vector(numbit_g - 1 downto 0);
    clk:        in  std_logic;
    rst_n:      in  std_logic;
    accumulate: in  std_logic;
    acc_en_n:   in  std_logic;
    y:          out std_logic_vector(numbit_g - 1 downto 0)
  );
end entity;

architecture behavioral of acc is
  signal mux_y, add_s, acc_y : std_logic_vector(numbit_g-1 downto 0);
begin
  mux_p : mux_y <= b when accumulate = '0' else
                   acc_y;

  add_p : add_s <= std_logic_vector(unsigned(a) + unsigned(mux_y));

  reg_p : process (clk) is -- chosen a synchronous behavior
  begin
    if rising_edge(clk) then -- the active edge is the rising one
      if rst_n = '0' then
        y <= (others => '0');
        acc_y <= (others => '0');
      elsif acc_en_n = '0' then -- it's enabled
        y <= add_s;
        acc_y <= add_s;
      end if;
    end if;
  end process;
end architecture;
