module mips_cpu_bus_control_logic(
    input logic[31:0] instr_readdata,
    output logic reg_dest,
    //output logic branch,
    //output logic read,
    //output logic write,
    output logic[1:0] ALUOp,
    output logic AluSrc,
    output logic reg_write_en,
    output logic load,
    output logic store,
    output logic[2:0] load_type,
    output logic[1:0] store_type
);
//apply constrants of RAM here --> i.e no write & read
// @ the same time.
    logic branch;
    logic[5:0] opcode;
    logic[5:0] function_code;
    assign opcode = instr_readdata[31:26];
    assign function_code = instr_readdata[5:0];
    always_comb begin
        // addiu opcode control
        if(opcode == 9) begin
            //rs as reg dest
            reg_dest = 0;
            branch = 0;
            ALUOp = 2;
            //use immediate operand
            AluSrc = 1;
            reg_write_en = 1;
        end
        //ANDI
        else if(opcode == 12)begin
            //rt as register destination has reg_dest = 0
            reg_dest = 0;
            branch = 0;
            ALUOp = 2;
            //use immediate operand
            AluSrc = 1;
            reg_write_en = 1;  
        end
        //ORI
        else if(opcode == 13)begin
            //rt as register destination has reg_dest = 0
            reg_dest = 0;
            branch = 0;
            ALUOp = 2;
            //use immediate operand
            AluSrc = 1;
            reg_write_en = 1;  
        end
        //XORI
        else if(opcode == 14)begin
            //rt as register destination has reg_dest = 0
            reg_dest = 0;
            branch = 0;
            ALUOp = 2;
            //use immediate operand
            AluSrc = 1;
            reg_write_en = 1;  
        end
        else if(opcode == 10)begin //SLTI
            reg_dest = 0;
            branch = 0;
            ALUOp = 2;
            AluSrc = 1;
            reg_write_en = 1;     
        end
        else if(opcode == 11)begin //SLTIU
            reg_dest = 0;
            branch = 0;
            //jr = 0;
            load = 0;
            store = 0;
            ALUOp = 2;
            AluSrc = 1;
            reg_write_en = 1;     
        end
        //addu opcode control
        else if(opcode == 0 && function_code == 33) begin
            //rd as reg dest
            reg_dest = 1;
            branch = 0;
            ALUOp = 2; //use rt operand
            AluSrc = 0;
            reg_write_en = 1;
        end
        //SUBU opcode control
        else if(opcode == 0 && function_code == 35) begin 
            ALUOp = 2;
            branch = 0;                                      
            AluSrc = 0;
            reg_dest = 1; //rd as reg dest
            reg_write_en = 1; //write to register file 
        end
        //AND opcode control
        else if(opcode == 0 && function_code == 36) begin 
            ALUOp = 2;
            branch = 0;
            AluSrc = 0;   
            reg_dest = 1; //rd as reg dest
            reg_write_en = 1; //write to register file  
        end
        //OR and NOR opcode control
        else if(opcode == 0 && function_code == 37||function_code==39) begin
            ALUOp = 2;
            branch = 0;
            AluSrc = 0;
            reg_dest = 1; //rd as reg dest
            reg_write_en = 1; //write to register file 
        end
        //XOR opcode control
        else if(opcode == 0 && function_code == 38) begin 
            ALUOp = 2;
            branch = 0;
            AluSrc = 0;
            reg_dest = 1; //rd as reg dest
            reg_write_en = 1; //write to register file 
        end
        //DIVU
        else if(opcode == 0 && function_code == 26) begin
            reg_dest = 0;
            branch = 0;
            ALUOp = 2;
            AluSrc = 0;
            reg_write_en = 0;
        end
        //sll
        else if(opcode == 0 && (function_code == 0)) begin 
            reg_dest = 1;
            branch = 1;
            ALUOp = 2;
            AluSrc = 1;
            reg_write_en = 1;  
        end
        //srl
        else if(opcode == 0 && function_code==2) begin 
            reg_dest = 1;
            branch = 1;
            ALUOp = 2;
            AluSrc = 1;
            reg_write_en = 1;  
        end
        //sra
        else if(opcode == 0 && function_code == 3) begin 
            reg_dest = 1;
            branch = 0;
            ALUOp = 2;
            AluSrc = 1;
            reg_write_en = 1; 
        end
        //srav
        else if(opcode == 0 && function_code == 7)begin
            reg_dest = 1;
            branch = 0;
            ALUOp = 2;
            AluSrc = 0;
            reg_write_en = 1;   
        end
        //SLLV
        else if(opcode == 0 && function_code == 4) begin 
            reg_dest = 1;
            branch = 1;
            ALUOp = 2;
            AluSrc = 0;
            reg_write_en = 1; 
        end
        //SRLV
        else if(opcode == 0 && function_code == 6) begin 
            reg_dest = 1;
            branch = 1;
            ALUOp = 2;
            AluSrc = 0;
            reg_write_en = 1; 
        end
        //SLT
        else if(opcode == 0 && function_code == 42)begin
            reg_dest = 1;
            branch = 0;
            ALUOp = 2;
            AluSrc = 0;
            reg_write_en = 1;     
        end
        //SLTU
        else if(opcode == 0 && function_code == 43)begin
            reg_dest = 1;
            branch = 0;
            ALUOp = 2;
            AluSrc = 0;
            reg_write_en = 1;     
        end
        //DIV
        else if(opcode == 0 && function_code == 26) begin
            reg_dest = 0;
            branch = 0;
            ALUOp = 2;
            AluSrc = 0;
            reg_write_en = 0;
        end
        //DIVU
        else if(opcode == 0 && function_code == 27) begin
            reg_dest = 0;
            branch = 0;
            ALUOp = 2;
            AluSrc = 0;
            reg_write_en = 0;
        end
        //MULT
        else if(opcode == 0 && function_code == 24) begin
            reg_dest = 0;
            branch = 0;
            ALUOp = 2;
            AluSrc = 0;
            reg_write_en = 0;
        end
        //MULTU
        else if(opcode == 0 && function_code == 25) begin
            reg_dest = 0;
            branch = 0;
            ALUOp = 2;
            AluSrc = 0;
            reg_write_en = 0;
        end
        else if(opcode == 0 && function_code == 19)begin //MTLO
            reg_dest = 1;
            branch = 0;
            ALUOp = 2;
            AluSrc = 0;
            reg_write_en = 1;   
        end
        else if(opcode == 0 && function_code == 17)begin //MTHI
            reg_dest = 1;
            branch = 0;
            ALUOp = 2;
            AluSrc = 0;
            reg_write_en = 1;   
        end


        //jump register
        else if(opcode == 0 && function_code == 8) begin
            reg_dest = 0;
            branch = 1;
            ALUOp = 3;
            AluSrc = 0;
            reg_write_en = 0;
            load=1;
        end
        //J
        else if(opcode == 2) begin
            reg_dest = 0;
            branch = 1;
            ALUOp = 3;
            AluSrc = 1;
            reg_write_en = 0;
        end
        //JAL
        else if(opcode == 3) begin
            reg_dest = 1;
            branch = 1; 
        end
        //BEQ
        else if(opcode == 4)begin
            reg_dest = 0;
            branch = 1;
            ALUOp = 2;
            AluSrc = 0;
            reg_write_en = 0;       
        end
        //BNE
        else if(opcode == 5)begin
            reg_dest = 0;
            branch = 1;
            ALUOp = 2;
            AluSrc = 0;
            reg_write_en = 0;       
        end
        else if(opcode == 7)begin //BGTZ
            reg_dest = 0;
            branch = 1;
            ALUOp = 2;
            AluSrc = 0;
            reg_write_en = 0;       
        end
        //BLEZ
        else if(opcode == 6)begin
            reg_dest = 0;
            branch = 1;
            ALUOp = 2;
            AluSrc = 0;
            reg_write_en = 0;       
        end
        //BGEZ, BLTZ, BGEZAL, BLTZAL
        else if(opcode == 1)begin 
            reg_dest = 0;
            branch = 1;
            ALUOp = 2;
            AluSrc = 0;
            reg_write_en = 0;
        end

        //LW opcode control
        else if(opcode == 35) begin
            reg_dest = 0;
            branch = 0;
            ALUOp = 0;
            AluSrc = 1;
            reg_write_en = 1;
        end
        //LB or LBU opcode control
        else if (opcode==32||opcode==36)begin
            reg_dest = 0;
            branch = 0;
            ALUOp = 0;
            AluSrc = 1;
            reg_write_en = 1;
        end
        //LH & LHU
        else if (opcode==33||opcode==37)begin
            reg_dest = 0;
            branch = 0;
            ALUOp = 0;
            AluSrc = 1;
            reg_write_en = 1;
        end
        // LWL
        else if (opcode==34)begin
            reg_dest = 0;
            branch = 0;
            ALUOp = 0;
            AluSrc = 1;
            reg_write_en = 1;
        end
        // LWR
        else if (opcode==38)begin
            reg_dest = 0;
            branch = 0;
            ALUOp = 0;
            AluSrc = 1;
            reg_write_en = 1;
        end
         //LUI
        else if(opcode == 15)begin
            //rt as register destination has reg_dest = 0
            reg_dest = 0;
            branch = 0;
            ALUOp = 2;
            //use immediate operand
            AluSrc = 1;
            reg_write_en = 1;
        end
        //SW opcode controls
        else if(opcode == 43) begin
            reg_dest = 0;
            branch = 0;
            ALUOp = 0;
            AluSrc = 1;
            reg_write_en = 0;
        end
        //SB
        else if(opcode == 40) begin
            reg_dest = 0;
            branch = 0;
            ALUOp = 0;
            AluSrc = 1;
            reg_write_en = 0;
        end
        //SH
        else if(opcode == 41) begin
            reg_dest = 0;
            branch = 0;
            ALUOp = 0;
            AluSrc = 1;
            reg_write_en = 0;
        end

        //this part deals with loading or storing
        if((opcode==35)||(opcode==32) || (opcode==36) || (opcode==33) || (opcode==37) || (opcode==34)|| (opcode==38))begin //LW , LB, LH, LHU, LWL, LWR
            load=1;
        end
        else begin
            load=0;
        end
        if(opcode==43 || opcode==40 || opcode==41)begin //SW, SB, SH 
            store=1;
        end
        else begin
            store=0;
        end

        //this part deals with load_type in register file
        if(opcode==32)begin//LB
            load_type = 1;
        end
        else if(opcode==36)begin//LBU
            load_type=2;
        end
        else if(opcode==33)begin//LH
            load_type=3;
        end
        else if(opcode==37)begin//LHU
            load_type=4;    
        end
        else if(opcode==34)begin//LWL
            load_type=5;
        end
        else if(opcode==38)begin//LWR
            load_type=6;
        end
        else begin
            load_type=0;
        end

        //this part deals with store_type
        if(opcode==40) begin //SB
          store_type = 1;
        end
        else if(opcode==41) begin //SH
          store_type = 2;
        end
        else begin
          store_type = 0;
        end

    end

endmodule

