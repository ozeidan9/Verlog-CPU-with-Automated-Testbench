module mips_cpu_bus_bus(
    input logic fetch,
    input logic decode,
    input logic exec1,
    input logic exec2,
    input logic clk,
    input logic load,
    input logic store,
    input logic[31:0] instr_address,
    input logic[31:0] reg_read_data_2,
    input logic[31:0] alu_result,
    input logic[2:0] load_type,
    input logic[1:0] store_type,
    output logic[31:0] address,
    output logic write,
    output logic read,
    output logic[31:0] writedata,
    output logic[3:0] byteenable,
    output logic[3:0] instr_byteenable
);

    logic[7:0] least_8;
    always_comb begin
        //LB
        //we get ram address (the 8) by just replacing final 2 bits of address with 0
        //if final two bits are 00: byte enable is 0001
        //if final two bits are 01: byte enable is 0010
        //if final two bits are 10: byte enable is 0100
        //if final two bits are 11: byte enable is 1000

        least_8 = reg_read_data_2[7:0];

        if(load_type==1||load_type==2||store_type==1)begin//LB or LBU
            if(alu_result[1:0]==0)begin
                //byte 0
                instr_byteenable=1;
            end else if(alu_result[1:0]==1)begin
                //byte 1
                instr_byteenable=2;
            end else if(alu_result[1:0]==2)begin
                //byte 2
                instr_byteenable=4;
            end else begin
                //byte 3
                instr_byteenable=8;
            end
        end
        //LH or LHU
        else if(load_type==3||load_type==4||store_type==2)begin
            //mem address will still be just alu out but replace last 2 bits with 0
            //if last two bits are 00:
            if(alu_result[1:0]==0 || alu_result[1:0]==1)begin
                //first halfword
                instr_byteenable=3;
            end else if(alu_result[1:0]==2 || alu_result[1:0]==3)begin
                //second halfword
                instr_byteenable=12;
            end
        end
        //LWL
        else if(load_type==5)begin
            //last two bits is 0: byte enable is 1111
            //last two bits is 1: byte enable is 1110
            //last two bits is 2: byte enable is 1100
            //last two bits is 3: byte enable is 1000
            if(alu_result[1:0]==0)begin
                instr_byteenable=4'b1111;
            end
            else if(alu_result[1:0]==1)begin
                instr_byteenable=4'b0111;
            end
            else if(alu_result[1:0]==2)begin
                instr_byteenable=4'b0011;    
            end
            else if(alu_result[1:0]==3)begin
                instr_byteenable=4'b0001;
            end
        end
        //LWR
        else if(load_type==6)begin
            if(alu_result[1:0]==0)begin
                instr_byteenable=4'b0000;
            end
            else if(alu_result[1:0]==1)begin
                instr_byteenable=4'b1000;
            end
            else if(alu_result[1:0]==2)begin
                instr_byteenable=4'b1100;    
            end
            else if(alu_result[1:0]==3)begin
                instr_byteenable=4'b1110;
            end
        end
        else begin
            // normal load
            instr_byteenable = 15;
        end

    end 

    always_comb begin//used to be always_comb
        //fetch
        if(fetch)begin
            // obtaining multiple of 4 address
            address = instr_address;
            write = 0;
            read = 1;
            byteenable = 4'b1111;
            //no assign of writedata
        end
        //load instruction
        else if(exec1&&load)begin
            if(load_type==6) begin
                address = {alu_result[31:2],2'b00}+4; 
            end
            else begin
                // obtaining multiple of 4 address
                address = {alu_result[31:2],2'b00};
            end    
            write = 0;
            read=1;
            byteenable=instr_byteenable;
            //no assign of writedata
        end
        //store instruction
        else if(exec1&&store)begin
            // obtaining multiple of 4 address
            
            address = {alu_result[31:2],2'b00};
            read=0;
            write=1;
            byteenable=instr_byteenable;
            if(store_type==1)begin
                if(instr_byteenable==1)begin
                    writedata={24'h000000, reg_read_data_2[7:0]};
                end
                else if(instr_byteenable==2)begin
                    writedata={16'h0000, reg_read_data_2[7:0], 8'h00};
                end
                else if(instr_byteenable==4)begin
                    writedata={8'h00, reg_read_data_2[7:0], 16'h0000};
                end
                else if(instr_byteenable==8)begin
                    writedata={reg_read_data_2[7:0],24'h000000};
                end
            end
            //SHU
            else if(store_type==2)begin
                if(alu_result[1:0]==0 || alu_result[1:0]==1)begin
                    writedata={16'd0,reg_read_data_2[15:0]};
                end
                else if(alu_result[1:0]==2 || alu_result[1:0]==3)begin
                    writedata={reg_read_data_2[15:0],16'd0};
                end
            end
            //normal store word
            else begin
                writedata = reg_read_data_2;
            end
        end
        else begin
            write = 0;
            read = 0;
        end 
    end




endmodule