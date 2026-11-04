module imm_gen_test;
logic [31:0] instruction; 
logic [31:0] immediate;

imm_gen dut(
    .instruction(instruction),
    .immediate(immediate)
);
initial begin 
    //I-type
    instruction = {12'd22, 5'd3, 3'b000, 5'd2, 7'b0010011};
    #1;
    if (immediate == 32'd22) begin
    $display("Pass: I-type immediate = 22");
end
else begin
    $display("Fail: I-type immediate is %d", immediate);
end
// Test S-type: 
instruction = {
    7'b0000000,   
    5'd5,         
    5'd3,         
    3'b010,       
    5'b01000,     
    7'b0100011    
};
#1;
if (immediate == 32'd8) begin
    $display("Pass: S-type immediate = 8");
end
else begin
    $display("Fail: S-type immediate is %d", immediate);
end
//B-Type:
instruction = {
    1'b0,          
    6'b000000,     
    5'd2,         
    5'd1,          
    3'b000,        
    4'b1000,       
    1'b0,          
    7'b1100011     
};
#1;
if (immediate == 32'd16) begin
    $display("Pass: B-type immediate = 16");
end
else begin
    $display("Fail: B-type immediate is %d", immediate);
end
//U-Type:
instruction = {
    20'h12345,
    5'd5,
    7'b0110111
};
#1;
if (immediate == 32'h12345000) begin
    $display("Pass: U-type immediate = 0x12345000");
end
else begin
    $display("Fail: U-type immediate is %h", immediate);
end
//J-Type
instruction = {
    1'b0,
    10'b0000001010,
    1'b0,
    8'b00000000,
    5'd1,
    7'b1101111
};
#1;
if (immediate == 32'd20) begin
    $display("Pass: J-type immediate = 20");
end
else begin
    $display("Fail: J-type immediate is %d", immediate);
end
$finish; 
end 
endmodule 
