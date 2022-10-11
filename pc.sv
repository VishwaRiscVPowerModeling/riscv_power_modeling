module PROGRAM_COUNTER (CLK,RST,ALU_ZERO,OFFSET,CTRL_BRANCH,INST_ADDR);

    input   logic   CLK;
    input   logic   RST;
    input   logic                                       ALU_ZERO;
    input   logic signed [RISC_V_DATA_WIDTH - 1 : 0]    OFFSET;
    input   logic                                       CTRL_BRANCH;
    output  logic [INST_MEM_ADD_BIT_WIDTH - 1 : 0] INST_ADDR = INST_MEM_ADD_BIT_WIDTH'('b0) ;

       always_ff @(posedge CLK or posedge RST) begin
        if (RST) begin
            INST_ADDR <= INST_MEM_ADD_BIT_WIDTH'('b0);
        end else begin
            if (ALU_ZERO && CTRL_BRANCH) begin
                INST_ADDR <= INST_ADDR + (OFFSET[RISC_V_DATA_WIDTH - 1 : 0] << 1);
            end else begin
                INST_ADDR <= INST_ADDR + INST_MEM_ADD_BIT_WIDTH'('b100);
            end
        end
    end


endmodule
