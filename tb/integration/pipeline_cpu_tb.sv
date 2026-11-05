`timescale 1ns/1ps
// Run the same program on both datapaths, then compare architectural state.
module pipeline_cpu_tb #(
    parameter PROGRAM_FILE = "programs/cpu_full_test.hex",
    parameter integer WORDS = 8
);
    logic clk = 0;
    logic reset_n = 1;
    integer i;
    integer stalls = 0, redirects = 0;
    pipeline_cpu #(.PROGRAM_FILE(PROGRAM_FILE)) dut (.clk(clk), .reset_n(reset_n));
    cpu_top #(.PROGRAM_FILE(PROGRAM_FILE)) reference_cpu (.clk(clk), .reset_n(reset_n));
    always #5 clk = ~clk;
    always @(posedge clk) if (reset_n) begin
        if (dut.stall) stalls = stalls + 1;
        if (dut.redirect) redirects = redirects + 1;
    end
    initial begin
        reset_n = 0; #1;
        // End each finite test with JAL x0, 0; initialize otherwise unspecified RAM.
        for (i = WORDS; i < 256; i = i + 1) begin
            dut.imem.memory[i] = 32'h0000006f;
            reference_cpu.imem_inst.memory[i] = 32'h0000006f;
        end
        for (i = 0; i < 1024; i = i + 1) begin
            dut.dmem.memory[i] = 0;
            reference_cpu.dmem_inst.memory[i] = 0;
        end
        #1; reset_n = 1;
        repeat (200) @(posedge clk);
        #1;
        for (i = 0; i < 32; i = i + 1)
            if ($isunknown(dut.rf.regs[i]) || dut.rf.regs[i] !== reference_cpu.rf_inst.regs[i])
                $fatal(1, "x%0d: pipeline=%h reference=%h", i,
                       dut.rf.regs[i], reference_cpu.rf_inst.regs[i]);
        for (i = 0; i < 1024; i = i + 1)
            if (dut.dmem.memory[i] !== reference_cpu.dmem_inst.memory[i])
                $fatal(1, "Memory mismatch at byte %0d", i);
        if ($isunknown(dut.pc) || dut.pc < WORDS * 4 || dut.pc > WORDS * 4 + 8)
            $fatal(1, "Pipeline did not reach terminal loop: PC=%h", dut.pc);
        if (PROGRAM_FILE == "programs/pipeline_hazard_test.hex") begin
            if (stalls != 3 || dut.rf.regs[6] !== 6 ||
                dut.rf.regs[9] !== 32'hffffffff || dut.rf.regs[10] !== 255 ||
                dut.rf.regs[12] !== 65535 || dut.rf.regs[13] !== 32'h12345000 ||
                dut.rf.regs[14] !== 4196 || dut.rf.regs[18] !== 120 ||
                dut.dmem.memory[8] !== 0 || dut.dmem.memory[20] !== 0)
                $fatal(1, "Directed hazard expectations failed");
        end
        $display("PASS: %s, all registers and RAM match; stalls=%0d redirects=%0d",
                 PROGRAM_FILE, stalls, redirects);
        $finish;
    end
endmodule

