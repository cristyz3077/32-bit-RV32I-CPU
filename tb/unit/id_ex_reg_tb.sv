
`timescale 1ns/1ps

module id_ex_reg_tb;

    logic clk;
    logic reset_n;
    logic flush;

    logic [31:0] pc_in, pc_out;
    logic [31:0] pc_plus4_in, pc_plus4_out;
    logic [31:0] rs1_data_in, rs1_data_out;
    logic [31:0] rs2_data_in, rs2_data_out;
    logic [31:0] immediate_in, immediate_out;

    logic [4:0] rs1_addr_in, rs1_addr_out;
    logic [4:0] rs2_addr_in, rs2_addr_out;
    logic [4:0] rd_addr_in, rd_addr_out;

    logic [6:0] opcode_in, opcode_out;
    logic [2:0] funct3_in, funct3_out;
    logic [6:0] funct7_in, funct7_out;

    logic reg_write_in, reg_write_out;
    logic mem_write_in, mem_write_out;
    logic mem_to_reg_in, mem_to_reg_out;
    logic alu_src_in, alu_src_out;
    logic branch_in, branch_out;
    logic jump_in, jump_out;

    integer tests_passed = 0;

    id_ex_reg dut (
        .clk(clk),
        .reset_n(reset_n),
        .flush(flush),

        .pc_in(pc_in),
        .pc_plus4_in(pc_plus4_in),
        .rs1_data_in(rs1_data_in),
        .rs2_data_in(rs2_data_in),
        .immediate_in(immediate_in),
        .rs1_addr_in(rs1_addr_in),
        .rs2_addr_in(rs2_addr_in),
        .rd_addr_in(rd_addr_in),
        .opcode_in(opcode_in),
        .funct3_in(funct3_in),
        .funct7_in(funct7_in),

        .reg_write_in(reg_write_in),
        .mem_write_in(mem_write_in),
        .mem_to_reg_in(mem_to_reg_in),
        .alu_src_in(alu_src_in),
        .branch_in(branch_in),
        .jump_in(jump_in),

        .pc_out(pc_out),
        .pc_plus4_out(pc_plus4_out),
        .rs1_data_out(rs1_data_out),
        .rs2_data_out(rs2_data_out),
        .immediate_out(immediate_out),
        .rs1_addr_out(rs1_addr_out),
        .rs2_addr_out(rs2_addr_out),
        .rd_addr_out(rd_addr_out),
        .opcode_out(opcode_out),
        .funct3_out(funct3_out),
        .funct7_out(funct7_out),

        .reg_write_out(reg_write_out),
        .mem_write_out(mem_write_out),
        .mem_to_reg_out(mem_to_reg_out),
        .alu_src_out(alu_src_out),
        .branch_out(branch_out),
        .jump_out(jump_out)
    );

    always #5 clk = ~clk;

    task check_outputs;
        input logic expect_zero;
        input logic [31:0] expected_pc;
        begin
            if (
                pc_out === expected_pc &&
                pc_plus4_out === (expect_zero ? 32'd0 : pc_plus4_in) &&
                rs1_data_out === (expect_zero ? 32'd0 : rs1_data_in) &&
                rs2_data_out === (expect_zero ? 32'd0 : rs2_data_in) &&
                immediate_out === (expect_zero ? 32'd0 : immediate_in) &&
                rs1_addr_out === (expect_zero ? 5'd0 : rs1_addr_in) &&
                rs2_addr_out === (expect_zero ? 5'd0 : rs2_addr_in) &&
                rd_addr_out === (expect_zero ? 5'd0 : rd_addr_in) &&
                opcode_out === (expect_zero ? 7'd0 : opcode_in) &&
                funct3_out === (expect_zero ? 3'd0 : funct3_in) &&
                funct7_out === (expect_zero ? 7'd0 : funct7_in) &&
                reg_write_out === (expect_zero ? 1'b0 : reg_write_in) &&
                mem_write_out === (expect_zero ? 1'b0 : mem_write_in) &&
                mem_to_reg_out === (expect_zero ? 1'b0 : mem_to_reg_in) &&
                alu_src_out === (expect_zero ? 1'b0 : alu_src_in) &&
                branch_out === (expect_zero ? 1'b0 : branch_in) &&
                jump_out === (expect_zero ? 1'b0 : jump_in)
            ) begin
                tests_passed = tests_passed + 1;
                $display("PASS: PC=%h", pc_out);
            end
            else begin
                $display("FAIL: PC=%h Expected=%h", pc_out, expected_pc);
            end
        end
    endtask

    initial begin
        clk = 0;
        reset_n = 0;
        flush = 0;

        pc_in = 0;
        pc_plus4_in = 0;
        rs1_data_in = 0;
        rs2_data_in = 0;
        immediate_in = 0;
        rs1_addr_in = 0;
        rs2_addr_in = 0;
        rd_addr_in = 0;
        opcode_in = 0;
        funct3_in = 0;
        funct7_in = 0;

        reg_write_in = 0;
        mem_write_in = 0;
        mem_to_reg_in = 0;
        alu_src_in = 0;
        branch_in = 0;
        jump_in = 0;

        // Test 1: Reset
        #2;
        check_outputs(1, 32'd0);

        // Test 2: Normal operation
        reset_n = 1;
        pc_in = 32'd8;
        pc_plus4_in = 32'd12;
        rs1_data_in = 32'd10;
        rs2_data_in = 32'd20;
        immediate_in = 32'd5;
        rs1_addr_in = 5'd1;
        rs2_addr_in = 5'd2;
        rd_addr_in = 5'd3;
        opcode_in = 7'b0010011;
        funct3_in = 3'b000;
        funct7_in = 7'b0000000;

        reg_write_in = 1;
        mem_write_in = 0;
        mem_to_reg_in = 0;
        alu_src_in = 1;
        branch_in = 0;
        jump_in = 0;

        @(posedge clk);
        #1;
        check_outputs(0, 32'd8);

        // Test 3: Flush
        flush = 1;

        @(posedge clk);
        #1;
        check_outputs(1, 32'd0);

        // Test 4: Resume after flush
        flush = 0;
        pc_in = 32'd16;
        pc_plus4_in = 32'd20;

        @(posedge clk);
        #1;
        check_outputs(0, 32'd16);

        $display("Tests passed: %0d/4", tests_passed);
        $finish;
    end

endmodule
