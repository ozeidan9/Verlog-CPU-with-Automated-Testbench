module mips_cpu_bus_alu(
  input logic[31:0] reg_read_data_1,
  input logic[31:0] reg_read_data_2,
  input logic[31:0] extended32,
  input logic AluSrc,
  input logic[4:0] control_alu,
  input logic op1change,
  output logic zero,
  output logic overflow,
  output logic carry,
  output logic [31:0] alu_result,
  output logic[31:0] HI,
  output logic[31:0] LO
  //output logic[31:0] op1_out,//rem
  //output logic[31:0] op2_out //rem
);

  logic[31:0] op1;
  logic[31:0] op2;
  always_comb begin
    op1 = op1change ? reg_read_data_2 : reg_read_data_1;
    op2 = AluSrc ? extended32 : reg_read_data_2;
  end
  logic signed [31:0] op1_signed;
  assign op1_signed = op1;
  logic signed [31:0] op2_signed;
  assign op2_signed = op2;
  
  logic signed [31:0] signed_sub_temp;
  logic[31:0] sub_temp;
  logic signed [63:0] mult_temp;



  //assign op1_out=op1;//rem
  ///assign op2_out=op2;//rem

  
  always_comb begin
      if(control_alu==2) begin
          // ADDU
          alu_result = op1 + op2;
          overflow=0; /*change this later */
          carry=0; /*change this later */
          if(alu_result==0)begin
            zero = 1;
          end else begin
            zero = 0;
          end   
      end 
      else if(control_alu==6) begin
          //SUBU
          alu_result = op1 - op2;
          overflow=0; /*change this later */
          carry=0; /*change this later */
          if(alu_result==0)begin
            zero = 1;
          end else begin
            zero = 0;
          end   
      end 
      else if(control_alu==0) begin
          //AND 
          alu_result = op1&op2;
          overflow = 0;
          carry = 0;
          if(alu_result==0)begin
            zero = 1;
          end else begin
            zero = 0;
          end
      end 
      else if(control_alu==1) begin
         //OR 
          alu_result = op1|op2;
          overflow = 0;
          carry = 0;
          if(alu_result==0)begin
            zero = 1;
          end else begin
            zero = 0;
          end
      end 
      else if(control_alu==12) begin
        //NOR
          alu_result = ~(op1|op2);
          overflow = 0;
          carry = 0;
          if(alu_result==0)begin
              zero = 1;
          end else begin
              zero = 0;
          end
      end 
      else if(control_alu==3) begin 
        //XOR  
          alu_result = op1^op2;
          overflow = 0;
          carry = 0;
          if(alu_result==0)begin
            zero = 1;
          end
          else begin
            zero = 0;
        end
      end
      //SLL
      else if(control_alu == 11)begin // should be rt<<sa (we changed it to rt so all Gucci )
        alu_result = op1<<op2; //number to be shifted goes into rs, op1
        overflow = 0;
        carry = 0;
        if(alu_result==0)begin
          zero = 1;
        end else begin
          zero = 0;
        end
      end
      //SRL //rt>>sa
      else if(control_alu == 13)begin 
        alu_result = op1>>op2; 
        overflow = 0;
        carry = 0;
        if(alu_result==0)begin
          zero = 1;
        end else begin
          zero = 0;
        end
      end
      //SRA rs>>>sa
      else if(control_alu == 14)begin
        alu_result = op1_signed>>>op2;
        overflow = 0;
        carry = 0;
        if(alu_result==0)begin
          zero = 1;
        end else begin
          zero = 0;
        end
      end 
      //SRAV rt>>>rs
      else if(control_alu == 15)begin
        alu_result = op2_signed>>>op1;
        overflow = 0;
        carry = 0;
        if(alu_result==0)begin
          zero = 1;
        end else begin
          zero = 0;
        end
      end
      //SLLV shift left logical variable
      else if(control_alu == 9)begin 
        alu_result = op2<<op1;
        overflow = 0;
        carry = 0;
        if(alu_result==0)begin
          zero = 1;
        end else begin
          zero = 0;
        end
      end
      //SRLV shift right logical variable
      else if(control_alu == 10)begin
        alu_result = op2>>op1;
        overflow = 0;
        carry = 0;
        if(alu_result==0)begin
          zero = 1;
        end else begin
          zero = 0;
        end 
      end
      //SLT/SLTI
      else if(control_alu == 20)begin
        signed_sub_temp = op1_signed-op2_signed;
        alu_result = signed_sub_temp[31];
      end
      //SLTU/SLTIU
      else if(control_alu == 21)begin
        if(op1<op2) begin
          alu_result = 1;
        end else begin
          alu_result = 0;
        end
      end
      // DIV -> 5
      else if(control_alu == 5) begin
        HI = op1_signed%op2_signed;
        LO = op1_signed/op2_signed;
        overflow = 0;
        carry = 0;
        zero = 0;
      end
      // DIVU -> 4
      else if(control_alu == 4) begin
        HI = op1%op2;
        LO = op1/op2;
        overflow = 0;
        carry = 0;
        zero = 0;
      end
       //MULT
      else if(control_alu == 8) begin
        mult_temp = op1_signed*op2_signed;
        HI = mult_temp[63:32];
        LO = mult_temp[31:0];
        if(mult_temp == 0) begin
          zero = 1;
        end
        else begin
          zero = 0;
        end
        overflow = 0;
        carry = 0;
      end
      //MULTU
      else if(control_alu == 7) begin
        mult_temp = op1*op2;
        HI = mult_temp[63:32];
        LO = mult_temp[31:0];
        if(mult_temp == 0) begin
          zero = 1;
        end
        else begin
          zero = 0;
        end
        overflow = 0;
        carry = 0;
      end
      //MTLO 
      else if(control_alu == 18)begin
        LO = reg_read_data_1;
      end
      //MTHI
      else if(control_alu == 19)begin
        HI = reg_read_data_1;
      end
      //LUI
      else if(control_alu == 31) begin
        alu_result = {op2[15:0], 16'h0000};
      end




  end

endmodule

