
module id_ex_reg (
    input logic clk,
    input logic reset_n,
    input logic flush,

    // Inputs from ID stage
    input logic [31:0] pc_in,
    input logic [31:0] pc_plus4_in,
    input logic [31:0] rs1_data_in,
    input logic [31:0] rs2_data_in,
    input logic [31:0] immediate_in,
    input logic [4:0] rs1_addr_in,
    input logic [4:0] rs2_addr_in,
    input logic [4:0] rd_addr_in,
    input logic [6:0] opcode_in,
    input logic [2:0] funct3_in,
    input logic [6:0] funct7_in,

    input logic reg_write_in,
    input logic mem_write_in,
    input logic mem_to_reg_in,
    input logic alu_src_in,
    input logic branch_in,
    input logic jump_in,

    output logic [31:0] pc_out,
    output logic [31:0] pc_plus4_out,
    output logic [31:0] rs1_data_out,
    output logic [31:0] rs2_data_out,
    output logic [31:0] immediate_out,
    output logic [4:0] rs1_addr_out,
    output logic [4:0] rs2_addr_out,
    output logic [4:0] rd_addr_out,
    output logic [6:0] opcode_out,
    output logic [2:0] funct3_out,
    output logic [6:0] funct7_out,

    output logic reg_write_out,
    output logic mem_write_out,
    output logic mem_to_reg_out,
    output logic alu_src_out,
    output logic branch_out,
    output logic jump_out
);

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            pc_out <= 0;
            pc_plus4_out <= 0;
            rs1_data_out <= 0;
            rs2_data_out <= 0;
            immediate_out <= 0;

            rs1_addr_out <= 0;
            rs2_addr_out <= 0;
            rd_addr_out <= 0;
            opcode_out <= 0;
            funct3_out <= 0;
            funct7_out <= 0;

            reg_write_out <= 0;
            mem_write_out <= 0;
            mem_to_reg_out <= 0;
            alu_src_out <= 0;
            branch_out <= 0;
            jump_out <= 0;
        end
        else if (flush) begin
            pc_out <= 0;
            pc_plus4_out <= 0;
            rs1_data_out <= 0;
            rs2_data_out <= 0;
            immediate_out <= 0;

            rs1_addr_out <= 0;
            rs2_addr_out <= 0;
            rd_addr_out <= 0;
            opcode_out <= 0;
            funct3_out <= 0;
            funct7_out <= 0;

            reg_write_out <= 0;
            mem_write_out <= 0;
            mem_to_reg_out <= 0;
            alu_src_out <= 0;
            branch_out <= 0;
            jump_out <= 0;
        end
        else begin
            pc_out <= pc_in;
            pc_plus4_out <= pc_plus4_in;
            rs1_data_out <= rs1_data_in;
            rs2_data_out <= rs2_data_in;
            immediate_out <= immediate_in;

            rs1_addr_out <= rs1_addr_in;
            rs2_addr_out <= rs2_addr_in;
            rd_addr_out <= rd_addr_in;
            opcode_out <= opcode_in;
            funct3_out <= funct3_in;
            funct7_out <= funct7_in;

            reg_write_out <= reg_write_in;
            mem_write_out <= mem_write_in;
            mem_to_reg_out <= mem_to_reg_in;
            alu_src_out <= alu_src_in;
            branch_out <= branch_in;
            jump_out <= jump_in;
        end
    end
endmodule
