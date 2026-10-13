
module instruction_memory #(
    parameter PROGRAM_FILE = "program.hex"
) (
    input logic [31:0] pc,
    output logic [31:0] instruction
);

    logic [31:0] memory [0:255];

    initial begin
        $readmemh(PROGRAM_FILE, memory);
    end

    assign instruction = memory[pc[9:2]];

endmodule
