module control_unit (
    clk,
    rst,
    opcode,
    ctrl_hold,

    ctrl_ALU_op,
    ctrl_ALU_src,

    ctrl_reg_w,
    
    ctrl_mem_w,
    ctrl_mem_r,
    ctrl_mem_to_reg,

    ctrl_branch
    
);

    
    input clk,rst,ctrl_hold;
    input   opcode_t    opcode;

    output  logic [1:0] ctrl_ALU_op;
    output  logic       ctrl_ALU_src;

    output  logic       ctrl_reg_w;
    
    output  logic       ctrl_mem_w;
    output  logic       ctrl_mem_r;
    output  logic       ctrl_mem_to_reg;

    output  logic       ctrl_branch;


     logic [1:0] int_ctrl_ALU_op;
     logic       int_ctrl_ALU_src;

     logic       int_ctrl_reg_w;
    
     logic       int_ctrl_mem_w;
     logic       int_ctrl_mem_r;
     logic       int_ctrl_mem_to_reg;

     logic       int_ctrl_branch;
    
    always @(posedge clk or posedge rst  ) begin

    if (rst | ctrl_hold ) begin

            ctrl_ALU_op     = 2'b00;
            ctrl_ALU_src    = 1'b0;
            ctrl_reg_w      = 1'b0;
            ctrl_mem_w      = 1'b0;
            ctrl_mem_r      = 1'b0;
            ctrl_mem_to_reg = 1'b0;
            ctrl_branch     = 1'b0;


        end else begin 
        
       ctrl_ALU_op     <= int_ctrl_ALU_op    ; 
       ctrl_ALU_src    <= int_ctrl_ALU_src   ;  
       ctrl_reg_w      <= int_ctrl_reg_w     ;  
       ctrl_mem_w      <= int_ctrl_mem_w     ;  
       ctrl_mem_r      <= int_ctrl_mem_r     ;  
       ctrl_mem_to_reg <= int_ctrl_mem_to_reg;  
       ctrl_branch     <= int_ctrl_branch    ;   
       

       end 
       end 

      always_comb begin 
        case (opcode)
        LOAD:
        begin
            int_ctrl_ALU_op     = 2'b00;
            int_ctrl_ALU_src    = 1'b1;
            int_ctrl_reg_w      = 1'b1;
            int_ctrl_mem_w      = 1'b0;
            int_ctrl_mem_r      = 1'b1;
            int_ctrl_mem_to_reg = 1'b1;
            int_ctrl_branch     = 1'b0;
        end

        STORE:
        begin
            int_ctrl_ALU_op     = 2'b00;
            int_ctrl_ALU_src    = 1'b1;
            int_ctrl_reg_w      = 1'b0;
            int_ctrl_mem_w      = 1'b1;
            int_ctrl_mem_r      = 1'b0;
            int_ctrl_mem_to_reg = 1'b0;
            int_ctrl_branch     = 1'b0;
        end

        ARITH:
        begin
            int_ctrl_ALU_op     = 2'b10;
            int_ctrl_ALU_src    = 1'b0;
            int_ctrl_reg_w      = 1'b1;
            int_ctrl_mem_w      = 1'b0;
            int_ctrl_mem_r      = 1'b0;
            int_ctrl_mem_to_reg = 1'b0;
            int_ctrl_branch     = 1'b0;
        end

        BRANCH:
        begin 
            int_ctrl_ALU_op     = 2'b01;
            int_ctrl_ALU_src    = 1'b0;
            int_ctrl_reg_w      = 1'b0;
            int_ctrl_mem_w      = 1'b0;
            int_ctrl_mem_r      = 1'b0;
            int_ctrl_mem_to_reg = 1'b0;
            int_ctrl_branch     = 1'b1;
        end


        default:
        begin
            int_ctrl_ALU_op     = 2'b00;
            int_ctrl_ALU_src    = 1'b0;
            int_ctrl_reg_w      = 1'b0;
            int_ctrl_mem_w      = 1'b0;
            int_ctrl_mem_r      = 1'b0;
            int_ctrl_mem_to_reg = 1'b0;
            int_ctrl_branch     = 1'b0;
        end

    endcase
    
    end

   
    

endmodule
