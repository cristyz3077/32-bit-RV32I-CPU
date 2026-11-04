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
