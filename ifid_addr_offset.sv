module ifid_addr_offset (rst,offset, pc,offset_pc);
input logic rst;
input logic signed [RISC_V_DATA_WIDTH - 1 : 0] offset;
input logic [INST_MEMORY_ADDRESS_WIDTH - 1 : 0] pc;
output logic [INST_MEMORY_ADDRESS_WIDTH - 1 : 0] offset_pc;
logic signed [RISC_V_DATA_WIDTH - 1 : 0] debug_offset;


always @( pc or offset) 
    debug_offset = pc+ (offset[RISC_V_DATA_WIDTH - 1 : 0] << 1);

always @(debug_offset  or posedge rst) begin 
    if (rst) begin 
      offset_pc =0;
      end else begin
    offset_pc = debug_offset;
    end
end
endmodule 
