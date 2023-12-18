# Step 1: Introduction to SystemVerilog

## Table of contents
1. [Introduction](#introduction)
2. [Included Files](#included-files)
3. [Usage (remote execution)](#usage-remote-execution)
4. [References](#references)

## Introduction
Verification engineers want to find bugs and simulation is still the workhorse of it all.

When it comes to developing testbenches, the typical straightforward approach is directed testing.
The hardware specifications are translated into a verification plan consisting in a list of tests,
each targeting a certain subset of the DUT's functionality. The testbench is then constructed to
generate enough stimulus vectors to exercise those features. Results are manually examined and, when
satisfactory, the process advances until the verification plan is completed. Although this approach
yields results quickly, each test must be written almost from scratch and the effort is directly
proportional to the complexity of the design. Furthermore, the stimulus vectors only exercise the
DUT in expected areas, limiting the ability to uncover bugs elsewhere.

But what if there was a way to discover bugs more efficiently?
In this first step of the *SoC Verification Strategies* workshop at Politecnico di Torino, I
have the opportunity to get familiar with some common principles of more advanced methodologies:
- *constrained random stimulus* is crucial for exercising complex designs. Randomness enables to
  find bugs that were never anticipated; constraints are essential to ensure that the stimulus is
  valid and relevant for the DUT.
- *functional coverage*. Once having switched to random tests, functional coverage becomes the
  metric for tracking progress in the verification plan, ensuring that all the intended features
  of the DUT were exercised.
- *layered structure*. Random stimulus implies the need of an environment capable of predicting the
  expected response in compliance with the specifications; building this infrastructure
  involves additional work. The resulting complexity is managed:
    - by increasing the abstraction level, up to transaction-level modeling. The environment can be
      structured composing simpler pieces: a generator, a driver, a monitor to name a few.
    - With a more expressive language; expressiveness limits analyzability, synthesizability and
      optimizability, but the primary goal is simulation-based verification here. SystemVerilog
      provides us with convenient high-level features and for this reason was chosen to package
      industrial verification methodology libraries like the UVM.

## Included Files

- [`run.sh`](./run.sh) - QuestaSIM launcher with remote execution and synchronization capabilities.
- [`scripts/`](./scripts) - **Simulation automation scripts**
    - [`scripts/main.do`](.scripts/main.do) - QuestaSIM shell script, launched by
      [`run.sh`](./run.sh). It orchestrates: source files collection, dependency resolution,
      simulation run, coverage report generation and the post-processing of the applied stimulus.
    - [`scripts/findFiles.tcl`](.scripts/findFiles.tcl) - Recursive `glob` procedure. It's used to
      collect the source files to be compiled.
    - [`scripts/log2csv.tcl`](.scripts/log2csv.tcl) - Procedure for parsing the simulation log.
      Expected packets saved into the scoreboard are exported in comma-separated value format,
      together with the outcome of the comparison. To ensure repeatability, the seed of the
      simulation and the configuration parameters of the environment are listed at the top of
      the file.

- [`src/rtl`](./src/rtl) - **DUTs source files**
    - [`src/rtl/alu`](./src/rtl/alu) - **Combinational circuit**
        - [`src/rtl/alu/type_alu.vhd`](./src/rtl/alu/type_alu.vhd) - Package containing the
          definition of the enumerated type which encodes the operations supported by the alu.
        - [`src/rtl/alu/alu.vhd`](./src/rtl/alu/alu.vhd) - The VHDL entity containing the behavioral
          description of the alu.
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
      It parses the command-line argument `+n_packets` that specifies the number of packets to generate.
    - [`src/tb/Scoreboard.sv`](./src/tb/Scoreboard.sv) - The Scoreboard connects via callbacks to
      the driver and the monitor. It collects the expected and actual DUT's reponses, then it
      performs a comparison check.
    - [`src/tb/BaseEnvironment.sv`](./src/tb/BaseEnvironment.sv) - The environment encapsulates all
      the blocks of the layered testbench. It simulates everything that is not inside the DUT, making
      it possible to run a certain testbench program via:
      - `build()`. This method is left to be implemented by child classes. It shall build the
        environment, which encompasses the allocation of the transactors, the instantiation of
        the callbacks and their registration with both the scoreboard and the coverage class.
      - `run()`. Generator, Driver and Monitor classes are run in their own threads. A timeout
        block prevents the simulation to hang in case of errors.
      - `wrap_up()`. Prints statistic of the current run: number of errors and the total
        functional coverage.
 
    - [`src/tb/alu`](./src/tb/alu) - **Additional testbench sources for the alu**
        - [`src/tb/alu/walu_pkg.sv`](./src/tb/alu/walu_pkg.sv) - Data types and configuration
          parameters for the SystemVerilog wrapper of the VHDL alu under test.
        - [`src/tb/alu/alu_if.sv`](./src/tb/alu/alu_if.sv) - The interface encapsulates
          connectivity and synchronization between the DUT and the testbench environment.
        - [`src/tb/alu/alu_if.svh`](./src/tb/alu/alu_if.svh) - `alu_if`-related type declarations.
        - [`src/tb/alu/walu.sv`](./src/tb/alu/walu.sv) - Wrapper for the ALU described in the VHDL
          entity `alu`.
 
        - [`src/tb/alu/AluPacket.sv`](./src/tb/alu/AluPacket.sv) - Refinement of what
          "transaction" means for the `walu` testbench. Here weighted distributions are used to
          constrain the randomization of the packet, so as to skew the stimulus towards interesting
          cases, namely corner cases for the alu operands.
        - [`src/tb/alu/AluDriver.sv`](./src/tb/alu/AluDriver.sv) - Class in charge of applying the
          stimulus to the DUT. Transactions are received from the Generator through a mailbox: the
          driver translates them into `alu_if` signals activations. Before and after applying the
          stimulus, the driver processes the registered callbacks in its queue.
          The callbacks are declared in
          [`src/tb/alu/AluScoreboardCallbacks.sv`](./src/tb/alu/AluScoreboardCallbacks.sv)
          and in [`src/tb/alu/AluCoverage.sv`](./src/tb/alu/AluCoverage.sv).
        - [`src/tb/alu/AluMonitor.sv`](./src/tb/alu/AluMonitor.sv) - Class in charge of capturing
          the response of the DUT, packing it in a high-level transaction. Like for the Monitor,
          callbacks are executed before and after capturing the DUT's response.
        - [`src/tb/alu/AluCoverage.sv`](./src/tb/alu/AluCoverage.sv) - Coverage class to gather
          information on how effective the generated stimulus is for exercising the DUT's
          functionality. Simple coverpoints are used to check that corner cases are being generated.
          The `AluCovDriverCb` callback is used to trigger the sampling once the Monitor has
          captured the DUT's response.
        - [`src/tb/alu/AluScoreboardCallbacks.sv`](./src/tb/alu/AluScoreboardCallbacks.sv) - Callback
          classes used to connect driver and monitor to the scoreboard. The driver is
          given the capability of generating the expected DUT's response: compared to SystemVerilog
          Assertions, this procedural-alternative is easier to debug and maintain.
        - [`src/tb/alu/AluEnvironment.sv`](./src/tb/alu/AluEnvironment.sv) - Child of
          "BaseEnvironment" abstract class. BaseEnvironment templates are defined based on the
          actual testbench components. Thus, `BaseEnvironment::build()` is now meaningful.
        - [`src/tb/alu/alu_test.sv`](./src/tb/alu/alu_test.sv) - The program steps through all the
          phases of the simulation, as defined by the AluEnvironment: `build()`, `run()` and
          `wrap_up()`. Using a program ensures separation between the design events
          (elaborated in the active region of the time slot) and the testbench events
          (elaborated in the reactive region), which is a typical source of race conditions in
          HDL testbenches.
        - [`src/tb/alu/alu_top.sv`](./src/tb/alu/alu_top.sv) - Highest testbench layer,
          containing:
          - The clock generator, because the clock is in general more closely tied to the
            design rather than to the testbench. In addition, this provides further separation
            between design and testbench events.
          - The interface object, which acts as a clever bundle of wires by embedding the timing
            details of DUT-testbench interaction.
          - The DUT instance.
          - The testbench program block.
 
    - [`src/tb/accumulator`](./src/tb/accumulator) - **Additional testbench sources for the
      accumulator**. As anticipated when introducing the advantages of having a higher-level testbench
      framework, changing the dut no more implies having to rewrite the testbench from scratch.
      There's a one to one mapping with the components already developed for the alu, thus I'm
      highlighting only the novelties here.
        - [`src/tb/accumulator/acc_pkg.sv`](./src/tb/accumulator/acc_pkg.sv)
        - [`src/tb/accumulator/acc_if.sv`](./src/tb/accumulator/acc_if.sv)
        - [`src/tb/accumulator/acc_if.svh`](./src/tb/accumulator/acc_if.svh)
 
        - [`src/tb/accumulator/AccPacket.sv`](./src/tb/accumulator/AccPacket.sv)
        - [`src/tb/accumulator/AccDriver.sv`](./src/tb/accumulator/AccDriver.sv)
        - [`src/tb/accumulator/AccMonitor.sv`](./src/tb/accumulator/AccMonitor.sv)
        - [`src/tb/accumulator/AccCoverage.sv`](./src/tb/accumulator/AccCoverage.sv) - With a
          sequential circuit there are a few additional cases that make the stimulus interesting and
          thus worth reporting:
            - a reset sequence,
            - the possible states for the accumulator: memory, sum and accumulate.
          The former is checked by means of the "transition coverage" syntax; the latter by means of
          cross-coverage, using custom-defined bins.
        - [`src/tb/accumulator/AccScoreboardCallbacks.sv`](./src/tb/accumulator/AccScoreboardCallbacks.sv) -
          Having chosen not to use SystemVerilog Assertions, here a callback takes care of
          implementing the golden model as per specifications. Being the circuit sequential,
          a class data member plays the role of the storage element.
        - [`src/tb/accumulator/AccEnvironment.sv`](./src/tb/accumulator/AccEnvironment.sv)
        - [`src/tb/accumulator/acc_test.sv`](./src/tb/accumulator/acc_test.sv) - Differently from
          the simpler combinational alu, here, before starting the transactors, it's essential that the
          dut has been successfully reset. The synchronization issue is solved with a naked event,
          shared with the top module.
        - [`src/tb/accumulator/acc_top.sv`](./src/tb/accumulator/acc_top.sv) - The top module takes
          care of enforcing the conditions required by the transactors to work properly. At first,
          while the transactors have not been started yet, the dut is reset. Then, the `dut_ready`
          event is triggered, which wakes up the `acc_test` program.

- [`doc/`](./doc) - **technical report and latex sources**

## Usage (remote execution)

1. Change into the directory containing this file:
    ```bash
    $ cd /path/to/socv-step1
    ```
2. Invoke the launcher. Examples:
    * **alu**. Customize `N` and `XX` in the following command. After execution, the outputs are saved
      in `out/alu_top_+n_packets100/`.
      ```bash
      $ ./run.sh -r 2023-socv-N@led-x3850-2.polito.it -p 100XX -c -m setmentor -- alu_top +n_packets100
      ```
    * **accumulator**. Customize `N` and `XX` in the following command. After execution, the outputs
      are saved in `out/acc_top_+n_packets100/`.
      ```bash
      $ ./run.sh -r 2023-socv-N@led-x3850-2.polito.it -p 100XX -c -m setmentor -- acc_top +n_packets100
      ```
3. Examine the outputs:
    * the simulation log: `vsim.log`
    * the coverage report: `func_cover.rpt`
    * the applied stimulus vector: `stimulus.csv`

For additional info on the capabilities of the launcher, hit `./run.sh -h`.

## References
[1] C. Spear and G. Tumbush, SystemVerilog for Verification: A Guide to Learning the
Testbench Language Features, 3rd. Springer US, 2012, isbn: 9781461407140.

[2] “IEEE Standard for Verilog Hardware Description Language,” IEEE Std 1364-2005
(Revision of IEEE Std 1364-2001), pp. 1–590, 2006. doi: 10.1109/IEEESTD.2006.99495.

[3] “IEEE Standard for SystemVerilog: Unified Hardware Design, Specification and Verification
Language,” IEEE Std 1800-2005, pp. 1–648, 2005. doi: 10.1109/IEEESTD.2005.97972.
