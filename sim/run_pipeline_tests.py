# Run from the repository root:
# python sim/run_pipeline_tests.py

from pathlib import Path
import subprocess

# Create the simulation output folder
output_folder = Path("build/sim")
output_folder.mkdir(parents=True, exist_ok=True)

# Find the CPU source files
sources = []
for source_file in Path("rtl").rglob("*.sv"):
    sources.append(str(source_file))

sources.sort()

# Run each test program
for program in sorted(Path("programs").glob("*test.hex")):

    # Count the instructions
    program_text = program.read_text()
    words = len(program_text.split())

    # Compile the testbench
    command = [
        "iverilog",
        "-g2012",
        "-s",
        "pipeline_cpu_tb",
        f'-Ppipeline_cpu_tb.PROGRAM_FILE="{program.as_posix()}"',
        f"-Ppipeline_cpu_tb.WORDS={words}",
        "-o",
        str(output_folder / "pipeline_cpu_tb.vvp"),
    ]
    command.extend(sources)
    command.append("tb/integration/pipeline_cpu_tb.sv")

    compiled = subprocess.run(command, capture_output=True, text=True)

    # Save compiler messages
    compile_log = output_folder / "pipeline_compile.log"
    compile_log.write_text(compiled.stderr)

    if compiled.returncode != 0:
        raise SystemExit(compiled.stderr)

    # Run the simulation
    subprocess.run(
        ["vvp", str(output_folder / "pipeline_cpu_tb.vvp")],
        check=True,
        timeout=30,
    )
