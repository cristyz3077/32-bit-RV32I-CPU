
module program_counter (
    input logic clk,
    input logic reset_n,
    input logic [31:0] next_pc,
    output logic [31:0] pc
);

always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n)
        pc <= 32'd0;
    else
        pc <= next_pc;
end

endmodule
