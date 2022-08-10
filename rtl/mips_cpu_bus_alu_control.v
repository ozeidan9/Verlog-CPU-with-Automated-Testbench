
module mips_cpu_bus_alu_control(
    input logic[5:0] opcode,
    input logic[5:0] function_code,
    input logic[1:0] ALUOp,
    output logic[4:0] control_alu,
    output logic op1change //changed to 5 bits wide (FOR NOW)
);  //control values used (0,1,2,3,4,5,6)
    always_comb begin
        op1change = (((function_code==0)|(function_code==3)|(function_code==2)) && (opcode==0));//this lines tells us if it is a shift op or not (affects op1 in alu)
        if(ALUOp==0) begin
            control_alu = 2;
        end
        else if(ALUOp==1) begin
            control_alu = 6;
        end
        else if(ALUOp==2) begin
            if(opcode == 0) begin //R-TYPE
                if(function_code==33) begin //ADDU
                    control_alu = 2;
                end
                else if(function_code==35) begin //SUBU
                    control_alu = 6;
                end
                else if(function_code==36) begin  //AND
                    control_alu = 0;
                end
                else if(function_code == 37) begin //OR
                    control_alu = 1;
                end
                else if(function_code == 38) begin //XOR
                    control_alu = 3; //DECIDED MYSELF (try find table)
                end
                else if(function_code == 26) begin  //DIV
                    control_alu = 5;
                end
                else if(function_code == 27) begin //DIVU
                    control_alu = 4;  
                end
                else if(function_code == 24) begin //mult
                    control_alu = 8;
                end
                else if(function_code == 25) begin //multu
                    control_alu = 7;
                end
                else if(function_code == 0)begin //sll
                    control_alu = 11;  
                end
                else if(function_code == 2)begin //srl
                    control_alu = 13;  
                end
                else if(function_code == 3)begin //sra
                    control_alu = 14; 
                end
                else if(function_code == 7)begin //srav
                    control_alu = 15;
                end
                else if(function_code == 4)begin //SLLV
                    control_alu = 9;
                end
                else if(function_code == 6)begin //SRLV
                    control_alu = 10;
                end
                else if(function_code == 42)begin //SLT
                    control_alu = 20; //setting the overflow from subtraction as value in register
                end
                else if(function_code == 43)begin //SLTU
                  control_alu = 21;
                end
                else if(function_code == 19)begin//MTLO
                    control_alu = 18;  
                end
                else if(function_code == 17)begin//MTHI
                    control_alu = 19; 
                end
            end
            else if(opcode == 9) begin //ADDIU
                control_alu = 2;    
            end
            else if(opcode == 12)begin //ANDI
                control_alu = 0;
            end
            else if(opcode == 13)begin //ORI
                control_alu = 1;
            end
            else if(opcode == 14)begin //XORI
                control_alu = 3;
            end
            else if(opcode == 10)begin //SLTI
              control_alu = 20;
            end
            else if(opcode == 11)begin //SLTIU
              control_alu = 21;       
            end
            else if(opcode == 4)begin //BEQ
                control_alu = 6;        //sub
            end
            else if(opcode == 5)begin //BNE
                control_alu = 6; //sub  
            end
            else if(opcode == 15) begin    //LUI
               control_alu = 31; // decided ourself
            end
            //no ALU control logic for BGTZ. Done in branch
            //no ALU control logic for BLEZ. Done in branch
            //no ALU control logic for BLTZ. Done in branch
        end
    end
endmodule
