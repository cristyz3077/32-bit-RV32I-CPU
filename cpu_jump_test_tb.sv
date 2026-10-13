
`timescale 1ns/1ps

module cpu_jump_test_tb;

    logic clk;
    logic reset_n;
    integer tests_passed;

    cpu_top #(
        .PROGRAM_FILE("cpu_jump_test.hex")
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
                $display("PASS: x%0d = %0d", reg_num, expected);
                tests_passed = tests_passed + 1;
            end else begin
                $display("FAIL: x%0d expected %0d, got %0d",
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

        repeat (6) @(posedge clk);
        #1;

        check_reg(1, 5);
        check_reg(2, 0);
        check_reg(3, 7);
        check_reg(4, 32);
        check_reg(5, 8);
        check_reg(6, 24);
        check_reg(7, 0);
        check_reg(8, 0);
        check_reg(9, 0);
        check_reg(10, 13);

        $display("Tests passed: %0d/10", tests_passed);
        $finish;
    end

endmodule
