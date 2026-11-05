
module pipeline_cpu #(parameter PROGRAM_FILE = "programs/program.hex") (
    input logic clk,
    input logic reset_n
);

    // IF stage signals
    logic [31:0] pc;
    logic [31:0] pc_plus4;
    logic [31:0] instruction;
    logic stall;

    // Outputs from IF/ID register
    logic [31:0] if_id_pc;
    logic [31:0] if_id_instruction;

    // Calculate next instruction address
    assign pc_plus4 = pc + 32'd4;

    // Program counter
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            pc <= 32'd0;
        end
        else if (redirect) begin
            pc <= redirect_target;
        end
        else if (!stall) begin
            pc <= pc_plus4;
        end
    end

    // Instruction memory
    instruction_memory #(.PROGRAM_FILE(PROGRAM_FILE)) imem (
        .pc(pc),
        .instruction(instruction)
    );

    if_id_reg if_id (
        .clk(clk),
        .reset_n(reset_n),
        .stall(stall),
        .flush(redirect),

        .pc_in(pc),
        .instruction_in(instruction),

        .pc_out(if_id_pc),
        .instruction_out(if_id_instruction)
    );

        // ID stage instruction fields
    logic [6:0] opcode;
    logic [4:0] rs1_addr;
    logic [4:0] rs2_addr;
    logic [4:0] rd_addr;
    logic [2:0] funct3;
    logic [6:0] funct7;

    // Decode instruction fields
    assign opcode   = if_id_instruction[6:0];
    assign rd_addr  = if_id_instruction[11:7];
    assign funct3   = if_id_instruction[14:12];
    assign rs1_addr = if_id_instruction[19:15];
    assign rs2_addr = if_id_instruction[24:20];
    assign funct7   = if_id_instruction[31:25];

        // Register file outputs
    logic [31:0] rs1_data;
    logic [31:0] rs2_data;

    // Writeback signals
    logic [4:0] wb_rd_addr;
    logic [31:0] wb_wr_data;
    logic wb_reg_write;

    // Register file
    register_file rf (
        .clk(clk),
        .reset_n(reset_n),

        // Read register addresses from ID stage
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),

        // Read register values
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),

        // Writeback connections
        .rd_addr(wb_rd_addr),
        .wr_data(wb_wr_data),
        .rf_wr_en(wb_reg_write)
    );

// ID stage control signals
logic [31:0] immediate;
logic reg_write;
logic mem_write;
logic mem_to_reg;
logic alu_src;
logic branch;
logic jump;

// Immediate generator
imm_gen imm (
    .instruction(if_id_instruction),
    .immediate(immediate)
);

// Control unit
control_unit control (
    .opcode(opcode),
    .reg_write(reg_write),
    .mem_write(mem_write),
    .mem_to_reg(mem_to_reg),
    .alu_src(alu_src),
    .branch(branch),
    .jump(jump)
);

// ID/EX signals
logic [31:0] id_ex_pc;
logic [31:0] id_ex_pc_plus4;
logic [31:0] id_ex_rs1_data;
logic [31:0] id_ex_rs2_data;
logic [31:0] id_ex_immediate;
logic [4:0] id_ex_rs1_addr;
logic [4:0] id_ex_rs2_addr;
logic [4:0] id_ex_rd_addr;
logic [6:0] id_ex_opcode;
logic [2:0] id_ex_funct3;
logic [6:0] id_ex_funct7;
logic id_ex_reg_write;
logic id_ex_mem_write;
logic id_ex_mem_to_reg;
logic id_ex_alu_src;
logic id_ex_branch;
logic id_ex_jump;

// EX/MEM signals
logic [31:0] ex_mem_alu_result;
logic [31:0] ex_mem_rs2_data;
logic [31:0] ex_mem_pc_plus4;
logic [31:0] ex_mem_immediate;
logic [4:0] ex_mem_rd_addr;
logic [2:0] ex_mem_funct3;
logic ex_mem_reg_write;
logic ex_mem_mem_write;
logic ex_mem_mem_to_reg;
logic ex_mem_jump;

// MEM/WB signals
logic [31:0] mem_wb_alu_result;
logic [31:0] mem_wb_mem_data;
logic [31:0] mem_wb_pc_plus4;
logic [31:0] mem_wb_immediate;
logic [4:0] mem_wb_rd_addr;
logic mem_wb_reg_write;
logic mem_wb_mem_to_reg;
logic mem_wb_jump;

logic [31:0] id_rs1_data;
logic [31:0] id_rs2_data;

// Forward writeback data to the ID stage
assign id_rs1_data = (wb_reg_write && wb_rd_addr != 0 && wb_rd_addr == rs1_addr)
                     ? wb_wr_data : rs1_data;
assign id_rs2_data = (wb_reg_write && wb_rd_addr != 0 && wb_rd_addr == rs2_addr)
                     ? wb_wr_data : rs2_data;

// ID/EX register
id_ex_reg id_ex (
    .clk(clk),
    .reset_n(reset_n),
    .flush(redirect || stall),
    .pc_in(if_id_pc),
    .pc_out(id_ex_pc),
    .pc_plus4_in(if_id_pc + 32'd4),
    .pc_plus4_out(id_ex_pc_plus4),
    .rs1_data_in(id_rs1_data),
    .rs1_data_out(id_ex_rs1_data),
    .rs2_data_in(id_rs2_data),
    .rs2_data_out(id_ex_rs2_data),
    .immediate_in(immediate),
    .immediate_out(id_ex_immediate),
    .rs1_addr_in(rs1_addr),
    .rs1_addr_out(id_ex_rs1_addr),
    .rs2_addr_in(rs2_addr),
    .rs2_addr_out(id_ex_rs2_addr),
    .rd_addr_in(rd_addr),
    .rd_addr_out(id_ex_rd_addr),
    .opcode_in(opcode),
    .opcode_out(id_ex_opcode),
    .funct3_in(funct3),
    .funct3_out(id_ex_funct3),
    .funct7_in(funct7),
    .funct7_out(id_ex_funct7),
    .reg_write_in(reg_write),
    .reg_write_out(id_ex_reg_write),
    .mem_write_in(mem_write),
    .mem_write_out(id_ex_mem_write),
    .mem_to_reg_in(mem_to_reg),
    .mem_to_reg_out(id_ex_mem_to_reg),
    .alu_src_in(alu_src),
    .alu_src_out(id_ex_alu_src),
    .branch_in(branch),
    .branch_out(id_ex_branch),
    .jump_in(jump),
    .jump_out(id_ex_jump)
);

// Load-use hazard detection
logic uses_rs1;
logic uses_rs2;
assign uses_rs1 = opcode == 7'b0110011 ||
                  opcode == 7'b0010011 ||
                  opcode == 7'b0000011 ||
                  opcode == 7'b0100011 ||
                  opcode == 7'b1100011 ||
                  opcode == 7'b1100111;
assign uses_rs2 = opcode == 7'b0110011 ||
                  opcode == 7'b0100011 ||
                  opcode == 7'b1100011;
assign stall = id_ex_mem_to_reg && id_ex_reg_write && id_ex_rd_addr != 0 &&
               ((uses_rs1 && rs1_addr == id_ex_rd_addr) ||
                (uses_rs2 && rs2_addr == id_ex_rd_addr));

logic [31:0] ex_rs1;
logic [31:0] ex_rs2;
logic [31:0] ex_alu_a;
logic [31:0] ex_alu_b;
logic [31:0] ex_alu_result;
logic [31:0] mem_forward_data;
logic [3:0] ex_alu_op;
assign mem_forward_data = ex_mem_jump ? ex_mem_pc_plus4 : ex_mem_alu_result;
// Forward data to the EX stage
// EX/MEM data has priority over writeback data
always @* begin
    ex_rs1 = id_ex_rs1_data;
    ex_rs2 = id_ex_rs2_data;
    if (wb_reg_write && wb_rd_addr != 0) begin
        if (wb_rd_addr == id_ex_rs1_addr) begin
            ex_rs1 = wb_wr_data;
        end
        if (wb_rd_addr == id_ex_rs2_addr) begin
            ex_rs2 = wb_wr_data;
        end
    end
    if (ex_mem_reg_write && !ex_mem_mem_to_reg && ex_mem_rd_addr != 0) begin
        if (ex_mem_rd_addr == id_ex_rs1_addr) begin
            ex_rs1 = mem_forward_data;
        end
        if (ex_mem_rd_addr == id_ex_rs2_addr) begin
            ex_rs2 = mem_forward_data;
        end
    end
end
assign ex_alu_a = (id_ex_opcode == 7'b0010111) ? id_ex_pc :
                  (id_ex_opcode == 7'b0110111) ? 32'd0 : ex_rs1;
assign ex_alu_b = id_ex_alu_src ? id_ex_immediate : ex_rs2;

// ALU control
alu_control ex_control (
    .opcode(id_ex_opcode),
    .funct3(id_ex_funct3),
    .funct7(id_ex_funct7),
    .alu_op(ex_alu_op)
);

// ALU
alu ex_alu (
    .A(ex_alu_a),
    .B(ex_alu_b),
    .alu_op(ex_alu_op),
    .Result(ex_alu_result)
);

// Branch and jump signals
logic branch_taken;
logic redirect;
logic [31:0] redirect_target;
always @* begin
    branch_taken = 1'b0;
    if (id_ex_branch) begin
        case (id_ex_funct3)
            3'b000: branch_taken = ex_rs1 == ex_rs2;
            3'b001: branch_taken = ex_rs1 != ex_rs2;
            3'b100: branch_taken = $signed(ex_rs1) < $signed(ex_rs2);

            3'b101: branch_taken = $signed(ex_rs1) >= $signed(ex_rs2);

            3'b110: branch_taken = ex_rs1 < ex_rs2;
            3'b111: branch_taken = ex_rs1 >= ex_rs2;
            default: branch_taken = 1'b0;
        endcase
    end
end
assign redirect = id_ex_jump || branch_taken;
assign redirect_target = (id_ex_opcode == 7'b1100111)
                       ? ((ex_rs1 + id_ex_immediate) & 32'hfffffffe)
                       : id_ex_pc + id_ex_immediate;

// EX/MEM register
ex_mem_reg ex_mem (
    .clk(clk),
    .reset_n(reset_n),
    .flush(1'b0),
    .alu_result_in(ex_alu_result),
    .alu_result_out(ex_mem_alu_result),
    .rs2_data_in(ex_rs2),
    .rs2_data_out(ex_mem_rs2_data),
    .pc_plus4_in(id_ex_pc_plus4),
    .pc_plus4_out(ex_mem_pc_plus4),
    .immediate_in(id_ex_immediate),
    .immediate_out(ex_mem_immediate),
    .rd_addr_in(id_ex_rd_addr),
    .rd_addr_out(ex_mem_rd_addr),
    .funct3_in(id_ex_funct3),
    .funct3_out(ex_mem_funct3),
    .reg_write_in(id_ex_reg_write),
    .reg_write_out(ex_mem_reg_write),
    .mem_write_in(id_ex_mem_write),
    .mem_write_out(ex_mem_mem_write),
    .mem_to_reg_in(id_ex_mem_to_reg),
    .mem_to_reg_out(ex_mem_mem_to_reg),
    .jump_in(id_ex_jump),
    .jump_out(ex_mem_jump)
);

logic [31:0] mem_read_data;

// Data memory
data_memory dmem (
    .clk(clk),
    .mem_write(ex_mem_mem_write && reset_n),
    .funct3(ex_mem_funct3),
    .address(ex_mem_alu_result),
    .write_data(ex_mem_rs2_data),
    .read_data(mem_read_data)
);

// MEM/WB register
mem_wb_reg mem_wb (
    .clk(clk),
    .reset_n(reset_n),
    .flush(1'b0),
    .alu_result_in(ex_mem_alu_result),
    .alu_result_out(mem_wb_alu_result),
    .mem_data_in(mem_read_data),
    .mem_data_out(mem_wb_mem_data),
    .pc_plus4_in(ex_mem_pc_plus4),
    .pc_plus4_out(mem_wb_pc_plus4),
    .immediate_in(ex_mem_immediate),
    .immediate_out(mem_wb_immediate),
    .rd_addr_in(ex_mem_rd_addr),
    .rd_addr_out(mem_wb_rd_addr),
    .reg_write_in(ex_mem_reg_write),
    .reg_write_out(mem_wb_reg_write),
    .mem_to_reg_in(ex_mem_mem_to_reg),
    .mem_to_reg_out(mem_wb_mem_to_reg),
    .jump_in(ex_mem_jump),
    .jump_out(mem_wb_jump)
);

// Writeback
assign wb_rd_addr = mem_wb_rd_addr;
assign wb_reg_write = mem_wb_reg_write;
assign wb_wr_data = mem_wb_jump ? mem_wb_pc_plus4 :
                    mem_wb_mem_to_reg ? mem_wb_mem_data : mem_wb_alu_result;
endmodule
