
`timescale 1ns/1ps

module instruction_memory_tb;

    logic [31:0] pc;
    logic [31:0] instruction;

    instruction_memory dut (
        .pc(pc),
        .instruction(instruction)
    );

    initial begin
        pc = 32'd0;
        #1;
        if (instruction == 32'h00500093)
            $display("PASS: Instruction 1");
        else
            $display("FAIL: Instruction 1");

        pc = 32'd4;
        #1;
        if (instruction == 32'h00a00113)
            $display("PASS: Instruction 2");
        else
            $display("FAIL: Instruction 2");

        pc = 32'd8;
        #1;
        if (instruction == 32'h002081b3)
            $display("PASS: Instruction 3");
        else
            $display("FAIL: Instruction 3");

        $finish;
    end

endmodule
