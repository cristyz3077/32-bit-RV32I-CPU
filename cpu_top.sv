
module cpu_top #(
    parameter PROGRAM_FILE = "program.hex"
) (
    input logic clk,
    input logic reset_n
);

    logic [31:0] pc;
    logic [31:0] next_pc;
    logic [31:0] pc_plus4;
    logic [31:0] instruction;

    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;

    logic [4:0] rs1_addr;
    logic [4:0] rs2_addr;
    logic [4:0] rd_addr;

    logic [31:0] rs1_data;
    logic [31:0] rs2_data;
    logic [31:0] immediate;
    logic [31:0] writeback_data;

    logic reg_write;
    logic alu_src;
    logic mem_write;
    logic mem_to_reg;
    logic branch;
    logic jump;

    logic [3:0] alu_op;
    logic [31:0] alu_A;
    logic [31:0] alu_B;
    logic [31:0] alu_result;
    logic [31:0] mem_read_data;

    logic branch_taken;
    logic [31:0] branch_target;
    logic [31:0] jump_target;

    logic [31:0] lui_value;
    logic [31:0] auipc_value;

    logic rf_write_enable;
    logic data_mem_write_enable;

    // Program Counter
    program_counter pc_inst (
        .clk(clk),
        .reset_n(reset_n),
        .next_pc(next_pc),
        .pc(pc)
    );

    // Instruction Memory
    instruction_memory #(
        .PROGRAM_FILE(PROGRAM_FILE)
    ) imem_inst (
        .pc(pc),
        .instruction(instruction)
    );

    // Instruction Fields
    assign opcode   = instruction[6:0];
    assign rd_addr  = instruction[11:7];
    assign funct3   = instruction[14:12];
    assign rs1_addr = instruction[19:15];
    assign rs2_addr = instruction[24:20];
    assign funct7   = instruction[31:25];

    // Control Unit
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
        .rf_wr_en(rf_write_enable)
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

    // ALU Input Selection
    assign alu_A = rs1_data;
    assign alu_B = alu_src ? immediate : rs2_data;

    // ALU
    alu alu_inst (
        .A(alu_A),
        .B(alu_B),
        .alu_op(alu_op),
        .Result(alu_result)
    );

    // Data Memory
    assign data_mem_write_enable =
        mem_write && (opcode == 7'b0100011);

    data_memory dmem_inst (
        .clk(clk),
        .mem_write(data_mem_write_enable),
        .funct3(funct3),
        .address(alu_result),
        .write_data(rs2_data),
        .read_data(mem_read_data)
    );

    // Branch Comparison
    always_comb begin
        branch_taken = 1'b0;

        if (branch) begin
            case (funct3)
                3'b000: branch_taken = (rs1_data == rs2_data);
                3'b001: branch_taken = (rs1_data != rs2_data);
                3'b100: branch_taken =
                    ($signed(rs1_data) < $signed(rs2_data));
                3'b101: branch_taken =
                    ($signed(rs1_data) >= $signed(rs2_data));
                3'b110: branch_taken = (rs1_data < rs2_data);
                3'b111: branch_taken = (rs1_data >= rs2_data);
                default: branch_taken = 1'b0;
            endcase
        end
    end

    // PC Calculations
    assign pc_plus4 = pc + 32'd4;
    assign branch_target = pc + immediate;

    // Jump Target
    assign jump_target =
        (opcode == 7'b1100111)
        ? ((rs1_data + immediate) & 32'hFFFFFFFE)
        : (pc + immediate);

    // Next PC Selection
    always_comb begin
        next_pc = pc_plus4;

        if (branch_taken)
            next_pc = branch_target;
        else if (opcode == 7'b1101111 ||
                 opcode == 7'b1100111)
            next_pc = jump_target;
    end

    // LUI and AUIPC
    assign lui_value = immediate;
    assign auipc_value = pc + immediate;

    // Register Write Enable
    assign rf_write_enable =
        reg_write ||
        (opcode == 7'b0110111) ||
        (opcode == 7'b0010111) ||
        (opcode == 7'b1101111) ||
        (opcode == 7'b1100111);

    // Writeback Selection
    always_comb begin
        writeback_data = alu_result;

        case (opcode)
            7'b0000011:
                writeback_data = mem_read_data;

            7'b0110111:
                writeback_data = lui_value;

            7'b0010111:
                writeback_data = auipc_value;

            7'b1101111, 7'b1100111:
                writeback_data = pc_plus4;

            default:
                writeback_data = alu_result;
        endcase
    end

endmodule
