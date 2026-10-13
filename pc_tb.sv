
`timescale 1ns/1ps

module program_counter_tb;

    logic clk;
    logic reset_n;
    logic [31:0] next_pc;
    logic [31:0] pc;

    integer tests_passed = 0;
    integer tests_failed = 0;

    program_counter dut (
        .clk(clk),
        .reset_n(reset_n),
        .next_pc(next_pc),
        .pc(pc)
    );

    always #5 clk = ~clk;

    task check;
        input [31:0] expected;
        begin
            #1;
            if (pc === expected) begin
                $display("PASS: pc = %0d", pc);
                tests_passed = tests_passed + 1;
            end
            else begin
                $display("FAIL: expected %0d, got %0d", expected, pc);
                tests_failed = tests_failed + 1;
            end
        end
    endtask

    initial begin
        clk = 0;
        reset_n = 1;
        next_pc = 0;

        // Test 1: Reset PC to zero
        #2;
        reset_n = 0;
        check(32'd0);

        // Release reset
        @(negedge clk);
        reset_n = 1;

        // Test 2: PC becomes 4
        next_pc = 32'd4;
        @(posedge clk);
        check(32'd4);

        // Test 3: PC becomes 8
        @(negedge clk);
        next_pc = 32'd8;
        @(posedge clk);
        check(32'd8);

        // Test 4: PC becomes 12
        @(negedge clk);
        next_pc = 32'd12;
        @(posedge clk);
        check(32'd12);

        // Test 5: Jump to address 100
        @(negedge clk);
        next_pc = 32'd100;
        @(posedge clk);
        check(32'd100);

        // Test 6: PC holds between clock edges
        @(negedge clk);
        next_pc = 32'd200;
        check(32'd100); 
        $display("Tests Passed: %0d", tests_passed);
        $display("Tests Failed: %0d", tests_failed);

        $finish;
    end

endmodule
