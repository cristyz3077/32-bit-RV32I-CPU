
module data_memory (
    input logic clk,
    input logic mem_write,
    input logic [2:0] funct3,
    input logic [31:0] address,
    input logic [31:0] write_data,
    output logic [31:0] read_data
);

    logic [7:0] memory [0:1023];

    // Write to memory
    always_ff @(posedge clk) begin
        if (mem_write) begin
            case (funct3)
                3'b000: begin // SB
                    memory[address[9:0]] <= write_data[7:0];
                end

                3'b001: begin // SH
                    memory[address[9:0]] <= write_data[7:0];
                    memory[address[9:0] + 1] <= write_data[15:8];
                end

                3'b010: begin // SW
                    memory[address[9:0]] <= write_data[7:0];
                    memory[address[9:0] + 1] <= write_data[15:8];
                    memory[address[9:0] + 2] <= write_data[23:16];
                    memory[address[9:0] + 3] <= write_data[31:24];
                end

                default: begin
                end
            endcase
        end
    end

    // Read from memory
    always_comb begin
        read_data = 32'd0;

        case (funct3)
            3'b000: read_data =
                {{24{memory[address[9:0]][7]}},
                  memory[address[9:0]]}; // LB

            3'b001: read_data =
                {{16{memory[address[9:0] + 1][7]}},
                  memory[address[9:0] + 1],
                  memory[address[9:0]]}; // LH

            3'b010: read_data =
                {memory[address[9:0] + 3],
                 memory[address[9:0] + 2],
                 memory[address[9:0] + 1],
                 memory[address[9:0]]}; // LW

            3'b100: read_data =
                {24'd0, memory[address[9:0]]}; // LBU

            3'b101: read_data =
                {16'd0,
                 memory[address[9:0] + 1],
                 memory[address[9:0]]}; // LHU

            default: read_data = 32'd0;
        endcase
    end

endmodule
