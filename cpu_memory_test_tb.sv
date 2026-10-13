
`timescale 1ns/1ps

module cpu_memory_test_tb;

    logic clk;
    logic reset_n;
    integer tests_passed;

    cpu_top #(
        .PROGRAM_FILE("cpu_memory_test.hex")
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

        repeat (13) @(posedge clk);
        #1;

        check_reg(1, 32'hFFFFFFFF);
        check_reg(2, 32'hFFFFFFFF);
        check_reg(3, 32'h000000FF);
        check_reg(4, 32'hFFFFFFFF);
        check_reg(5, 32'h0000FFFF);
        check_reg(6, 32'h0000007F);
        check_reg(7, 32'h0000007F);
        check_reg(8, 32'hFFFFFFFE);
        check_reg(9, 32'h0000FFFE);
        check_reg(10, 32'hFFFFFFFE);

        $display("Tests passed: %0d/10", tests_passed);
        $finish;
    end

endmodule
