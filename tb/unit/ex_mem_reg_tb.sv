
`timescale 1ns/1ps

module ex_mem_reg_tb;

    // Clock and control signals
    logic clk;
    logic reset_n;
    logic flush;

    // Data inputs and outputs
    logic [31:0] alu_result_in, alu_result_out;
    logic [31:0] rs2_data_in, rs2_data_out;
    logic [31:0] pc_plus4_in, pc_plus4_out;
    logic [31:0] immediate_in, immediate_out;
    logic [4:0] rd_addr_in, rd_addr_out;

    logic [2:0] funct3_in = 3'b101, funct3_out;

    // Control signal inputs and outputs
    logic reg_write_in, reg_write_out;
    logic mem_write_in, mem_write_out;
    logic mem_to_reg_in, mem_to_reg_out;
    logic jump_in, jump_out;

    integer tests_passed = 0;

    // Connect testbench to EX/MEM register
    ex_mem_reg dut (
        .clk(clk),
        .reset_n(reset_n),
        .flush(flush),
        .funct3_in(funct3_in),
        .funct3_out(funct3_out),

        .alu_result_in(alu_result_in),
        .rs2_data_in(rs2_data_in),
        .pc_plus4_in(pc_plus4_in),
        .immediate_in(immediate_in),
        .rd_addr_in(rd_addr_in),

        .reg_write_in(reg_write_in),
        .mem_write_in(mem_write_in),
        .mem_to_reg_in(mem_to_reg_in),
        .jump_in(jump_in),

        .alu_result_out(alu_result_out),
        .rs2_data_out(rs2_data_out),
        .pc_plus4_out(pc_plus4_out),
        .immediate_out(immediate_out),
        .rd_addr_out(rd_addr_out),

        .reg_write_out(reg_write_out),
        .mem_write_out(mem_write_out),
        .mem_to_reg_out(mem_to_reg_out),
        .jump_out(jump_out)
    );

    // Generate clock: 10 ns period
    always #5 clk = ~clk;

    // Check whether outputs match expected values
    task check_outputs;
        input expect_zero;
        input [31:0] expected_alu;
        begin
            if (
                funct3_out === (expect_zero ? 3'd0 : funct3_in) &&
                alu_result_out === expected_alu &&
                rs2_data_out === (expect_zero ? 32'd0 : rs2_data_in) &&
                pc_plus4_out === (expect_zero ? 32'd0 : pc_plus4_in) &&
                immediate_out === (expect_zero ? 32'd0 : immediate_in) &&
                rd_addr_out === (expect_zero ? 5'd0 : rd_addr_in) &&
                reg_write_out === (expect_zero ? 1'b0 : reg_write_in) &&
                mem_write_out === (expect_zero ? 1'b0 : mem_write_in) &&
                mem_to_reg_out === (expect_zero ? 1'b0 : mem_to_reg_in) &&
                jump_out === (expect_zero ? 1'b0 : jump_in)
            ) begin
                tests_passed = tests_passed + 1;
                $display("PASS: ALU=%h", alu_result_out);
            end
            else begin
                $display("FAIL: ALU=%h Expected=%h", alu_result_out, expected_alu);
            end
        end
    endtask

    initial begin

        // Initialize all signals
        clk = 0;
        reset_n = 0;
        flush = 0;

        alu_result_in = 0;
        rs2_data_in = 0;
        pc_plus4_in = 0;
        immediate_in = 0;
        rd_addr_in = 0;

        reg_write_in = 0;
        mem_write_in = 0;
        mem_to_reg_in = 0;
        jump_in = 0;

        // TEST 1: Reset clears all outputs
        #2;
        check_outputs(1, 32'd0);

        // TEST 2: Normal operation
        // Example: ALU calculates 10 + 20 = 30
        reset_n = 1;
        alu_result_in = 32'd30;
        rs2_data_in = 32'd20;
        pc_plus4_in = 32'd12;
        immediate_in = 32'd5;
        rd_addr_in = 5'd3;

        reg_write_in = 1;
        mem_write_in = 0;
        mem_to_reg_in = 0;
        jump_in = 0;

        @(posedge clk);
        #1;
        check_outputs(0, 32'd30);

        // TEST 3: Flush clears the instruction
        flush = 1;

        @(posedge clk);
        #1;
        check_outputs(1, 32'd0);

        // TEST 4: Resume normal operation
        flush = 0;
        alu_result_in = 32'd50;

        @(posedge clk);
        #1;
        check_outputs(0, 32'd50);

        // Display final results
        $display("Tests passed: %0d/4", tests_passed);
        $finish;
    end

endmodule
