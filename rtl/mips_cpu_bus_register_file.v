module mips_cpu_bus_register_file (
    input logic clk,
    input logic fetch,
    input logic reset,
    // write port
    input  logic        reg_write_en,
    input  logic[4:0]   reg_write_dest,
    input  logic[31:0]  reg_write_data,
    // read port 1
    input  logic[4:0]   reg_read_addr_1,
    input logic[31:0] pc,
    input logic link_en,
    input logic[4:0] link_dest,
    output logic[31:0]  reg_read_data_1,
    // read port 2
    input  logic[4:0]   reg_read_addr_2,
    output logic[31:0]  reg_read_data_2,
    output logic[31:0] register_v0,
    input logic[2:0] load_type,
    input logic[3:0] instr_byteenable
    //if = 0: no change, we just load the whole of reg_write_data
    //if = 1: LB : take the 8 MSB OF reg_write_data and load into 8LSB of register
    //if = 2: LBU : take the MSB OF reg_write_data and load into 8LSB of register
    //if = 3: LH : take
    //if = 4: LHU : 
    //if = 5: LWL :
    //if = 6: LWR :  
);
    
    reg [31:0] reg_array [31:0];
    
    integer i;
    // write port
    // reg [4:0] i;
    always_comb begin
        if(reset) begin
            for(i=0; i<32; i=i+1) begin
                reg_array[i] = 32'd0;
            end
        end
        reg_array[0] = 0;  //DONT change. Register 0 is always 0.
    end
    
    always @(posedge fetch) begin
        if (link_en)begin
            reg_array[link_dest]<=pc+4;
        end
        else if (reg_write_en==1 && reg_write_dest != 0) begin
            //LB registers (inluding for each byte location)
            if(load_type==1)begin
                //byte 0
                if(instr_byteenable==1)begin
                    if(reg_write_data[7]==1)begin
                        reg_array[reg_write_dest]<={24'hffffff, reg_write_data[7:0]};
                    end
                    else begin
                      reg_array[reg_write_dest]<={24'h000000, reg_write_data[7:0]};
                    end     
                end
                //byte 1
                else if(instr_byteenable==2)begin
                    if(reg_write_data[15]==1)begin
                        reg_array[reg_write_dest]<={24'hffffff, reg_write_data[15:8]};
                    end
                    else begin
                      reg_array[reg_write_dest]<={24'h000000, reg_write_data[15:8]};
                    end     
                end
                //byte 2
                else if(instr_byteenable==4)begin
                    if(reg_write_data[23]==1)begin
                        reg_array[reg_write_dest]<={24'hffffff, reg_write_data[23:16]};
                    end
                    else begin
                      reg_array[reg_write_dest]<={24'h000000, reg_write_data[23:16]};
                    end     
                end
                //byte 3
                else if(instr_byteenable==8)begin
                    if(reg_write_data[31]==1)begin
                        reg_array[reg_write_dest]<={24'hffffff, reg_write_data[31:24]};
                    end
                    else begin
                      reg_array[reg_write_dest]<={24'h000000, reg_write_data[31:24]};
                    end     
                end
            end
            //LBU register
            else if(load_type==2)begin
                //byte 0
                if(instr_byteenable==1)begin
                    reg_array[reg_write_dest]<={24'h000000, reg_write_data[7:0]};
                end
                //byte 1
                else if(instr_byteenable==2)begin
                    reg_array[reg_write_dest]<={24'h000000, reg_write_data[15:8]};
                end
                //byte 2
                else if(instr_byteenable==4)begin
                    reg_array[reg_write_dest]<={24'h000000, reg_write_data[23:16]};
                end
                //byte 3
                else if(instr_byteenable==8)begin
                    reg_array[reg_write_dest]<={24'h000000, reg_write_data[31:24]};
                end
            end
            //LH
            else if(load_type==3)begin
                //first halfword
                if(instr_byteenable==3)begin
                    if(reg_write_data[15]==1)begin
                        reg_array[reg_write_dest]<={16'hffff,reg_write_data[15:0]};
                    end
                    else begin
                        reg_array[reg_write_dest]<={16'h0000,reg_write_data[15:0]};
                    end
                end
                //second halfword
                if(instr_byteenable==12)begin
                    if(reg_write_data[31]==1)begin
                        reg_array[reg_write_dest]<={16'hffff,reg_write_data[31:16]};
                    end
                    else begin
                        reg_array[reg_write_dest]<={16'h0000,reg_write_data[31:16]};
                    end
                end
            end
            //LHU
            else if(load_type==4)begin
                //first halfword
                if(instr_byteenable==3)begin
                    reg_array[reg_write_dest]<={16'h0000,reg_write_data[15:0]};
                end
                //second halfword
                if(instr_byteenable==12)begin
                    reg_array[reg_write_dest]<={16'h0000,reg_write_data[31:16]};
                end   
            end
            
            //LWL
            else if(load_type==5)begin
                //offset 0
                if(instr_byteenable==4'b1111)begin
                    reg_array[reg_write_dest]<=reg_write_data;                    
                end
                //offset 1
                else if(instr_byteenable==4'b0111)begin
                    reg_array[reg_write_dest]<={reg_write_data[23:0],reg_array[reg_write_dest][7:0]};               
                end
                //offset 2
                else if(instr_byteenable==4'b0011)begin
                    reg_array[reg_write_dest]<={reg_write_data[15:0],reg_array[reg_write_dest][15:0]};               
                end
                //offset 3
                else if(instr_byteenable==4'b0001)begin
                    reg_array[reg_write_dest]<={reg_write_data[7:0],reg_array[reg_write_dest][23:0]};               
                end
            end
            //LWR
            else if(load_type==6)begin
                if(instr_byteenable==4'b1000)begin
                    reg_array[reg_write_dest]<={reg_array[reg_write_dest][31:8],reg_write_data[31:24]};               
                end
                else if(instr_byteenable==4'b1100)begin
                    reg_array[reg_write_dest]<={reg_array[reg_write_dest][31:16],reg_write_data[31:16]};           
                end
                else if(instr_byteenable==4'b1110)begin
                    reg_array[reg_write_dest]<={reg_array[reg_write_dest][31:24],reg_write_data[31:8]};               
                end        
            end
            //general register usage
            else begin
                reg_array[reg_write_dest] <= reg_write_data;
            end
            
        end
    end
    logic[31:0] ra;
    assign ra = reg_array[31];
    logic[31:0] s1;
    assign s1=reg_array[17];
    logic[31:0] s0;
    assign s0=reg_array[16];
    assign reg_read_data_1 = reg_array[reg_read_addr_1];
    assign reg_read_data_2 = reg_array[reg_read_addr_2];
    assign register_v0=reg_array[2];
    //assign reg_write_dest_check=reg_write_dest;
    //assign reg_write_data_check = reg_write_data;
endmodule