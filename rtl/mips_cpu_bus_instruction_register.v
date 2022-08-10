module mips_cpu_bus_instruction_register(
    input logic clk,
    input logic exec1,
    input logic[31:0] readdata,
    output logic[31:0] instr_readdata
);

    always_ff @(posedge exec1) begin
        instr_readdata <= readdata;
    end

endmodule
