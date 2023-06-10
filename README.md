# Step 1: Introduction to SystemVerilog 
--------------------------------------
## Introduction
-------------

## Included Files 
-----------------

- [`run.sh`](./run.sh) - QuestaSIM launcher with remote execution and
  synchronization capabilities. 
- [`scripts/`](./scripts) - **Simulation automation**
    - [`scripts/main.do`](.scripts/main.do) - QuestaSIM shell script, launched
      by [`run.sh`](./run.sh). It orchestrates: source files collection,
      dependency resolution, simulation run and coverage report generation.
    - [`scripts/findFiles.tcl`](.scripts/findFiles.tcl) - Recursive `glob`
      procedure. It's used to collect the source files to be compiled.
- [`src/rtl`](./src/rtl) - **DUTs source files**
    - [`src/rtl/alu`](./src/rtl/alu) - **Combinational circuit**
        - [`src/rtl/alu/type_alu.vhd`](./src/rtl/alu/type_alu.vhd) - Package
          containing the definition of the enumerated type which encodes
          the operations supported by the ALU.
        - [`src/rtl/alu/alu.vhd`](./src/rtl/alu/alu.vhd) - The VHDL entity
          containing the behavioral description of the ALU.
    - [`src/rtl/accumulator/acc.vhd`](./src/rtl/accumulator/acc.vhd) - 
      **Sequential circuit**. The VHDL entity containing the behavioral
      description of the accumulator.

## Usage (remote execution)
---------------------------

1. Change into the directory containing this file:
    ```bash
    $ cd /path/to/step1_introsv
    ```
2. Invoke the launcher specifying:
   - the connection parameters (asking not to clean the project upon completion)
   - the name of the alias to be called remotely to initialize the simulator
   - the name of the systemverilog program containing the random test to be executed

   For example:
    ```bash
    $ ./run.sh -r 2023-socv-N@led-x3850-2.polito.it -p 100XX -m setmentor test_alu
    ```
