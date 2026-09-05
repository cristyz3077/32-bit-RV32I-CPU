module alu( 
    input logic [31:0]A,
    input logic [31:0]B,
    input logic [3:0]alu_op,
    output logic [31:0]Result
);
always_comb begin
    case(alu_op)
        default: Result = 32'b0;
        4'b0000: Result = A + B;
        4'b0001: Result = A - B;
        4'b0010: Result = A << B[4:0]; //SLL
        4'b0011: Result = ($signed(A) < $signed(B)); //SLT
        4'b0100: Result = A < B; //SLTU
        4'b0101: Result = A ^ B; // XOR
        4'b0110: Result = A >> B[4:0]; //SRL
        4'b0111: Result = $signed(A)>>>B[4:0]; //SRA
        4'b1000: Result = A | B;
        4'b1001: Result = A & B;
    endcase
end 
endmodule 


