module hazard_unit ( idex_ctrl_mem_r, idex_rd, ifid_rs1,ifid_rs2,pc_hold, ifid_hold, ctrl_hold);
input logic idex_ctrl_mem_r;
input logic [REGISTER_FILE_ADDRESS_WIDTH -1:0] ifid_rs1,ifid_rs2,idex_rd;
output logic pc_hold, ifid_hold, ctrl_hold; 

always_comb begin 
    if ( idex_ctrl_mem_r && ((idex_rd == ifid_rs1) | (idex_rd == ifid_rs2))) begin
    pc_hold = 1'b1;
    ifid_hold =1'b1;
    ctrl_hold =1'b1;

    end else begin 
    pc_hold = 1'b0;
    ifid_hold =1'b0;
    ctrl_hold =1'b0;

end 
end

endmodule 

