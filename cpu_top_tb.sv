
`timescale 1ns/1ps

module cpu_top_tb;

    logic clk;
    logic reset_n;

    cpu_top dut (
        .clk(clk),
        .reset_n(reset_n)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset_n = 0;

        #2;
        reset_n = 1;

        // Execute instruction 1: addi x1, x0, 5
        @(posedge clk);
        #1;
        if (dut.rf_inst.regs[1] === 32'd5)
            $display("PASS: x1 = 5");
        else
            $display("FAIL: x1 = %d", dut.rf_inst.regs[1]);

        // Execute instruction 2: addi x2, x0, 10
        @(posedge clk);
        #1;
        if (dut.rf_inst.regs[2] === 32'd10)
            $display("PASS: x2 = 10");
        else
            $display("FAIL: x2 = %d", dut.rf_inst.regs[2]);

        // Execute instruction 3: add x3, x1, x2
        @(posedge clk);
        #1;
        if (dut.rf_inst.regs[3] === 32'd15)
            $display("PASS: x3 = 15");
        else
            $display("FAIL: x3 = %d", dut.rf_inst.regs[3]);

        $finish;
    end

endmodule
