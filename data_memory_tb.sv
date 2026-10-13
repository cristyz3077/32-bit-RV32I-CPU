
`timescale 1ns/1ps

module data_memory_tb;

    logic clk;
    logic mem_write;
    logic [31:0] address;
    logic [31:0] write_data;
    logic [31:0] read_data;

    data_memory dut (
        .clk(clk),
        .mem_write(mem_write),
        .address(address),
        .write_data(write_data),
        .read_data(read_data)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        mem_write = 0;
        address = 0;
        write_data = 0;

        // Test 1: Write 25 to address 0
        mem_write = 1;
        address = 0;
        write_data = 25;
        @(posedge clk);
        #1;
        if (read_data === 32'd25)
            $display("PASS: Write 25");
        else
            $display("FAIL: Write 25");

        // Test 2: Write 50 to address 4
        @(negedge clk);
        address = 4;
        write_data = 50;
        @(posedge clk);
        #1;
        if (read_data === 32'd50)
            $display("PASS: Write 50");
        else
            $display("FAIL: Write 50");

        // Test 3: Read address 0
        @(negedge clk);
        mem_write = 0;
        address = 0;
        #1;
        if (read_data === 32'd25)
            $display("PASS: Read 25");
        else
            $display("FAIL: Read 25");

        // Test 4: Read address 4
        address = 4;
        #1;
        if (read_data === 32'd50)
            $display("PASS: Read 50");
        else
            $display("FAIL: Read 50");

        $finish;
    end

endmodule
