
`timescale 1ns/1ps

module if_id_reg_tb;

    logic clk;
    logic reset_n;
    logic stall;
    logic flush;

    logic [31:0] pc_in;
    logic [31:0] instruction_in;
    logic [31:0] pc_out;
    logic [31:0] instruction_out;

    integer tests_passed = 0;

    if_id_reg dut (
        .clk(clk),
        .reset_n(reset_n),
        .stall(stall),
        .flush(flush),
        .pc_in(pc_in),
        .instruction_in(instruction_in),
        .pc_out(pc_out),
        .instruction_out(instruction_out)
    );

    always #5 clk = ~clk;

    task check_outputs;
        input [31:0] expected_pc;
        input [31:0] expected_instruction;
        begin
            if (pc_out === expected_pc &&
                instruction_out === expected_instruction) begin
                $display("PASS: PC=%h Instruction=%h",
                         pc_out, instruction_out);
                tests_passed = tests_passed + 1;
            end else begin
                $display("FAIL: PC=%h Instruction=%h",
                         pc_out, instruction_out);
            end
        end
    endtask

    initial begin
        clk = 0;
        reset_n = 0;
        stall = 0;
        flush = 0;
        pc_in = 0;
        instruction_in = 0;

        #2;
        check_outputs(32'd0, 32'h00000013);

        reset_n = 1;

        // Test 1: Normal instruction
        pc_in = 32'd4;
        instruction_in = 32'h00500093;
        @(posedge clk);
        #1;
        check_outputs(32'd4, 32'h00500093);

        // Test 2: Stall
        stall = 1;
        pc_in = 32'd8;
        instruction_in = 32'h00a00113;
        @(posedge clk);
        #1;
        check_outputs(32'd4, 32'h00500093);

        // Test 3: Resume
        stall = 0;
        @(posedge clk);
        #1;
        check_outputs(32'd8, 32'h00a00113);

        // Test 4: Flush
        flush = 1;
        @(posedge clk);
        #1;
        check_outputs(32'd0, 32'h00000013);

        $display("Tests passed: %0d/5", tests_passed);
        $finish;
    end

endmodule
