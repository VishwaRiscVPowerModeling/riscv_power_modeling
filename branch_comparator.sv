module branch_comparator (
clk,
rst,
r_data_0,
r_data_1,
branch_eq_flag,
idex_ir,
idex_branch_decision,
branch_decision_incorrect_flag);

input logic rst,clk;
input logic [RISC_V_DATA_WIDTH - 1 : 0]           r_data_0;                   
input logic [RISC_V_DATA_WIDTH - 1 : 0]           r_data_1;
input logic  [INST_WIDTH -1 : 0] idex_ir;
input logic idex_branch_decision;
output logic branch_decision_incorrect_flag; 
output logic branch_eq_flag;

wire [RISC_V_DATA_WIDTH - 1 : 0] xor_r_data;


assign xor_r_data = r_data_0 ^ r_data_1;                // compare two regesiter values at idex stage 
    assign branch_eq_flag = ! ( | xor_r_data);          // if both register values are matching --> branch equal flag set to 1


always@(posedge clk or posedge rst) begin
    if(rst) branch_decision_incorrect_flag = 1'b0;
    else begin 
    if (idex_ir[6:0] ==  7'b1100011) begin 
        if (branch_eq_flag == ~idex_branch_decision )   //compares the branch predictor desicision with actual branch decision at idex stage 
            branch_decision_incorrect_flag = 1'b1;

        else  branch_decision_incorrect_flag =1'b0;


        end 
    end
end 



endmodule 
