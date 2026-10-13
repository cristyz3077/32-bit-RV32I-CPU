
module cpu_top (
    input logic clk,
    input logic reset_n
);

    logic [31:0] pc;
    logic [31:0] next_pc;
    logic [31:0] instruction;

    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;

    logic [4:0] rs1_addr;
    logic [4:0] rs2_addr;
    logic [4:0] rd_addr;

    logic [31:0] rs1_data;
    logic [31:0] rs2_data;
    logic [31:0] writeback_data;
    logic [31:0] immediate;

    logic reg_write;
    logic alu_src;
    logic mem_write;
    logic mem_to_reg;
    logic branch;
    logic jump;

    logic [3:0] alu_op;
    logic [31:0] alu_B;
    logic [31:0] alu_result;
    logic [31:0] mem_read_data;

    // Program Counter
    program_counter pc_inst (
        .clk(clk),
        .reset_n(reset_n),
        .next_pc(next_pc),
        .pc(pc)
    );

    assign next_pc = pc + 32'd4;

    // Instruction Memory
    instruction_memory imem_inst (
        .pc(pc),
        .instruction(instruction)
    );

    // Instruction fields
    assign opcode   = instruction[6:0];
    assign rd_addr  = instruction[11:7];
    assign funct3   = instruction[14:12];
    assign rs1_addr = instruction[19:15];
    assign rs2_addr = instruction[24:20];
    assign funct7   = instruction[31:25];

    // Main Control Unit
    control_unit control_inst (
        .opcode(opcode),
        .reg_write(reg_write),
        .alu_src(alu_src),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .branch(branch),
        .jump(jump)
    );

    // Register File
    register_file rf_inst (
        .clk(clk),
        .reset_n(reset_n),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .rd_addr(rd_addr),
        .wr_data(writeback_data),
        .rf_wr_en(reg_write)
    );

    // Immediate Generator
    imm_gen imm_inst (
        .instruction(instruction),
        .immediate(immediate)
    );

    // ALU Control
    alu_control alu_control_inst (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .alu_op(alu_op)
    );

    // ALU input selection
    assign alu_B = alu_src ? immediate : rs2_data;

    // ALU
    alu alu_inst (
        .A(rs1_data),
        .B(alu_B),
        .alu_op(alu_op),
        .Result(alu_result)
    );

    // Data Memory
    data_memory dmem_inst (
        .clk(clk),
        .mem_write(mem_write),
        .address(alu_result),
        .write_data(rs2_data),
        .read_data(mem_read_data)
    );

    // Writeback selection
    assign writeback_data = mem_to_reg ? mem_read_data : alu_result;

endmodule
