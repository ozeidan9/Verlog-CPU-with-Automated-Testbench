module mips_cpu_bus_sign_extend16 (
    input logic [15:0] immed_op,
    input logic[4:0] sa_in,
    input logic[4:0] control_alu,
    output logic [31:0] extended32
);
    always_comb begin
      if(control_alu == 11||control_alu==13||control_alu==14) begin //if shift extend by 26 bits
        extended32 = {26'b0, sa_in};
      end
      else begin
        if(immed_op[15]==1) begin
          extended32 = {16'hFFFF, immed_op};
        end
        else if(immed_op[15]==0) begin
          extended32 = { 16'h0000, immed_op};
        end 
      end
    end
endmodule