module tb_top();
logic clk,rst;
logic debug;


top top(.clk(clk),.rst(rst),.debug(debug));


task wait_cycles(input int cycles);
begin 
    for (int i=0; i< cycles; i++)
            @(negedge clk);
            end;
endtask


initial begin
  clk = 1'b0;
  rst = 1'b0;
  #10 rst =1'b1;
  #10 rst =1'b0;
 wait_cycles(10);
 $finish;
end 


always #5 clk = !clk;

initial
    begin
        $fsdbDumpfile("test.fsdb");
        $fsdbDumpvars(0);
    end

endmodule
