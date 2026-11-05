
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

// Pipeline CPU
pipeline_cpu #(.PROGRAM_FILE(PROGRAM_FILE)) dut (
    .clk(clk),
    .reset_n(reset_n)
);

// Single cycle CPU
cpu_top #(.PROGRAM_FILE(PROGRAM_FILE)) reference_cpu (
    .clk(clk),
    .reset_n(reset_n)
);

// Clock
always #5 clk = ~clk;

// Count stalls and redirects
always @(posedge clk) begin
    if (reset_n) begin
        if (dut.stall) begin
            stalls = stalls + 1;
        end

        if (dut.redirect) begin
            redirects = redirects + 1;
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

    $finish;
end

endmodule
