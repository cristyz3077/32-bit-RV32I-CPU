
module mem_wb_reg (
    input logic clk,
    input logic reset_n,
    input logic flush,

    // Inputs from MEM stage
    input logic [31:0] alu_result_in,
    input logic [31:0] mem_data_in,
    input logic [31:0] pc_plus4_in,
    input logic [31:0] immediate_in,
    input logic [4:0] rd_addr_in,

    // Control signals
    input logic reg_write_in,
    input logic mem_to_reg_in,
    input logic jump_in,

    // Outputs to WB stage
    output logic [31:0] alu_result_out,
    output logic [31:0] mem_data_out,
    output logic [31:0] pc_plus4_out,
    output logic [31:0] immediate_out,
    output logic [4:0] rd_addr_out,

    // Control signal outputs
    output logic reg_write_out,
    output logic mem_to_reg_out,
    output logic jump_out
);

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            alu_result_out <= 0;
            mem_data_out <= 0;
            pc_plus4_out <= 0;
            immediate_out <= 0;
            rd_addr_out <= 0;

            reg_write_out <= 0;
            mem_to_reg_out <= 0;
            jump_out <= 0;
        end
        else if (flush) begin
            alu_result_out <= 0;
            mem_data_out <= 0;
            pc_plus4_out <= 0;
            immediate_out <= 0;
            rd_addr_out <= 0;

            reg_write_out <= 0;
            mem_to_reg_out <= 0;
            jump_out <= 0;
        end
        else begin
            alu_result_out <= alu_result_in;
            mem_data_out <= mem_data_in;
            pc_plus4_out <= pc_plus4_in;
            immediate_out <= immediate_in;
            rd_addr_out <= rd_addr_in;

            reg_write_out <= reg_write_in;
            mem_to_reg_out <= mem_to_reg_in;
            jump_out <= jump_in;
        end
    end

endmodule
