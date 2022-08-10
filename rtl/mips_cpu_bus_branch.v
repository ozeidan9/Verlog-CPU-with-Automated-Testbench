module mips_cpu_bus_branch(
    input logic[31:0] alu_result,
    input logic zero,
    input logic carry,
    input logic overflow,
    input logic[5:0] opcode,
    input logic[5:0] function_code,
    input logic[31:0] reg_read_data_1,
    input logic[31:0] instr_readdata,
    input logic[31:0] pc,
    output logic link_en,
    output logic[4:0] link_dest,
    output logic branch,
    output logic[31:0] jr_address
);

    logic[32:0] target;
    assign target = {6'b000000, instr_readdata[25:0]};
    logic[31:0] offset;
    assign offset = {16'h0000, instr_readdata[15:0]};
    logic[5:0] branch_code;
    logic[31:0] next_pc;
    logic[27:0] jl_target;
    assign jl_target = {instr_readdata[25:0],2'b00};
    
    assign next_pc=pc+4;
    assign branch_code = instr_readdata[20:16];
    always_comb begin
        //JR
        if((opcode==0)&&(function_code==8))begin
            branch=1;
            jr_address=reg_read_data_1;
            link_en=0;
        end 
        //JALR
        else if((opcode==0)&&(function_code==9))begin
            branch=1;
            jr_address=reg_read_data_1;
            link_en=1;
            link_dest = instr_readdata[15:11];
        end
        //Jump (J)
        else if(opcode==2) begin
          branch = 1;
          jr_address = pc+4+(target<<2);
          link_en=0;
        end
        //JAL
        else if(opcode==3) begin
            if(instr_readdata[25:0]==0)begin
                jr_address=0;
            end
            else begin
                jr_address={next_pc[32:28],jl_target};
            end
            branch=1;
            link_en = 1;
            link_dest = 31;
        end
        //BEQ
        else if (opcode==4)begin
            if(zero)begin
                branch = 1;
                jr_address=pc+(offset*4);
            end
            else begin
                branch=0;
            end
            link_en=0;
        end
        //BNE
        else if (opcode==5)begin
            if(zero)begin
                branch = 0;
            end
            else begin
                branch = 1;
                jr_address=pc+(offset<<2);
            end
            link_en=0;
        end
        //BGTZ
        else if (opcode==7)begin
            if((reg_read_data_1[31]==0)&&(reg_read_data_1!=0)) begin
                branch = 1;
                jr_address=pc+(offset<<2);
            end
            else begin
              branch = 0;
            end
            link_en=0;
        end
        //BLEZ
        else if (opcode==6)begin
            if((reg_read_data_1[31]==1) || (reg_read_data_1==0)) begin
                branch = 1;
                jr_address=pc+(offset<<2);
            end
            else begin
                branch = 0;
            end
            link_en=0;
        end
        //BLTZ
        else if ((opcode==1) && (branch_code==0))begin
            if(reg_read_data_1[31]==1)begin
                branch = 1;
                jr_address=pc+(offset<<2);
            end
            else begin
                branch = 0;
            end
            link_en=0;
        end
        //BGEZ
        else if ((opcode==1) && (branch_code==1))begin
            if(reg_read_data_1[31]==0 || (reg_read_data_1==0)) begin
                branch = 1;
                jr_address=pc+(offset<<2);
            end
            else begin
                branch = 0;
            end
            link_en=0;
        end
        //BGEZAL
        else if ((opcode==1) && (branch_code==17))begin
            if(reg_read_data_1[31]==0 || (reg_read_data_1==0)) begin
                branch = 1;
                jr_address=pc+(offset<<2); //pc+=offset*4
                link_en=1;
                link_dest = 31;
            end
            else begin
                branch = 0;
                link_en = 0;
                link_dest = 0;
            end
        end
        //BLTZAL
        else if ((opcode==1) && (branch_code==16))begin
            if(reg_read_data_1[31]==1)begin
                branch = 1;
                jr_address=pc+(offset<<2); //pc+=offset*4
                link_en = 1;
                link_dest = 31;
            end
            else begin
                branch = 0;
                link_en = 0;
                link_dest = 0;
            end
        end
        else begin
          branch = 0;
          link_en=0;
          link_dest = 0;
        end
    end
    



endmodule