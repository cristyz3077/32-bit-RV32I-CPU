
module alu_control (
    input logic [6:0] opcode,
    input logic [2:0] funct3,
    input logic [6:0] funct7,
    output logic [3:0] alu_op
);

always_comb begin
    alu_op = 4'b0000;

    case (opcode)

        // R-type
        7'b0110011: begin
            case (funct3)
                3'b000: begin
                    if (funct7 == 7'b0100000)
                        alu_op = 4'b0001; // SUB
                    else
                        alu_op = 4'b0000; // ADD
                end
                3'b001: alu_op = 4'b0010; // SLL
                3'b010: alu_op = 4'b0011; // SLT
                3'b011: alu_op = 4'b0100; // SLTU
                3'b100: alu_op = 4'b0101; // XOR
                3'b101: begin
                    if (funct7 == 7'b0100000)
                        alu_op = 4'b0111; // SRA
                    else
                        alu_op = 4'b0110; // SRL
                end
                3'b110: alu_op = 4'b1000; // OR
                3'b111: alu_op = 4'b1001; // AND
                default: alu_op = 4'b0000;
            endcase
        end

        // I-type ALU
        7'b0010011: begin
            case (funct3)
                3'b000: alu_op = 4'b0000; // ADDI
                3'b010: alu_op = 4'b0011; // SLTI
                3'b011: alu_op = 4'b0100; // SLTIU
                3'b100: alu_op = 4'b0101; // XORI
                3'b110: alu_op = 4'b1000; // ORI
                3'b111: alu_op = 4'b1001; // ANDI
                3'b001: alu_op = 4'b0010; // SLLI
                3'b101: begin
                    if (funct7 == 7'b0100000)
                        alu_op = 4'b0111; // SRAI
                    else
                        alu_op = 4'b0110; // SRLI
                end
                default: alu_op = 4'b0000;
            endcase
        end

        // Load, Store, JALR, AUIPC
        7'b0000011,
        7'b0100011,
        7'b1100111,
        7'b0010111: alu_op = 4'b0000;

        // Branch: comparison using subtraction
        7'b1100011: alu_op = 4'b0001;

        default: alu_op = 4'b0000;

    endcase
end

endmodule
