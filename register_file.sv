module register_file (
    input logic clk, 
    input logic reset_n,
    //read register address
    input logic [4:0] rs1_addr,
    input logic [4:0] rs2_addr,
    //read data outputs
    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data,
    //write 
    input logic[4:0] rd_addr,
    input logic[31:0] wr_data,
    input logic rf_wr_en
);
logic [31:0] regs [0:31];
always_ff @(posedge clk or negedge reset_n) begin 
    if (!reset_n) begin 
        integer i;
        for (i=0;i<32; i+=1)
            regs[i] <= 32'd0;
    end 
    else if (rf_wr_en && (rd_addr != 5'd0)) begin
        regs[rd_addr]<= wr_data;
    end 
end 
assign rs1_data = regs[rs1_addr];
assign rs2_data = regs[rs2_addr];
endmodule

            
