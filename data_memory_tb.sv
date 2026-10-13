
`timescale 1ns/1ps

module data_memory_tb;

    logic clk;
    logic mem_write;
    logic [2:0] funct3;
    logic [31:0] address;
    logic [31:0] write_data;
    logic [31:0] read_data;

    integer tests_passed;

    data_memory dut (
        .clk(clk),
        .mem_write(mem_write),
        .funct3(funct3),
        .address(address),
        .write_data(write_data),
        .read_data(read_data)
    );

    always #5 clk = ~clk;

    task check_result;
        input [31:0] expected;
        begin
            #1;
            if (read_data === expected) begin
                $display("PASS: Test %0d", tests_passed + 1);
                tests_passed = tests_passed + 1;
            end else begin
                $display("FAIL: Expected %h, Got %h",
                         expected, read_data);
            end
        end
    endtask

    initial begin
        clk = 0;
        mem_write = 0;
        funct3 = 0;
        address = 0;
        write_data = 0;
        tests_passed = 0;

        // SW: Store a 32-bit word
        @(negedge clk);
        mem_write = 1;
        funct3 = 3'b010;
        address = 0;
        write_data = 32'h12345678;

        @(posedge clk);
        #1;
        mem_write = 0;
        funct3 = 3'b010;
        check_result(32'h12345678);

        // LB: Load signed byte
        funct3 = 3'b000;
        check_result(32'h00000078);

        // LBU: Load unsigned byte
        funct3 = 3'b100;
        check_result(32'h00000078);

        // LH: Load signed halfword
        funct3 = 3'b001;
        check_result(32'h00005678);

        // LHU: Load unsigned halfword
        funct3 = 3'b101;
        check_result(32'h00005678);

        // SB: Store a byte
        @(negedge clk);
        mem_write = 1;
        funct3 = 3'b000;
        address = 4;
        write_data = 32'h000000FF;

        @(posedge clk);
        #1;
        mem_write = 0;
        funct3 = 3'b000;
        check_result(32'hFFFFFFFF);

        // LBU: Zero extension
        funct3 = 3'b100;
        check_result(32'h000000FF);

        // SH: Store a halfword
        @(negedge clk);
        mem_write = 1;
        funct3 = 3'b001;
        address = 8;
        write_data = 32'h00008001;

        @(posedge clk);
        #1;
        mem_write = 0;
        funct3 = 3'b001;
        check_result(32'hFFFF8001);

        // LHU: Zero extension
        funct3 = 3'b101;
        check_result(32'h00008001);

        $display("Tests passed: %0d/9", tests_passed);
        $finish;
    end

endmodule
