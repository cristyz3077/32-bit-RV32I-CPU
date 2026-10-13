
`timescale 1ns/1ps

module cpu_alu_full_test_tb;

    logic clk;
    logic reset_n;
    integer tests_passed;

    cpu_top #(
        .PROGRAM_FILE("cpu_alu_full_test.hex")
    ) dut (
        .clk(clk),
        .reset_n(reset_n)
    );

    always #5 clk = ~clk;

    task check_reg;
        input [4:0] reg_num;
        input [31:0] expected;
        begin
            if (dut.rf_inst.regs[reg_num] === expected) begin
                $display("PASS: x%0d = %h", reg_num, expected);
                tests_passed = tests_passed + 1;
            end else begin
                $display("FAIL: x%0d expected %h, got %h",
                    reg_num, expected, dut.rf_inst.regs[reg_num]);
            end
        end
    endtask

    initial begin
        clk = 0;
        reset_n = 0;
        tests_passed = 0;

        #2;
        reset_n = 1;

        repeat (19) @(posedge clk);
        #1;

        check_reg(1, 32'd8);
        check_reg(2, 32'd2);
        check_reg(3, 32'd6);
        check_reg(4, 32'd32);
        check_reg(5, 32'd0);
        check_reg(6, 32'd0);
        check_reg(7, 32'd10);
        check_reg(8, 32'd10);
        check_reg(9, 32'd0);
        check_reg(10, 32'd2);
        check_reg(11, 32'd2);
        check_reg(12, 32'd64);
        check_reg(13, 32'd1);
        check_reg(14, 32'd1);
        check_reg(15, 32'd0);
        check_reg(16, 32'd0);
        check_reg(17, 32'd7);
        check_reg(18, 32'd15);
        check_reg(19, 32'd8);

        $display("Tests passed: %0d/19", tests_passed);
        $finish;
    end

endmodule
