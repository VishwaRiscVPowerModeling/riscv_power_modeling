module tb_top();
logic clk,rst;
logic [15:0] debug;


cpu cpu(.clk(clk),.rst(rst),.debug(debug));


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
 wait_cycles(100);
 $finish;
end 


always #5 clk = !clk;

initial
    begin
        $fsdbDumpfile("test.fsdb");
        $fsdbDumpMDA();
        $fsdbDumpvars();
    end

endmodule
