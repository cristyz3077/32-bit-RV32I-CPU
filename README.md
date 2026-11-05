# RV32I CPU

Project layout:

- `rtl/single_cycle/`: single-cycle CPU modules.
- `rtl/pipeline/`: pipeline modules.
- `tb/unit/`: individual module testbenches.
- `tb/integration/`: CPU integration testbenches.
- `programs/`: hexadecimal instruction data used by simulations.
- `build/sim/`: generated simulation executables (ignored by Git).
- `build/waves/`: generated waveforms (ignored by Git).

Run simulations from the repository root so program paths resolve correctly.
For example, in PowerShell with Icarus Verilog installed:

```powershell
New-Item -ItemType Directory -Force build/sim, build/waves | Out-Null
iverilog -g2012 -s alu_test -o build/sim/alu_test.vvp rtl/single_cycle/alu.sv tb/unit/alu_tb.sv
vvp build/sim/alu_test.vvp
```

Existing simulation executables moved into `build/sim/` may contain old paths;
recompile their testbenches before running them.

Run the pipeline regression with Icarus Verilog and Python installed:

```powershell
python sim/run_pipeline_tests.py
```

The regression runs seven existing programs and a directed hazard program,
compares all registers and data-memory bytes against the single-cycle CPU,
and checks explicit hazard-test results. The pipeline includes EX/MEM and WB
forwarding, WB-to-ID bypass, a one-cycle load-use interlock, and EX-stage
branch/jump redirection with younger-instruction flushing. `PROGRAM_FILE`
selects the program for `pipeline_cpu`.

Memory retains the existing implementation: use data addresses within the
1,024-byte RAM and naturally aligned halfword/word accesses. Architectural
traps for invalid addresses, misalignment, and illegal instructions are not
implemented. Short hex files produce harmless `$readmemh` size warnings;
the regression fills unused instruction slots with a terminal loop.
