
`timescale 1ns/1ps

module pipeline_cpu_tb #(
    parameter PROGRAM_FILE = "programs/cpu_full_test.hex",
    parameter integer WORDS = 8
);

logic clk = 0;
logic reset_n = 1;

integer i;
integer stalls = 0;
integer redirects = 0;
integer cycles = 0;
integer program_cycles = 0;
logic finished = 0;
integer retired_instructions = 0;
integer measurement_cycles = 0;
integer reference_instructions = 0;
logic reference_finished = 0;
logic retire_valid;
logic [31:0] retire_pc;
logic [31:0] reference_pc [0:199];

// Pipeline CPU
pipeline_cpu #(.PROGRAM_FILE(PROGRAM_FILE)) dut (
    .clk(clk),
    .reset_n(reset_n),
    .retire_valid(retire_valid),
    .retire_pc(retire_pc)
);

// Single cycle CPU
cpu_top #(.PROGRAM_FILE(PROGRAM_FILE)) reference_cpu (
    .clk(clk),
    .reset_n(reset_n)
);

// Clock
always #5 clk = ~clk;

// Count cycles, stalls, and redirects
always @(posedge clk) begin
    if (reset_n) begin
        cycles = cycles + 1;

        if (dut.stall) begin
            stalls = stalls + 1;
        end

        if (dut.redirect) begin
            redirects = redirects + 1;
        end
    end
end

// Record the instructions executed by the single cycle CPU
always @(posedge clk) begin
    if (reset_n && !reference_finished) begin
        if (reference_cpu.pc == WORDS * 4) begin
            reference_finished = 1;
        end
        else begin
            if (reference_instructions >= 200) begin
                $display("Reference instruction trace is full");
                $fatal(1);
            end

            reference_pc[reference_instructions] = reference_cpu.pc;
            reference_instructions = reference_instructions + 1;
        end
    end
end

// Count retired instructions and exclude the terminal loop
always @(posedge clk) begin
    if (!reset_n) begin
        measurement_cycles = 0;
        program_cycles = 0;
        retired_instructions = 0;
        finished = 0;
    end
    else if (!finished) begin
        measurement_cycles = measurement_cycles + 1;

        if (retire_valid) begin
            if (retire_pc == WORDS * 4) begin
                finished = 1;
            end
            else begin
                // Check retirement order, including stores and branches
                if (retired_instructions >= reference_instructions ||
                    retire_pc !== reference_pc[retired_instructions]) begin

                    $display("Retired instruction PC does not match at instruction %0d",
                             retired_instructions);
                    $fatal(1);
                end

                retired_instructions = retired_instructions + 1;
                program_cycles = measurement_cycles;
            end
        end
    end
end

initial begin

    // Reset CPU
    reset_n = 0;
    #1;

    // Fill unused instruction memory
    for (i = WORDS; i < 256; i = i + 1) begin
        dut.imem.memory[i] = 32'h0000006f;
        reference_cpu.imem_inst.memory[i] = 32'h0000006f;
    end

    // Initialize data memory
    for (i = 0; i < 1024; i = i + 1) begin
        dut.dmem.memory[i] = 0;
        reference_cpu.dmem_inst.memory[i] = 0;
    end

    // Start CPU
    #1;
    reset_n = 1;

    // Run simulation for 200 cycles
    repeat (200) @(posedge clk);
    #1;

    // Check all 32 registers
    for (i = 0; i < 32; i = i + 1) begin
        if ($isunknown(dut.rf.regs[i]) ||
            dut.rf.regs[i] !== reference_cpu.rf_inst.regs[i]) begin

            $display("Register x%0d does not match", i);
            $display("Pipeline = %h", dut.rf.regs[i]);
            $display("Single cycle = %h", reference_cpu.rf_inst.regs[i]);
            $fatal(1);
        end
    end

    // Check data memory
    for (i = 0; i < 1024; i = i + 1) begin
        if (dut.dmem.memory[i] !== reference_cpu.dmem_inst.memory[i]) begin
            $display("Memory does not match at address %0d", i);
            $fatal(1);
        end
    end

    // Check if CPU reached the end of the program
    if ($isunknown(dut.pc) ||
        dut.pc < WORDS * 4 ||
        dut.pc > WORDS * 4 + 8) begin

        $display("CPU did not reach the end of the program");
        $fatal(1);
    end

    // Check if the cycle measurement finished
    if (!finished) begin
        $display("Program cycle measurement did not finish");
        $fatal(1);
    end

    // Check the retired instruction count
    if (!reference_finished ||
        retired_instructions == 0 ||
        retired_instructions != reference_instructions) begin

        $display("Retired instruction count does not match");
        $fatal(1);
    end

    // Check hazard test results
    if (PROGRAM_FILE == "programs/pipeline_hazard_test.hex") begin

        if (stalls != 3 ||
            dut.rf.regs[6] !== 6 ||
            dut.rf.regs[9] !== 32'hffffffff ||
            dut.rf.regs[10] !== 255 ||
            dut.rf.regs[12] !== 65535 ||
            dut.rf.regs[13] !== 32'h12345000 ||
            dut.rf.regs[14] !== 4196 ||
            dut.rf.regs[18] !== 120 ||
            dut.dmem.memory[8] !== 0 ||
            dut.dmem.memory[20] !== 0) begin

            $display("Hazard test failed");
            $fatal(1);
        end
    end

    // All tests passed
    $display("PASS: %s", PROGRAM_FILE);
    $display("All registers and memory match");
    $display("Stalls = %0d", stalls);
    $display("Redirects = %0d", redirects);

    $display("Total simulation cycles = %0d", cycles);
    $display("Program cycles = %0d", program_cycles);
    $display("Instruction words = %0d", WORDS);
    $display("Retired instructions = %0d", retired_instructions);
    $display("CPI = %f", real'(program_cycles) / retired_instructions);

    $finish;
end

endmodule
