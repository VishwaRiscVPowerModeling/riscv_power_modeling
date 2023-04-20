module addr_offset (clk,rst,offset, pc,offset_pc);
input logic clk,rst;
input logic signed [RISC_V_DATA_WIDTH - 1 : 0] offset;
input logic [INST_MEMORY_ADDRESS_WIDTH - 1 : 0] pc;
output logic [INST_MEMORY_ADDRESS_WIDTH - 1 : 0] offset_pc;
logic signed [RISC_V_DATA_WIDTH - 1 : 0] debug_offset;
//logic  [RISC_V_DATA_WIDTH - 1 : 0] debug_offset_pc;


always @( pc or offset) 
 debug_offset = pc+ (offset[RISC_V_DATA_WIDTH - 1 : 0] << 1);  //generates the instrcution address offset for brach opration 

always @(posedge clk or posedge rst) begin 
if (rst) begin 
    offset_pc =0;
    end else begin
//if ( offset > 0) begin
offset_pc = debug_offset;
//pc + (offset[RISC_V_DATA_WIDTH - 1 : 0] << 1);
//end else begin 
//offset_pc <= pc - (offset[RISC_V_DATA_WIDTH - 1 : 0] << 1);
//end
end
end
endmodule 
