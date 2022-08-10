module mips_cpu_bus_pc (
    input logic reset,
    input logic clk,
    input logic branch,
    input logic exec2,
    input logic[31:0] jr_address,
    output logic[31:0] pc,
    output logic active
);

    logic[31:0] pc_increment;
    assign pc_increment = pc + 4;

    always_ff @(posedge clk) begin
        if(reset) begin
            pc <= 32'hBFC00000; //address 0 is the "halt code" - readme file
            active <= 1;
        end
        else if(pc==0)begin
            active<=0;
        end
        
    end
    logic jmp_store;
    logic[31:0]jr_address_store;
    //working out if we have to jump next instruction
    always_ff @(posedge exec2)begin
        if(branch)begin
            jmp_store<=1;
            jr_address_store<=jr_address;
        end
        else if(jmp_store)begin
            jmp_store<=0;
        end
    end
    
    always_ff @(posedge exec2)begin
        if(jmp_store)begin
            pc<=jr_address_store;    
        end
        else begin
            pc<=pc_increment;
        end
        if(jr_address_store==0)begin
            active<=0;
        end
    end


    // always_ff @(posedge exec2) begin
    //     if (jr) begin
    //         if (jr_address == 0) begin
                
    //             pc <= jr_address;
    //             active <= 0;  
    //         end
    //         else begin
    //             pc <= jr_address;
    //             active <= 1;
    //         end
    //     end
    //     else begin
    //         pc <= pc_increment;
    //         active <= 1;
    //     end 
    // end
    
endmodule