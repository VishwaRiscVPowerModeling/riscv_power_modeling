module inst_memory (
    inst_add,
    inst_data
);

    output  logic   [INST_WIDTH - 1 : 0]                 inst_data;
    input   logic   [INST_MEMORY_ADDRESS_WIDTH - 1 : 0]    inst_add;


    reg [INST_BYTE_WIDTH - 1 : 0]  [7:0] inst_mem  [INST_MEM_DEPTH-1:0];   

    logic [INST_MEMORY_ADDRESS_WIDTH - 1 : 0]  inst_adjusted_add = 0;
    
    initial begin
        $readmemh("instruction_memory.mem", inst_mem, INST_MEMORY_ADDRESS_WIDTH'('h0), INST_MEMORY_ADDRESS_WIDTH'('hFFFF));
    end
    always@(inst_add) begin
    assign inst_adjusted_add = int'(inst_add/4);

    if ( inst_add % INST_BYTE_WIDTH == 0 ) begin
        assign inst_data = inst_mem [inst_adjusted_add] [INST_BYTE_WIDTH - 1 : 0]  ;
    end
    else if ( inst_add % INST_BYTE_WIDTH == INST_BYTE_WIDTH / 2 ) begin 
       assign inst_data = inst_mem [inst_adjusted_add] [INST_BYTE_WIDTH /2 - 1 : 0]  ;
    end
    else begin
        assign inst_data = inst_mem [0][INST_BYTE_WIDTH -1 : 0];
        $error(" ERROR :- INCORRECT INSTRUCTION ADDRESS. " );
    end

    end


endmodule
