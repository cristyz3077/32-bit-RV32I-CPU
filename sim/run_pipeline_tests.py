"""Run from the repository root: python sim/run_pipeline_tests.py"""
from pathlib import Path
import subprocess

out = Path("build/sim")
out.mkdir(parents=True, exist_ok=True)
sources = sorted(str(p) for p in Path("rtl").rglob("*.sv"))
for program in sorted(Path("programs").glob("*test.hex")):
    words = len(program.read_text().split())
    command = ["iverilog", "-g2012", "-s", "pipeline_cpu_tb",
               f'-Ppipeline_cpu_tb.PROGRAM_FILE="{program.as_posix()}"',
               f"-Ppipeline_cpu_tb.WORDS={words}", "-o", str(out / "pipeline_cpu_tb.vvp"),
               *sources, "tb/integration/pipeline_cpu_tb.sv"]
    compiled = subprocess.run(command, capture_output=True, text=True)
    (out / "pipeline_compile.log").write_text(compiled.stderr)
    if compiled.returncode:
        raise SystemExit(compiled.stderr)
    subprocess.run(["vvp", str(out / "pipeline_cpu_tb.vvp")], check=True, timeout=30)
