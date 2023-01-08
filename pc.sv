module program_counter (clk,rst,pc_src,inst_offset_addr,inst_addr,pc_hold,current_inst,branch_decision_take,branch_decision_incorrect_flag,branch_inst_addr,branch_decision,branch_offset,idex_branch_inst_addr,idex_branch_offset,idex_branch_decision);

    input   logic   clk;
    input   logic   rst;
    input   logic   pc_hold;
    input   logic   branch_decision_take;
    input   logic   branch_decision_incorrect_flag;
    input   logic   [INST_WIDTH - 1 : 0] current_inst; // inst_memory instruction output 
    input   logic                                       pc_src;
    input   logic [INST_MEMORY_ADDRESS_WIDTH - 1 : 0]   inst_offset_addr;
    output  logic [INST_MEMORY_ADDRESS_WIDTH - 1 : 0]   inst_addr = INST_MEMORY_ADDRESS_WIDTH '('b0) ;
    logic         [INST_MEMORY_ADDRESS_WIDTH - 1 : 0]   debug_inst_offset_addr;
    logic  current_inst_branch_flag;
    logic  signed    [RISC_V_DATA_WIDTH - 1 : 0] current_inst_offset;
    logic  [11:0] imm;
    output logic  [INST_MEMORY_ADDRESS_WIDTH - 1 : 0]  branch_inst_addr;  
    output logic  branch_decision; 
    output logic  signed  [RISC_V_DATA_WIDTH - 1 : 0]  branch_offset;
    input logic  [INST_MEMORY_ADDRESS_WIDTH - 1 : 0]  idex_branch_inst_addr;  
    input logic  idex_branch_decision; 
    input logic  signed  [RISC_V_DATA_WIDTH - 1 : 0]  idex_branch_offset;

       
       always @(inst_offset_addr)
                debug_inst_offset_addr = inst_offset_addr;
       
       
       always @(posedge clk or posedge rst) begin
        if (rst) begin
            inst_addr <= INST_MEMORY_ADDRESS_WIDTH '('b0);
        end else begin
            if (pc_hold) begin 
                inst_addr <= inst_addr;
                end else begin
                        if (branch_decision_incorrect_flag == 1'b1) begin
                            if(idex_branch_decision == 1'b1) begin
                                inst_addr <= idex_branch_inst_addr + INST_MEMORY_ADDRESS_WIDTH '('b100);
                            end else begin
                                inst_addr <= INST_MEMORY_ADDRESS_WIDTH '(idex_branch_offset);
                                end
                        end else begin 
                        if (current_inst_branch_flag && branch_decision_take) begin
                            inst_addr <= INST_MEMORY_ADDRESS_WIDTH '(current_inst_offset);
                        end else begin
                            inst_addr <= inst_addr + INST_MEMORY_ADDRESS_WIDTH '('b100);
                        end

                    end
                end
        end
        end

        always @(current_inst) begin
            if (current_inst[6:0] ==  7'b1100011) begin 
                current_inst_branch_flag = 1'b1;
                imm = {current_inst[31], current_inst[7], current_inst[30:25], current_inst[11:8]};
                current_inst_offset   = inst_addr + (RISC_V_DATA_WIDTH'(signed'(imm)) << 1);
                branch_inst_addr = inst_addr;
                branch_decision  = branch_decision_take;
                branch_offset    = current_inst_offset;
            end    else current_inst_branch_flag =1'b0;
        end 

endmodule
