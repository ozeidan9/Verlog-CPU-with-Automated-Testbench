module mips_cpu_bus_tb();

logic clk;
logic[31:0] address;
logic write;
logic read;
logic waitrequest;
logic[31:0] writedata;
logic[3:0] byteenable;
logic[31:0] readdata;
logic[31:0] register_v0;
logic active;
logic reset;

integer f; 

parameter INSTR_INIT_FILE = "";


mips_cpu_bus cpu(
    .clk(clk),
    .reset(reset),
    .active(active),
    .register_v0(register_v0),
    .address(address),
    .write(write),
    .read(read),
    .waitrequest(waitrequest),
    .writedata(writedata),
    .byteenable(byteenable),
    .readdata(readdata)
);


mips_cpu_bus_memory #(INSTR_INIT_FILE) dt(
    .clk(clk),
    .address(address),
    .write(write),
    .read(read),
    .waitrequest(waitrequest),
    .writedata(writedata),
    .byteenable(byteenable),
    .readdata(readdata)
);


initial begin
    f = $fopen("test/cpu_output/tb_output.txt","w");
end


initial begin
    clk=0;
    reset=0;
    #10;
    clk=1;
    #10;
    reset=1;
    clk=0;
    #10;
    clk=1;
    #10;
    reset=0;
    clk=0;
    #10
    clk=1;
    #10
    clk=0;


        
    repeat (100) begin
        #5;
        clk = !clk;
        #5;
        clk = !clk;


    end
    
    // $display("register v0 is: %h", register_v0);
    $fwrite(f, "%0d", register_v0); //new - the zero in between removes leading whitespaces 

    $fclose(f);
    

end

    

endmodule




////// LB address 9
//we wanna make ram address = 8
//9%8 is 1 
//ra
//if mod is 0 - bytenable[0]
//mod n -> byteenable[n]
//we want byte enable to be 0010
// 
//LB
//we get ram address (the 8) by just replacing final 2 bits of address with 0
//if final two bits are 00: byte enable is 0001
//if final two bits are 01: byte enable is 0010
//if final two bits are 10: byte enable is 0100
//if final two bits are 11: byte enable is 1000