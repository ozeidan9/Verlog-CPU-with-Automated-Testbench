module mips_cpu_bus_statemachine(
    input logic reset,
    input logic clk,
    input logic waitrequest,
    output logic fetch,
    output logic decode,
    output logic exec1,
    output logic exec2,
    input logic load,
    input logic store,
    input logic active
);
    logic exec1wait;
    assign exec1wait = load||store;
    initial begin
      fetch=1;
      decode=0;
      exec2=0;
      exec1=0;
    end


    always_ff @(posedge clk)begin
        if(active)begin
            if(reset==1)begin
                exec1<=0;
                exec2<=0;
                decode<=0;
                fetch<=1;
            end

            else begin
                if(fetch)begin
                    if(~waitrequest)begin
                        fetch<=0;
                        decode<=1;
                        exec1<=0;
                        exec2<=0;
                    end 
                end
                //decode
                else if(decode)begin
                    fetch<=0;
                    decode<=0;
                    exec1<=1;
                    exec2<=0;
                end
            //exec1
                else if(exec1)begin
                    if((exec1wait&&(~waitrequest))||~exec1wait) begin
                        fetch<=0;
                        decode<=0;
                        exec1<=0;
                        exec2<=1;
                    end
                end 
            //exec2
                else if(exec2)begin
                    fetch<=1;
                    decode<=0;
                    exec1<=0;
                    exec2<=0;
                end
            end
        end   
    end
endmodule