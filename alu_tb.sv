module alu_test;
logic [31:0]A;
logic [31:0]B;
logic [3:0]alu_op;
logic [31:0]Result;
alu dut (
    .A(A), .B(B), .alu_op(alu_op), .Result(Result)
);

initial begin 
    $dumpfile("alu.vcd");
    $dumpvars(0, alu_test);
    A = 2;
    B = 2;
    alu_op = 4'b0000;
    #10;
    if (Result == 4)
        $display("Pass");
    else
        $display("Fail");
    alu_op = 4'b0001;
    #10;
    if (Result == 0)
        $display("Pass");
    else 
        $display("Fail");
    A = 8;
    B = 1;
    alu_op = 4'b0010;
    #10;
    if (Result == 16)
        $display("Pass");
    else
        $display("Fail");
    A = -2;
    B = -5;
    alu_op = 4'b0011;
    #10;
    if (Result == 0)
        $display("True");
    else 
        $display("Fail");
    A = 2;
    B = 3;
    alu_op = 4'b0100;
    #10;
    if (Result == 1)
        $display("True");
    else 
        $display("Fail");
    alu_op = 4'b0101;
    #10;
    if (Result == 1)
        $display("True");
    else
        $display("Fail");
    A = 8;
    B = 1;
    alu_op = 4'b0110;
    #10;
    if (Result == 4)
        $display("True");
    else 
        $display("Fail");
    A = -8;
    B = 1;
    alu_op = 4'b0111;
    #10;
    if (Result == -4)
        $display("True");
    else
        $display("Fail");
    A = 0;
    B = 0;
    alu_op = 4'b1000;
    #10;
    if (Result == 0)
        $display("True");
    else 
        $display("Fail");
    alu_op = 4'b1001;
    #10;
    if (Result == 0)
        $display("True");
    else 
        $display("Fail");


end
endmodule 
