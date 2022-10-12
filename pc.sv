module program_counter (clk,rst,pc_src,inst_offset_addr,inst_addr);

    input   logic   clk;
    input   logic   rst;
    input   logic                                       pc_src;
    input   logic signed [INST_MEMORY_ADDRESS_WIDTH - 1 : 0]   inst_offset_addr;
    output  logic [INST_MEMORY_ADDRESS_WIDTH  - 1 : 0] inst_addr = INST_MEMORY_ADDRESS_WIDTH '('b0) ;

       always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            inst_addr <= INST_MEMORY_ADDRESS_WIDTH '('b0);
        end else begin
            if (pc_src) begin
              //  inst_addr <= inst_addr + (offset[RISC_V_DATA_WIDTH - 1 : 0] << 1);
                   inst_addr <= inst_offset_addr;
            end else begin
                inst_addr <= inst_addr + INST_MEMORY_ADDRESS_WIDTH '('b100);
            end
        end
    end


endmodule
