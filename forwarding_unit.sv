module forwarding_unit (idex_rs1,idex_rs2,memwb_rd,exmem_rd,memwb_ctrl_reg_w,exmem_ctrl_reg_w,idex_reg_r0,idex_reg_r1,exmem_ALU_data_out,memwb_mux_read_data,forward_r_data_0,forward_r_data_1);

input logic [REGISTER_FILE_ADDRESS_WIDTH -1:0] idex_rs1,idex_rs2,exmem_rd,memwb_rd;
input logic [RISC_V_DATA_WIDTH - 1 : 0] idex_reg_r0,idex_reg_r1,exmem_ALU_data_out,memwb_mux_read_data;
input logic memwb_ctrl_reg_w,exmem_ctrl_reg_w;
output logic [RISC_V_DATA_WIDTH - 1 : 0] forward_r_data_0,forward_r_data_1;

logic flag_exmem_rd_idex_rs1;
logic flag_exmem_rd_idex_rs2;
logic flag_memwb_rd_idex_rs1;
logic flag_memwb_rd_idex_rs2;






always_comb begin 
 flag_exmem_rd_idex_rs1 = (exmem_ctrl_reg_w && (exmem_rd !=0)  && (exmem_rd == idex_rs1)) ;
 flag_exmem_rd_idex_rs2 = (exmem_ctrl_reg_w && (exmem_rd !=0)  && (exmem_rd == idex_rs2)) ;
 flag_memwb_rd_idex_rs1 = (memwb_ctrl_reg_w  && (memwb_rd !=0)  && !flag_exmem_rd_idex_rs1   && (memwb_rd == idex_rs1)) ;
 flag_memwb_rd_idex_rs2 = (memwb_ctrl_reg_w  && (memwb_rd !=0)  && !flag_exmem_rd_idex_rs2  && (memwb_rd == idex_rs2)) ;

if (flag_exmem_rd_idex_rs1 ) 
    forward_r_data_0 = exmem_ALU_data_out;

else if (flag_memwb_rd_idex_rs1 ) 
    forward_r_data_0 = memwb_mux_read_data;

else forward_r_data_0 = idex_reg_r0;

if (flag_exmem_rd_idex_rs2 ) 
    forward_r_data_1 = exmem_ALU_data_out;

else if ( flag_memwb_rd_idex_rs2)
    forward_r_data_1 = memwb_mux_read_data;

else forward_r_data_1 = idex_reg_r1;

end
endmodule 
