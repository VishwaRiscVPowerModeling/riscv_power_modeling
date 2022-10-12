module addr_offset (clk,offset, pc, offset_pc);
input logic clk;
input logic signed [RISC_V_DATA_WIDTH - 1 : 0] offset;
input logic [INST_MEMORY_ADDRESS_WIDTH - 1 : 0] pc;
output logic [INST_MEMORY_ADDRESS_WIDTH - 1 : 0] offset_pc;


always @(posedge clk) begin 
if ( offset > 0) begin
offset_pc <= pc + (offset[RISC_V_DATA_WIDTH - 1 : 0] << 1);
end else begin 
offset_pc <= pc - (offset[RISC_V_DATA_WIDTH - 1 : 0] << 1);
end

end
endmodule 
