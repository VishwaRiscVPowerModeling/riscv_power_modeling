module two_bit_bpredictor(clk,rst,branch_taken_flag,branch_flag,branch_decision_take);
input logic clk,rst,branch_taken_flag,branch_flag;
output logic  branch_decision_take;
bpredictor_state_t  current_state;

//branch_flag --> idex_ctrl_branch
//branch_taken_flag --> branch_eq_flag 



always@(posedge clk  or posedge rst ) begin 
if(rst)  begin
    current_state <= predict_taken_weak;
   // nxt_state     <= predict_taken_weak;
    branch_decision_take <= 1'b1;
    end else begin

    if (branch_flag) begin
    case(current_state) 
    predict_taken_strong:
        begin 
            if(branch_taken_flag) current_state = predict_taken_strong;
                else current_state = predict_taken_weak;
        end 
    predict_taken_weak:
        begin 
            if(branch_taken_flag) current_state = predict_taken_strong;
                else current_state = predict_not_taken_weak;
        end 
    predict_not_taken_weak:
        begin 
            if(branch_taken_flag) current_state = predict_taken_weak;
                else current_state = predict_not_taken_strong;
        end
    predict_not_taken_strong:
        begin 
            if(branch_taken_flag) current_state = predict_not_taken_weak;
                else current_state = predict_not_taken_strong;
        end
    endcase
    end


    //current_state <= nxt_state;
    branch_decision_take <=  ( current_state == predict_taken_strong || current_state == predict_taken_weak) ? 1'b1 : 1'b0;
    end


end 



endmodule 
