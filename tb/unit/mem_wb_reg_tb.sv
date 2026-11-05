
`timescale 1ns/1ps

module mem_wb_reg_tb;

    // Clock and control signals
    logic clk;
    logic reset_n;
    logic flush;

    // Data inputs and outputs
    logic [31:0] alu_result_in, alu_result_out;
    logic [31:0] mem_data_in, mem_data_out;
    logic [31:0] pc_plus4_in, pc_plus4_out;
    logic [31:0] immediate_in, immediate_out;
    logic [4:0] rd_addr_in, rd_addr_out;

    // Control signals
    logic reg_write_in, reg_write_out;
    logic mem_to_reg_in, mem_to_reg_out;
    logic jump_in, jump_out;

    integer tests_passed = 0;

    // Connect testbench to MEM/WB register
    mem_wb_reg dut (
        .clk(clk),
        .reset_n(reset_n),
        .flush(flush),

        .alu_result_in(alu_result_in),
        .mem_data_in(mem_data_in),
        .pc_plus4_in(pc_plus4_in),
        .immediate_in(immediate_in),
        .rd_addr_in(rd_addr_in),

        .reg_write_in(reg_write_in),
        .mem_to_reg_in(mem_to_reg_in),
        .jump_in(jump_in),

        .alu_result_out(alu_result_out),
        .mem_data_out(mem_data_out),
        .pc_plus4_out(pc_plus4_out),
        .immediate_out(immediate_out),
        .rd_addr_out(rd_addr_out),

        .reg_write_out(reg_write_out),
        .mem_to_reg_out(mem_to_reg_out),
        .jump_out(jump_out)
    );

    // Generate clock every 5 ns
    always #5 clk = ~clk;

    // Check all outputs
    task check_outputs;
        input logic expect_zero;
        begin
            if (
                alu_result_out === (expect_zero ? 32'd0 : alu_result_in) &&
                mem_data_out === (expect_zero ? 32'd0 : mem_data_in) &&
                pc_plus4_out === (expect_zero ? 32'd0 : pc_plus4_in) &&
                immediate_out === (expect_zero ? 32'd0 : immediate_in) &&
                rd_addr_out === (expect_zero ? 5'd0 : rd_addr_in) &&
                reg_write_out === (expect_zero ? 1'b0 : reg_write_in) &&
                mem_to_reg_out === (expect_zero ? 1'b0 : mem_to_reg_in) &&
                jump_out === (expect_zero ? 1'b0 : jump_in)
            ) begin
                tests_passed = tests_passed + 1;
                $display("PASS: ALU=%h MEM=%h",
                         alu_result_out, mem_data_out);
            end
            else begin
                $display("FAIL: Output mismatch");
            end
        end
    endtask

    initial begin

        // Initialize inputs
        clk = 0;
        reset_n = 0;
        flush = 0;

        alu_result_in = 0;
        mem_data_in = 0;
        pc_plus4_in = 0;
        immediate_in = 0;
        rd_addr_in = 0;

        reg_write_in = 0;
        mem_to_reg_in = 0;
        jump_in = 0;

        // TEST 1: Reset
        #2;
        check_outputs(1);

        // TEST 2: Normal ALU result
        reset_n = 1;
        alu_result_in = 32'd30;
        mem_data_in = 32'd0;
        pc_plus4_in = 32'd12;
        immediate_in = 32'd5;
        rd_addr_in = 5'd3;
        reg_write_in = 1;

        @(posedge clk);
        #1;
        check_outputs(0);

        // TEST 3: Load from memory
        alu_result_in = 32'd100;
        mem_data_in = 32'd42;
        mem_to_reg_in = 1;

        @(posedge clk);
        #1;
        check_outputs(0);

        // TEST 4: Flush
        flush = 1;

        @(posedge clk);
        #1;
        check_outputs(1);

        // TEST 5: Resume after flush
        flush = 0;
        alu_result_in = 32'd50;
        mem_data_in = 32'd0;
        mem_to_reg_in = 0;

        @(posedge clk);
        #1;
        check_outputs(0);

        $display("Tests passed: %0d/5", tests_passed);
        $finish;
    end

endmodule
