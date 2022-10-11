module register_file (

    clk,
    rst,

    reg_num_r0,
    reg_num_r1,
    reg_num_w,

    r_data_0,
    r_data_1,
    w_data,

    ctrl_reg_w,

    debug

    );


    input   logic                                       clk;                        
    input   logic                                       rst;                        

    input   logic [REGISTER_FILE_ADDRESS_WIDTH - 1 : 0] reg_num_r0;                 
    input   logic [REGISTER_FILE_ADDRESS_WIDTH - 1 : 0] reg_num_r1;                 
    input   logic [REGISTER_FILE_ADDRESS_WIDTH - 1 : 0] reg_num_w;                  

    output  logic [RISC_V_DATA_WIDTH - 1 : 0]           r_data_0;                  
    output  logic [RISC_V_DATA_WIDTH - 1 : 0]           r_data_1;                   
    input   logic [RISC_V_DATA_WIDTH - 1 : 0]           w_data;                     

    input   logic                                       ctrl_reg_w;                

    output  logic [15:0]    debug;                                                 


    logic [RISC_V_DATA_WIDTH - 1 : 0] RF [REGISTER_FILE_NUM];                      
  
    assign r_data_0 = RF[reg_num_r0];
    assign r_data_1 = RF[reg_num_r1];
    assign debug    = RF[31][15:0];
    
    initial begin
            integer j;
            for (j = 0; j < REGISTER_FILE_NUM; j = j + 1) RF[j] <= RISC_V_DATA_WIDTH'('b0);
    end


    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            integer i;
            for (i = 0; i < REGISTER_FILE_NUM; i = i + 1) RF[i] <= RISC_V_DATA_WIDTH'('b0);
        end else begin
            if (ctrl_reg_w) begin
                RF[reg_num_w] <= w_data;
            end
        end
    end

endmodule
