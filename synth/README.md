# Generic single-cycle synthesis

Run from the repository root with Yosys on PATH:

```powershell
New-Item -ItemType Directory -Force build/synth | Out-Null
yosys -l build/synth/single_cycle.log -s synth/synth_single_cycle.ys
```

The hierarchy-check script remains separate. The synthesis script keeps module
boundaries and uses generic gates, not FPGA LUTs, block RAM, or ASIC library cells.
Outputs are written under the ignored build folder.

## First measured result

Top: single_cycle_synth_top. Yosys: 0.70+336. ROM: programs/program.hex.

| Resource | Count |
|---|---:|
| Generic cells total | 74,954 |
| Flip-flop bits total | 9,248 |
| Data RAM flip-flop bits | 8,192 |
| Register-file flip-flop bits | 1,024 |
| PC flip-flop bits | 32 |
| Multiplexer cells | 48,504 |
| Other combinational cells | 17,202 |

The data_memory module accounts for 67,182 cells. The generic flow maps its
1,024-byte memory into flip-flops and selection logic. No memory cells remain.
The register file also becomes flip-flops; Yosys reports this conversion as a warning.
Final design checks report zero problems.

The instruction ROM maps to only four logic cells. The file initializes just
three words; the remaining locations are unspecified and can be used as don't-care
values during synthesis. This is not a representative general-purpose ROM cost.
Keeping hierarchy also limits optimization across module boundaries.

This first report is a baseline for understanding the RTL, not a fair architecture
area comparison or timing result. A comparison must use matching memory boundaries,
program initialization, observable outputs, hierarchy settings, and target mapping.
Do not interpret these generic cell counts as FPGA resource counts or maximum clock
frequency. The Windows run also emitted ABC temporary-file cleanup errors; Yosys
completed with exit code zero, generated its JSON netlist, and passed design checks.
