module ALU (
    clk,
    rst,
    data_in_A,
    data_in_B,
    data_out,

    zero,

    ALU_ctrl
);

    input   logic signed    [RISC_V_DATA_WIDTH - 1 : 0]     data_in_A;
    input   logic signed    [RISC_V_DATA_WIDTH - 1 : 0]     data_in_B;
    output  logic signed    [RISC_V_DATA_WIDTH - 1 : 0]     data_out;
    logic signed    [RISC_V_DATA_WIDTH - 1 : 0]     int_data_out;
    output  logic                                   zero;
    logic                                          int_zero;
    input   ALU_ctrl_t                              ALU_ctrl;
    input clk,rst; 

    
    /*
    ALU operations
    1.AND
    2.OR
    3.ADD
    4.SUB
    */
    always @(*) begin
    case (ALU_ctrl)
            AND: int_data_out = data_in_A & data_in_B;
            OR:  int_data_out = data_in_A | data_in_B;
            ADD: int_data_out = data_in_A + data_in_B;
            SUB: int_data_out = data_in_A - data_in_B;
            default: int_data_out = RISC_V_DATA_WIDTH'('b0);
        endcase

    end

    //Zero outputs the comparison results for branch equal operation 

    always @(posedge clk or posedge rst)
    begin
    if(rst) begin 
        data_out = RISC_V_DATA_WIDTH'('b0);
        zero = 1'b0;
    end else begin
        data_out = int_data_out;
        zero = (data_out == RISC_V_DATA_WIDTH'('b0));
    end
    end
endmodule
