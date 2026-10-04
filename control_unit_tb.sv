module control_unit_test;

logic [6:0] opcode;
logic reg_write;
logic alu_src;
logic mem_write;
logic mem_to_reg;
logic branch;
logic jump;

control_unit dut (
    .opcode(opcode),
    .reg_write(reg_write),
    .alu_src(alu_src),
    .mem_write(mem_write),
    .mem_to_reg(mem_to_reg),
    .branch(branch),
    .jump(jump)
);

initial begin

    // R-type
    opcode = 7'b0110011;
    #1;
    if (reg_write == 1'b1 &&
        alu_src == 1'b0 &&
        mem_write == 1'b0 &&
        mem_to_reg == 1'b0 &&
        branch == 1'b0 &&
        jump == 1'b0)
        $display("Pass: R-type");
    else
        $display("Fail: R-type");


    // I-type ALU
    opcode = 7'b0010011;
    #1;
    if (reg_write == 1'b1 &&
        alu_src == 1'b1 &&
        mem_write == 1'b0 &&
        mem_to_reg == 1'b0 &&
        branch == 1'b0 &&
        jump == 1'b0)
        $display("Pass: I-type");
    else
        $display("Fail: I-type");


    // S-type
    opcode = 7'b0100011;
    #1;
    if (reg_write == 1'b0 &&
        alu_src == 1'b1 &&
        mem_write == 1'b1 &&
        mem_to_reg == 1'b0 &&
        branch == 1'b0 &&
        jump == 1'b0)
        $display("Pass: S-type");
    else
        $display("Fail: S-type");


    // Load
    opcode = 7'b0000011;
    #1;
    if (reg_write == 1'b1 &&
        alu_src == 1'b1 &&
        mem_write == 1'b0 &&
        mem_to_reg == 1'b1 &&
        branch == 1'b0 &&
        jump == 1'b0)
        $display("Pass: Load");
    else
        $display("Fail: Load");


    // B-type
    opcode = 7'b1100011;
    #1;
    if (reg_write == 1'b0 &&
        alu_src == 1'b0 &&
        mem_write == 1'b0 &&
        mem_to_reg == 1'b0 &&
        branch == 1'b1 &&
        jump == 1'b0)
        $display("Pass: B-type");
    else
        $display("Fail: B-type");


    // J-type (JAL)
    opcode = 7'b1101111;
    #1;
    if (reg_write == 1'b1 &&
        alu_src == 1'b0 &&
        mem_write == 1'b0 &&
        mem_to_reg == 1'b0 &&
        branch == 1'b0 &&
        jump == 1'b1)
        $display("Pass: JAL");
    else
        $display("Fail: JAL");


    // U-type LUI
    opcode = 7'b0110111;
    #1;
    if (reg_write == 1'b1 &&
        alu_src == 1'b1 &&
        mem_write == 1'b0 &&
        mem_to_reg == 1'b0 &&
        branch == 1'b0 &&
        jump == 1'b0)
        $display("Pass: LUI");
    else
        $display("Fail: LUI");


    // U-type AUIPC
    opcode = 7'b0010111;
    #1;
    if (reg_write == 1'b1 &&
        alu_src == 1'b1 &&
        mem_write == 1'b0 &&
        mem_to_reg == 1'b0 &&
        branch == 1'b0 &&
        jump == 1'b0)
        $display("Pass: AUIPC");
    else
        $display("Fail: AUIPC");


    // JALR
    opcode = 7'b1100111;
    #1;
    if (reg_write == 1'b1 &&
        alu_src == 1'b1 &&
        mem_write == 1'b0 &&
        mem_to_reg == 1'b0 &&
        branch == 1'b0 &&
        jump == 1'b1)
        $display("Pass: JALR");
    else
        $display("Fail: JALR");


    // Invalid opcode
    opcode = 7'b1111111;
    #1;
    if (reg_write == 1'b0 &&
        alu_src == 1'b0 &&
        mem_write == 1'b0 &&
        mem_to_reg == 1'b0 &&
        branch == 1'b0 &&
        jump == 1'b0)
        $display("Pass: Default");
    else
        $display("Fail: Default");


    $finish;

end

endmodule