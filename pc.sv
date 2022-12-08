module program_counter (clk,rst,pc_src,inst_offset_addr,inst_addr,pc_hold);

    input   logic   clk;
    input   logic   rst;
    input logic pc_hold;
    input   logic                                       pc_src;
    input   logic [INST_MEMORY_ADDRESS_WIDTH - 1 : 0]   inst_offset_addr;
    output  logic [INST_MEMORY_ADDRESS_WIDTH  - 1 : 0] inst_addr = INST_MEMORY_ADDRESS_WIDTH '('b0) ;
    logic [INST_MEMORY_ADDRESS_WIDTH - 1 : 0]   debug_inst_offset_addr;
       
       always @(inst_offset_addr)
                debug_inst_offset_addr = inst_offset_addr;
       
       
       always @(posedge clk or posedge rst) begin
        if (rst) begin
            inst_addr <= INST_MEMORY_ADDRESS_WIDTH '('b0);
        end else begin
            if (pc_hold) begin 
                inst_addr <= inst_addr;
                end else begin
            if (pc_src) begin
                  //inst_addr <= inst_addr + (inst_offset_addr[RISC_V_DATA_WIDTH - 1 : 0] << 1);
                   inst_addr <= debug_inst_offset_addr;
            end else begin
                inst_addr <= inst_addr + INST_MEMORY_ADDRESS_WIDTH '('b100);
            end
            end
        end
    end


endmodule
