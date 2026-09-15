module register_test;
logic clk;
logic reset_n;
logic [4:0] rs1_addr;
logic [4:0] rs2_addr;
logic [31:0] rs1_data;
logic [31:0] rs2_data;
logic[4:0] rd_addr;
logic[31:0] wr_data;
logic rf_wr_en;

register_file dut(
    .clk(clk), .reset_n(reset_n), .rs1_addr(rs1_addr), .rs2_addr(rs2_addr),
    .rs1_data(rs1_data), .rs2_data(rs2_data), .rd_addr(rd_addr), .wr_data(wr_data), .rf_wr_en(rf_wr_en)
);

always #5 clk = ~clk;

initial begin
    clk = 0;
    reset_n = 0;
    rs1_addr = 0;
    rs2_addr = 0;
    rd_addr = 0;
    wr_data = 0;
    rf_wr_en = 0;
   
    #10;
    reset_n = 1;

    rf_wr_en = 1;
    rd_addr = 5'd3;
    wr_data = 32'd25;
    @(posedge clk);
    
    #1;

    rf_wr_en = 0;
    rs1_addr = 5'd3;
    #1;

    if (rs1_data == 32'd25) begin
        $display("Pass: x3 = 25");
    end
    else begin 
        $display("Fail: x3 is %d", rs1_data);
    end

    rf_wr_en = 1;
    rd_addr = 5'd0;
    wr_data= 32'd100;
    @(posedge clk);
    #1;

    rf_wr_en = 0;
    rs1_addr = 5'd0;
    
    #1;

    if (rs1_data == 32'd0) begin
        $display("Pass");
    end
    else begin 
        $display("Fail: x0 is %d", rs1_data);
    end 
end 
endmodule 