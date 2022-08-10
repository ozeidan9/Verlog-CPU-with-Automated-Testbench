module mips_cpu_bus_memory(
    input logic clk,
    input logic[31:0] address,
    input logic write,
    input logic read,
    output logic waitrequest,
    input logic[31:0] writedata,
    input logic[3:0] byteenable,
    output logic[31:0] readdata
);

    // logic[31:0] test;
    // assign test = {memory[103],memory[102],memory[101],memory[100]};

    logic[31:0] address_mapped;
    always_comb begin
        if(address==0)begin
            address_mapped=4092;//where the halt goes to (address 0)
        end
        else begin
            address_mapped=address-3217031168;
        end
    end 

    parameter INSTR_INIT_FILE = "";
    reg [7:0] memory[4095:0];

    reg [7:0] readfile [0:100]; //tmp memory used to store values from binary file

    initial begin
        integer i;
        /* Initialise to zero by default */
        for (i=0; i<4096; i++) begin
            memory[i]=0;
        end

        // //ADDIU $2, $3,100 $2 = 100
        // memory[4]=8'b01100100; 
        // memory[5]=8'b01100010;   //rs before rt(destination)
        // memory[6]=8'b01100010; 
        // memory[7]=8'b00100100; 

        // // LW $3, $0(1) $3 = 2  ($2 = 5)
        // memory[8]=8'b10001100;
        // memory[9]=8'b00000011;
        // memory[10]=8'b00000000;
        // memory[11]=8'b00000100;

        // //ADDIU $2, $3,100 $2 = 102
        // memory[12]=8'b00100100;
        // memory[13]=8'b01100010;   //rs before rt(destination)
        // memory[14]=8'b00000000;
        // memory[15]=8'b01100100;

        // //ADDIU $4, $3,100 $4 = 102 $2 = 102
        // memory[22]=8'b00100100;
        // memory[23]=8'b01100100;
        // memory[24]=8'b00000000;
        // memory[25]=8'b01100100;
        // //ADDIU $2, $3,100 $2 = 102
        // memory[10]=8'b00100100;
        // memory[11]=8'b01100010;
        // memory[12]=8'b00000000;
        // memory[13]=8'b01100100;

        // // JR $4
        // memory[26]=8'b00000000;
        // memory[27]=8'b10000000;
        // memory[28]=8'b00000000;
        // memory[29]=8'b00001000;

        // // LW $2, $0(0) $2 = 4 - works
        // memory[30]=8'b10001100;
        // memory[31]=8'b00000010;
        // memory[32]=8'b00000000;
        // memory[33]=8'b00000000;


        // // ADDU $2, $2, $3  $2 = 6
        // memory[102]=8'b00000000;
        // memory[103]=8'b01000011;
        // memory[104]=8'b00010000;
        // memory[105]=8'b00100001;


        // //Store reg 2 in RAM[0]
        // memory[106]=8'b10101100;
        // memory[107]=8'b00000010;
        // memory[108]=8'b00000000;
        // memory[109]=8'b00000000;


        // //SUBU $2, $2, $3  $2 = 4
        // memory[10]=8'b00000000;
        // memory[11]=8'b01000011;
        // memory[12]=8'b00010000;
        // memory[13]=8'b00100011;

        // //AND $2, $3,   
        // memory[10]=8'b00000000;
        // memory[11]=8'b01000011;
        // memory[12]=8'b00010000;
        // memory[13]=8'b00100100;
        
        // //SLR $2, shift $3 2times $2 = 2 
        // memory[10]=8'b00000000;
        // memory[11]=8'b00000011;
        // memory[12]=8'b00010000;
        // memory[13]=8'b10000010;

        //SLRA $2, arithmetically shift $3 2times $2 = 2 
        // memory[10]=8'b00000000;
        // memory[11]=8'b00000011;
        // memory[12]=8'b00010000;
        // memory[13]=8'b10000011;
        
        //SLRAV $2 = $3>>$2
        // memory[10]=8'b00000000;
        // memory[11]=8'b01000011;
        // memory[12]=8'b00010000;
        // memory[13]=8'b00000111;
        
        //SLLV $2=$3<<$2
        // memory[10]=8'b00000000;
        // memory[11]=8'b01000011;
        // memory[12]=8'b00010000;
        // memory[13]=8'b00000100;

        //SRLV $2=$3>>$2
        // memory[10]=8'b00000000;
        // memory[11]=8'b01000011;
        // memory[12]=8'b00010000;
        // memory[13]=8'b00000110;

        //ANDI $2=$3&(01010101) 
        // memory[10]=8'b00110000;
        // memory[11]=8'b01100010;
        // memory[12]=8'b00000000;
        // memory[13]=8'b01010101;

        //ORI $2=$3|(01010101) 
        // memory[10]=8'b00110100;
        // memory[11]=8'b01100010;
        // memory[12]=8'b00000000;
        // memory[13]=8'b11111111;

        //XORI $2=$3xor(01010101) 
        // memory[10]=8'b00111000;
        // memory[11]=8'b01100010;
        // memory[12]=8'b00000000;
        // memory[13]=8'b01010101;

        //SLT $2=1 if $2<$3 or else $2 = 0;
        // memory[10]=8'b00000000;
        // memory[11]=8'b01000011;
        // memory[12]=8'b00010000;
        // memory[13]=8'b00101010;

        // //SLTU $2=1 if $2<$3 or else $2 = 0;
        // // memory[10]=8'b00000000;
        // // memory[11]=8'b01000011;
        // // memory[12]=8'b00010000;
        // // memory[13]=8'b00101011;

        // //SLTI $2=1 if $3<immediate or else $2 = 0
        // memory[10]=8'b00101000;
        // memory[11]=8'b01100010;
        // memory[12]=8'b10000000;
        // memory[13]=8'b00101011;

        //SLTIU $2=1 if $3<immediate or else $2 = 0
        // memory[10]=8'b00101100;
        // memory[11]=8'b01100010;
        // memory[12]=8'b10000000;
        // memory[13]=8'b00101011;

        // //JR to $3
        // memory[10]=8'b00000000;
        // memory[11]=8'b01100000;
        // memory[12]=8'b00000000;
        // memory[13]=8'b00001000;

        // //Jump to immediate
        // memory[10]=8'b00001000;
        // memory[11]=8'b00000000;
        // memory[12]=8'b00000000;
        // memory[13]=8'd2;

        // //BEQ
        // memory[10]=8'b00010000;
        // memory[11]=8'b01000011;
        // memory[12]=8'b00000000;
        // memory[13]=8'd50;

        // //BNE
        // memory[10]=8'b00010100;
        // memory[11]=8'b01000011;
        // memory[12]=8'b00000000;
        // memory[13]=8'd50;

        // //BGTZ
        // memory[10]=8'b00011100;
        // memory[11]=8'b01000000;
        // memory[12]=8'b00000000;
        // memory[13]=8'd51;

    

        // // BLEZ
        // memory[10]=8'b00011000;
        // memory[11]=8'b01000000;
        // memory[12]=8'b00000000;
        // memory[13]=8'd52;

        // // BLTZ
        // memory[10]=8'b00000100;
        // memory[11]=8'b01000000;
        // memory[12]=8'b00000000;
        // memory[13]=8'd50;

        // // BGEZ
        // memory[10]=8'b00000100;
        // memory[11]=8'b01000001;
        // memory[12]=8'b00000000;
        // memory[13]=8'd51;

        // //JAL
        // memory[10]=8'b00001100;
        // memory[11]=8'b00000000;
        // memory[12]=8'b00000000;
        // memory[13]=8'd20;

        //JALR
//         memory[10]=8'b00000000;
//         memory[11]=8'b01100000;
//         memory[12]=8'b00010000;
//         memory[13]=8'b00001001;


        // // // LW $2, $0(0) $2 = 4
        // memory[7]=8'b10001100;
        // memory[6]=8'b00000010;
        // memory[5]=8'b00000000;
        // memory[4]=8'b00000000;

//         // //ADDIU $2, $2,6 $2 = 10
//         memory[26]=8'b00100100;
//         memory[27]=8'b01000010;
//         memory[28]=8'b00000000;
//         memory[29]=8'b00000110;
        
       
       $readmemb(INSTR_INIT_FILE, readfile);


    end

    initial begin
        integer j;

       for(j=0;j<4096;j=j+4) begin            
            memory[j+3] =  readfile[j];
            memory[j+2] =  readfile[j+1];
            memory[j+1] =  readfile[j+2];
            memory[j]   =  readfile[j+3];
        end
    end

    logic[31:0] instr_0;
    assign instr_0 = {memory[7],memory[6],memory[5],memory[4]};
        

        

  //Taking this information, and the early quote about byte-enables, we can say that 
  //byteenable[x] controls whether writedata[x*8+7:x*8] will be written to address+x. 
  //In a read transaction byteenable[x] determines whether address+x is read or not.
    always @(posedge(read || write)) begin
        //
        waitrequest<=1;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        // @(posedge clk);
        // @(posedge clk);
        waitrequest<=0;
    end

    
    always @(posedge clk) begin
        if (write) begin
            if(byteenable[3])begin
                memory[address_mapped+3] <= writedata[31:24];
            end
            if (byteenable[2])begin
                memory[address_mapped+2] <= writedata[23:16];
            end
            if (byteenable[1])begin
                memory[address_mapped+1] <= writedata[15:8];
            end
            if (byteenable[0])begin
                memory[address_mapped+0] <= writedata[7:0];
            end 
        end
        else if (read) begin
            readdata[31:24] <= (byteenable[3]) ? memory[address_mapped+3] : 0;
            readdata[23:16] <= (byteenable[2]) ? memory[address_mapped+2] : 0;
            readdata[15:8] <= (byteenable[1]) ? memory[address_mapped+1] : 0;
            readdata[7:0] <= (byteenable[0]) ? memory[address_mapped+0] : 0;
        end
    end
endmodule

//store in byte 9
//mem 8: byte enable would 0010
//take two end bits from addres:
