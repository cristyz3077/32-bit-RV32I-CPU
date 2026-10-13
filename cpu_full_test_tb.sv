
`timescale 1ns/1ps

module cpu_full_test_tb;

    logic clk;
    logic reset_n;

    integer tests_passed;

    cpu_top #(
        .PROGRAM_FILE("cpu_full_test.hex")
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
                         reg_num, expected,
                         dut.rf_inst.regs[reg_num]);
            end
        end
    endtask

    initial begin
        clk = 0;
        reset_n = 0;
        tests_passed = 0;

        #2;
        reset_n = 1;

        // Execute first six instructions.
        repeat (6) @(posedge clk);
        #1;

        check_reg(1, 5);
        check_reg(2, 10);
        check_reg(3, 15);
        check_reg(4, 15);

        // BEQ should skip the instruction at PC = 24.
        if (dut.pc === 32'd28) begin
            $display("PASS: BEQ skipped instruction");
            tests_passed = tests_passed + 1;
        end else begin
            $display("FAIL: Expected PC = 28, got %0d", dut.pc);
        end

        // Execute instruction at PC = 28.
        @(posedge clk);
        #1;

        check_reg(5, 0);
        check_reg(6, 7);

        $display("Tests passed: %0d/7", tests_passed);
        $finish;
    end

endmodule
