module control_unit(
    input logic [6:0] opcode, 
    output logic reg_write, //write?
    output logic alu_src, //use immediate?
    output logic mem_write, //write in memory?
    output logic mem_to_reg,
    output logic branch,
    output logic jump
);
always_comb begin 
    reg_write = 1'b0;
    alu_src = 1'b0;
    mem_write = 1'b0;
    mem_to_reg = 1'b0;
    branch = 1'b0;
    jump = 1'b0;

    case(opcode)
    // R-type
    7'b0110011: begin
        reg_write = 1'b1;
        alu_src   = 1'b0;
        mem_write = 1'b0;  
end 
// I-type ALU
    7'b0010011: begin
        reg_write = 1'b1;
        alu_src   = 1'b1;
        mem_write = 1'b0;
end

// S-type
    7'b0100011: begin
        reg_write = 1'b0;
        alu_src   = 1'b1;
        mem_write = 1'b1;
end
// Load
    7'b0000011: begin
        reg_write = 1'b1;
        alu_src   = 1'b1;
        mem_write = 1'b0;
        mem_to_reg = 1'b1;
end
// B-type
    7'b1100011: begin
        reg_write  = 1'b0;
        alu_src    = 1'b0;
        mem_write  = 1'b0;
        mem_to_reg = 1'b0;
        branch = 1'b1;
end
// J-type
    7'b1101111: begin
        reg_write  = 1'b1;
        alu_src = 1'b0;
        mem_write  = 1'b0;
        mem_to_reg = 1'b0;
        branch  = 1'b0;
        jump = 1'b1;
end
// U-type
    7'b0110111, 7'b0010111: begin
        reg_write  = 1'b1;
        alu_src    = 1'b1;
        mem_write  = 1'b0;
        mem_to_reg = 1'b0;
        branch     = 1'b0;
        jump       = 1'b0;
end
// JALR
    7'b1100111: begin
        reg_write  = 1'b1;
        alu_src    = 1'b1;
        mem_write  = 1'b0;
        mem_to_reg = 1'b0;
        branch     = 1'b0;
        jump       = 1'b1;
end
    default: begin
        reg_write  = 1'b0;
        alu_src    = 1'b0;
        mem_write  = 1'b0;
        mem_to_reg = 1'b0;
        branch     = 1'b0;
        jump       = 1'b0;
end
    endcase 
end 

endmodule