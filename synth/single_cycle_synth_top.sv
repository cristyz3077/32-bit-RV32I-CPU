module single_cycle_synth_top #(
    parameter PROGRAM_FILE = "programs/program.hex"
) (
    input logic clk,
    input logic reset_n,
    output logic [31:0] debug_pc,
    output logic debug_reg_write,
    output logic [4:0] debug_rd_addr,
    output logic [31:0] debug_writeback_data
);

// Single cycle CPU
cpu_top #(.PROGRAM_FILE(PROGRAM_FILE)) cpu (
    .clk(clk),
    .reset_n(reset_n),
    .debug_pc(debug_pc),
    .debug_reg_write(debug_reg_write),
    .debug_rd_addr(debug_rd_addr),
    .debug_writeback_data(debug_writeback_data)
);

endmodule
