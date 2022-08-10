module mips_cpu_bus (
    /* Standard signals */
    input   logic           clk,
    input   logic           reset,
    output  logic           active,
    output  logic[31:0]     register_v0,

    /* Avalon memory mapped bus controller (master) */
    output  logic[31:0]     address,
    output  logic           write,
    output  logic           read,
    input   logic           waitrequest,
    // An agent asserts waitrequest when unable to respond to a
    // read or write request. Forces the host to wait until the
    // interconnect is ready to proceed with the transfer. 
    output  logic[31:0]     writedata,
    output  logic[3:0]      byteenable,
    // Enables one or more specific byte lanes during transfers on
    // interfaces of width greater than 8 bits. Each bit in byteenable
    // corresponds to a byte in writedata and readdata.
    input   logic[31:0]     readdata
);

    //statemachine logic
    logic fetch;
    logic decode;
    logic exec1;
    logic exec2;
    logic load;
    logic store;
    logic op1change;

    mips_cpu_bus_statemachine tbb(
    .reset(reset),
    .clk(clk),
    .waitrequest(waitrequest),
    .fetch(fetch),
    .decode(decode),
    .exec1(exec1),
    .exec2(exec2),
    .load(load), //inputs
    .store(store),
    .active(active) // inputs
    );

    //pc logic
    logic[31:0] instr_address;
    logic branch;
    logic[31:0] reg_read_data_1;
    logic[31:0] jr_address;
    
    
    

    mips_cpu_bus_pc pc(
        .reset(reset),
        .clk(clk),
        .branch(branch),
        .exec2(exec2),
        .jr_address(jr_address),
        .pc(instr_address),
        .active(active)
    );

    //bus bus logic
    logic[31:0] reg_read_data_2;
    logic[31:0] alu_result;
    logic[2:0] load_type;
    logic[1:0] store_type;
    logic[3:0] instr_byteenable;
    
    mips_cpu_bus_bus bus(
    .fetch(fetch),
    .decode(decode),
    .exec1(exec1),
    .exec2(exec2),
    .clk(clk),
    .load(load),
    .store(store),
    .instr_address(instr_address),
    .reg_read_data_2(reg_read_data_2),
    .alu_result(alu_result),
    .load_type(load_type),
    .store_type(store_type),
    .address(address),
    .write(write),
    .read(read),
    .writedata(writedata),
    .byteenable(byteenable),
    .instr_byteenable(instr_byteenable)
    );

    //instruction register logic
    logic[31:0] instr_readdata;

    mips_cpu_bus_instruction_register intr_reg(
    .clk(clk),
    .exec1(exec1),
    .readdata(readdata),
    .instr_readdata(instr_readdata)
    );

    // control logic
    logic reg_write_en;
    logic reg_dest;
    logic[1:0] ALUOp;   
    logic AluSrc;


    mips_cpu_bus_control_logic cl(
        .instr_readdata(instr_readdata),
        .reg_dest(reg_dest),
        //.branch(branch),
        .ALUOp(ALUOp),
        .AluSrc(AluSrc),
        .reg_write_en(reg_write_en),
        .load(load),
        .store(store),
        .load_type(load_type),
        .store_type(store_type)
    );
    logic[4:0]      reg_write_dest;
    logic[31:0]     reg_write_data;
    logic[4:0]      reg_read_addr_1;
    logic[31:0]     reg_write_data_1;
    logic[4:0]      reg_read_addr_2;
    logic[31:0]     reg_write_data_2;
    
    assign reg_read_addr_1 = instr_readdata[25:21];
    assign reg_read_addr_2 = instr_readdata[20:16];

    always_comb begin
        //mux to decide whether we write rt or rd to register file 
        if(reg_dest) begin
            reg_write_dest = instr_readdata[15:11];
        end
        else begin
            reg_write_dest = instr_readdata[20:16];
        end
        //mux to decide whether we use alu_result or data from  ram to store in register file.
        if(load) begin
            reg_write_data = readdata;
        end
        else begin
            reg_write_data = alu_result;
        end
    end

    logic link_en;
    logic[4:0] link_dest;

    mips_cpu_bus_register_file registerfile(
        .clk(clk),
        .fetch(fetch),
        .reset(reset),
        .reg_write_en(reg_write_en),
        .reg_write_dest(reg_write_dest),
        .reg_write_data(reg_write_data),
        .reg_read_addr_1(reg_read_addr_1),
        .pc(instr_address),
        .link_en(link_en),
        .link_dest(link_dest),
        .reg_read_data_1(reg_read_data_1),
        .reg_read_addr_2(reg_read_addr_2),
        .reg_read_data_2(reg_read_data_2),
        .register_v0(register_v0),
        .load_type(load_type),
        .instr_byteenable(instr_byteenable)
    );

    //alu_control logic
    logic[5:0]      function_code;
    logic[4:0]      control_alu;
    logic[5:0]      opcode;
    assign opcode = instr_readdata[31:26];
    assign function_code = instr_readdata[5:0];
    

    mips_cpu_bus_alu_control aluc(
        .opcode(opcode),
        .function_code(function_code),
        .ALUOp(ALUOp),
        .control_alu(control_alu),
        .op1change(op1change)
    );

    //alu logic
    logic[31:0] extended32;
    logic[15:0] immed_op;
    assign immed_op = instr_readdata[15:0];
    logic zero;
    logic carry;
    logic overflow;
    reg [31:0] HI_reg;
    reg [31:0] LO_reg;
    logic[31:0] HI;
    logic[31:0] LO;

    //MTHI/MTLO register functionality
    always @(posedge exec2) begin
        if((opcode==0)&&(((function_code>23)&&(function_code<28))||(function_code==17))) begin
          HI_reg <= HI;
        end
        if((opcode==0)&&(((function_code>23)&&(function_code<28))||(function_code==19))) begin
          LO_reg <= LO;
        end
    end

    mips_cpu_bus_alu alu(
        .reg_read_data_1(reg_read_data_1),
        .reg_read_data_2(reg_read_data_2),
        .extended32(extended32),
        .AluSrc(AluSrc),
        .control_alu(control_alu),
        .op1change(op1change),
        .zero(zero),
        .overflow(overflow),
        .carry(carry),
        .alu_result(alu_result),
        .HI(HI),
        .LO(LO)
    );

    //branch block

    mips_cpu_bus_branch br(
        .alu_result(alu_result),
        .zero(zero),
        .carry(carry),
        .overflow(overflow),
        .opcode(opcode),
        .function_code(function_code),
        .reg_read_data_1(reg_read_data_1),
        .instr_readdata(instr_readdata),
        .pc(instr_address),
        .link_en(link_en),
        .link_dest(link_dest),
        .branch(branch),
        .jr_address(jr_address)
    );
    
    logic[4:0] sa_in;
    assign sa_in = instr_readdata[10:6];

    mips_cpu_bus_sign_extend16 signextend(
        .immed_op(immed_op),
        .sa_in(sa_in),
        .control_alu(control_alu),
        .extended32(extended32)
    );


endmodule