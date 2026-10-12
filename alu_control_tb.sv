
`timescale 1ns/1ps

module alu_control_tb;

    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;
    logic [3:0] alu_op;

    integer tests_passed = 0;
    integer tests_failed = 0;

    alu_control dut (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .alu_op(alu_op)
    );

    task check;
        input [3:0] expected;
        begin
            #1;
            if (alu_op === expected) begin
                $display("PASS: alu_op = %b", alu_op);
                tests_passed = tests_passed + 1;
            end
            else begin
                $display("FAIL: expected %b, got %b", expected, alu_op);
                tests_failed = tests_failed + 1;
            end
        end
    endtask

    initial begin

        // R-type ADD
        opcode = 7'b0110011;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        check(4'b0000);

        // R-type SUB
        opcode = 7'b0110011;
        funct3 = 3'b000;
        funct7 = 7'b0100000;
        check(4'b0001);

        // R-type SLL
        opcode = 7'b0110011;
        funct3 = 3'b001;
        funct7 = 7'b0000000;
        check(4'b0010);

        // R-type SLT
        funct3 = 3'b010;
        check(4'b0011);

        // R-type SLTU
        funct3 = 3'b011;
        check(4'b0100);

        // R-type XOR
        funct3 = 3'b100;
        check(4'b0101);

        // R-type SRL
        funct3 = 3'b101;
        funct7 = 7'b0000000;
        check(4'b0110);

        // R-type SRA
        funct7 = 7'b0100000;
        check(4'b0111);

        // R-type OR
        funct3 = 3'b110;
        funct7 = 7'b0000000;
        check(4'b1000);

        // R-type AND
        funct3 = 3'b111;
        check(4'b1001);

        // I-type ADDI
        opcode = 7'b0010011;
        funct3 = 3'b000;
        check(4'b0000);

        // I-type SLTI
        funct3 = 3'b010;
        check(4'b0011);

        // I-type SLTIU
        funct3 = 3'b011;
        check(4'b0100);

        // I-type XORI
        funct3 = 3'b100;
        check(4'b0101);

        // I-type ORI
        funct3 = 3'b110;
        check(4'b1000);

        // I-type ANDI
        funct3 = 3'b111;
        check(4'b1001);

        // I-type SLLI
        funct3 = 3'b001;
        funct7 = 7'b0000000;
        check(4'b0010);

        // I-type SRLI
        funct3 = 3'b101;
        funct7 = 7'b0000000;
        check(4'b0110);

        // I-type SRAI
        funct7 = 7'b0100000;
        check(4'b0111);

        // Load: address calculation
        opcode = 7'b0000011;
        check(4'b0000);

        // Store: address calculation
        opcode = 7'b0100011;
        check(4'b0000);

        // Branch: subtraction
        opcode = 7'b1100011;
        check(4'b0001);

        // JALR: address calculation
        opcode = 7'b1100111;
        check(4'b0000);

        // AUIPC: addition
        opcode = 7'b0010111;
        check(4'b0000);

        // Default
        opcode = 7'b1111111;
        check(4'b0000);

        $display("----------------------------");
        $display("Tests Passed: %0d", tests_passed);
        $display("Tests Failed: %0d", tests_failed);
        $display("----------------------------");

        $finish;
    end

endmodule
