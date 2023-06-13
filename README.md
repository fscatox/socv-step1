# Step 1: Introduction to SystemVerilog 

## Introduction

## Included Files 

- [`run.sh`](./run.sh) - QuestaSIM launcher with remote execution and synchronization capabilities. 
- [`scripts/`](./scripts) - **Simulation automation scripts**
    - [`scripts/main.do`](.scripts/main.do) - QuestaSIM shell script, launched by
      [`run.sh`](./run.sh). It orchestrates: source files collection, dependency resolution,
      simulation run and coverage report generation.
    - [`scripts/findFiles.tcl`](.scripts/findFiles.tcl) - Recursive `glob` procedure. It's used to
      collect the source files to be compiled.

- [`src/rtl`](./src/rtl) - **DUTs source files**
    - [`src/rtl/alu`](./src/rtl/alu) - **Combinational circuit**
        - [`src/rtl/alu/type_alu.vhd`](./src/rtl/alu/type_alu.vhd) - Package containing the
          definition of the enumerated type which encodes the operations supported by the ALU.
        - [`src/rtl/alu/alu.vhd`](./src/rtl/alu/alu.vhd) - The VHDL entity containing the behavioral
          description of the ALU.
    - [`src/rtl/accumulator/acc.vhd`](./src/rtl/accumulator/acc.vhd) - **Sequential circuit**. The
      VHDL entity containing the behavioral description of the accumulator.

- [`src/tb`](./src/tb) - **Testbench source files**. The classes and headers located in this folder
  are basic components of any testbench structured in a layered manner.
    - [`src/tb/rpt.svh`](./src/tb/rpt.svh) - Collection of macros for complaining.   
    - [`src/tb/BaseTransaction.sv`](./src/tb/BaseTransaction.sv) - Base class for transaction
      objects passed around in the testbench.
    - [`src/tb/Generator.sv`](./src/tb/Generator.sv) - Generates the random transactions and
      dispatches them to the driver. The class is templated so to support multiple transaction
      types.
    - [`src/tb/Callback.svh`](./src/tb/Callback.svh) - Callbacks are used to inject new behavior
      into a class, without having to change its code.
    - [`src/tb/Config.sv`](./src/tb/Config.sv) - Central configuration descriptor for the testbench.
      It parses the command-line argument that specifies the number of packets to generate.
    - [`src/tb/Scoreboard.sv`](./src/tb/Scoreboard.sv) - The Scoreboard connects via callbacks to
      the driver and the monitor. It collects the expected and actual DUT's reponses, then it
      performs a comparison check.
    - [`src/tb/BaseEnvironment.sv`](./src/tb/BaseEnvironment.sv) - The environment encapsulates all
      the blocks of the layered testbench. It simulates evrything that is not inside the DUT, making
      it possible to run a certain testbench program.

    - [`src/tb/alu`](./src/tb/alu) - **Additional testbench sources for the alu**
        - [`src/tb/alu/walu_pkg.sv`](./src/tb/alu/walu_pkg.sv) - Data types and configuration
          parameters for the SystemVerilog wrapper of the VHDL alu under test.
          - [`src/tb/alu/alu_if.sv`](./src/tb/alu/alu_if.sv) - The interface encapsulates
            connectivity and synchronization between the DUT and the testbench environment.
          - [`src/tb/alu/alu_if.svh`](./src/tb/alu/alu_if.svh) - `alu_if`-related type declarations.
          - [`src/tb/alu/walu.sv`](./src/tb/alu/walu.sv) - Wrapper for the ALU described in the VHDL
            entity `alu`.

          - [`src/tb/alu/AluPacket.sv`](./src/tb/alu/AluPacket.sv) - Refinement of what
            "transaction" means for the `walu` testbench.
          - [`src/tb/alu/AluDriver.sv`](./src/tb/alu/AluDriver.sv) - Class in charge of applying the
            stimulus to the DUT, translating from the high-level transactions received.
          - [`src/tb/alu/AluMonitor.sv`](./src/tb/alu/AluMonitor.sv) - Class in charge of capturing
            the response of the DUT, packing it in a high-level transaction.
          - [`src/tb/alu/AluCoverage.sv`](./src/tb/alu/AluCoverage.sv) - Coverage class to gather
            information on how effective the generated stimulus is for exercising the DUT's
            functionality.
          - [`src/tb/alu/AluScoreboardCallbacks.sv`](./src/tb/alu/AluScoreboardCallbacks.sv) - Callback
            classes used to connect driver and monitor to the scoreboard. The driver is
            given the capability of generating the expected DUT's response.
          - [`src/tb/alu/AluEnvironment.sv`](./src/tb/alu/AluEnvironment.sv) - Child of
            "BaseEnvironment" abstract class. BaseEnvironment templates are defined based on the
            actual testbench components. Thus, BaseEnvironment::build() is now meaningful.

          - [`src/tb/alu/alu_test.sv`](./src/tb/alu/alu_test.sv) - The program steps through all the
            phases of the simulation, as defined by the AluEnvironment.
          - [`src/tb/alu/alu_top.sv`](./src/tb/alu/alu_top.sv) - Highest testbench layer,
            containing:
                - clock generator. The clock is in general more closely tied to the design rather
                  than to the testbench, thus it's generated here.
                - DUT.
                - The testbench program block, which ensures separation between the design events
                  (elaborated in the active region of the time slot) and the testbench events
                  (elaborated in the reactive region).
                - The interface between the two.

    - [`src/tb/accumulator`](./src/tb/accumulator) - **Additional testbench sources for the
      accumulator** 
        - [`src/tb/accumulator/acc_pkg.sv`](./src/tb/accumulator/acc_pkg.sv) - Data types and
          configuration parameters for the SystemVerilog wrapper of the VHDL accumulator under test.
        - [`src/tb/accumulator/acc_if.sv`](./src/tb/accumulator/acc_if.sv) - The interface
          encapsulates connectivity and synchronization between the DUT and the testbench
          environment.
        - [`src/tb/accumulator/acc_if.svh`](./src/tb/accumulator/acc_if.svh) - `acc_if`-related type
          declarations.

        - [`src/tb/accumulator/AccPacket.sv`](./src/tb/accumulator/AccPacket.sv) - Refinement of what
          "transaction" means for the `acc` testbench.
        - [`src/tb/accumulator/AccDriver.sv`](./src/tb/accumulator/AccDriver.sv) - Class in charge of
          applying the stimulus to the DUT, translating from the high-level transactions received.
        - [`src/tb/accumulator/AccMonitor.sv`](./src/tb/accumulator/AccMonitor.sv) - Class in charge
          of capturing the response of the DUT, packing it in a high-level transaction.
        - [`src/tb/accumulator/AccCoverage.sv`](./src/tb/accumulator/AccCoverage.sv) - Coverage class
          to gather information on how effective the generated stimulus is for exercising the DUT's
          functionality.
        - [`src/tb/accumulator/AccScoreboardCallbacks.sv`](./src/tb/accumulator/AccScoreboardCallbacks.sv) -
          Callback classes used to connect driver and monitor to the scoreboard. The driver is
          given the capability of generating the expected DUT's response.
        - [`src/tb/accumulator/AccEnvironment.sv`](./src/tb/accumulator/AccEnvironment.sv) - Child of
          "BaseEnvironment" abstract class. BaseEnvironment templates are defined based on the
          actual testbench components. Thus, BaseEnvironment::build() is now meaningful.

## Usage (remote execution)

1. Change into the directory containing this file: 
    ```bash 
    $ cd /path/to/step1_introsv 
    ```
2. Invoke the launcher. Examples:
    * alu. Customize `N` and `XX` in the following command. After execution, the outputs can be
      inspected in the `out/alu_top_+n_packets100/` folder.  
      ```bash 
      $ ./run.sh -r 2023-socv-N@led-x3850-2.polito.it -p 100XX -m setmentor -- alu_top +n_packets100 
      ```
    * accumulator. Customize `N` and `XX` in the following command. After execution, the outputs can
      be inspected in the `out/acc_top_+n_packets100/` folder.  
      ```bash 
      $ ./run.sh -r 2023-socv-N@led-x3850-2.polito.it -p 100XX -m setmentor -- acc_top +n_packets100 
      ```
 
