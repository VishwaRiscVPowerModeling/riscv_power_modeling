`include "params.sv"
import params_pkg::*;


`include "addr_offset.sv"
`include "alu.sv"
`include "alu_control.sv"
`include "control_unit.sv"
`include "data_memory.sv"
`include "imm_generator.sv"
`include "instruction_memory.sv"
`include "pc.sv"
`include "register_file.sv"




module cpu (
    clk,
    rst,
    debug
);

input   logic           clk;
input   logic           rst;
output  logic [15:0]    debug;



logic [1:0] ctrl_ALU_op;
logic       ctrl_ALU_src;
logic       ctrl_reg_w;
logic       ctrl_mem_w;
logic       ctrl_mem_r;
logic       ctrl_mem_to_reg;
logic       ctrl_branch;


logic [1:0] idex_ctrl_ALU_op;
logic       idex_ctrl_ALU_src;
logic       idex_ctrl_reg_w;
logic       idex_ctrl_mem_w;
logic       idex_ctrl_mem_r;
logic       idex_ctrl_mem_to_reg;
logic       idex_ctrl_branch;



logic       exmem_ctrl_reg_w;
logic       exmem_ctrl_mem_w;
logic       exmem_ctrl_mem_r;
logic       exmem_ctrl_mem_to_reg;
logic       exmem_ctrl_branch;

logic       memwb_ctrl_mem_to_reg;
logic       memwb_ctrl_reg_w;



logic [INST_WIDTH - 1 : 0] instruction;
logic [INST_MEMORY_ADDRESS_WIDTH - 1 : 0] instruction_address;

logic [RISC_V_DATA_WIDTH - 1 : 0] reg_read_data_0;
logic [RISC_V_DATA_WIDTH - 1 : 0] reg_read_data_1;

logic signed [RISC_V_DATA_WIDTH - 1 : 0] idex_offset;
logic signed  [INST_MEMORY_ADDRESS_WIDTH  - 1 : 0]   exmem_offset;

ALU_ctrl_t  ALU_ctrl;
logic [RISC_V_DATA_WIDTH - 1 : 0]   exmem_ALU_data_out;
logic                               exmem_ALU_zero_flag;

logic [RISC_V_DATA_WIDTH - 1 : 0]   memwb_ALU_data_out;
logic [RISC_V_DATA_WIDTH - 1 : 0]   memwb_mem_read_data;


reg [RISC_V_DATA_WIDTH  -1 : 0] idex_reg_r0,idex_reg_r1,exmem_reg_r1;


reg [INST_WIDTH -1 : 0] ifid_ir, idex_ir,exmem_ir, memwb_ir = NOP;

logic [4:0] ifid_rs1,ifid_rs2,memwb_rd;
logic [6:0] idex_op, exmem_op, memwb_op;
logic [INST_MEMORY_ADDRESS_WIDTH  - 1 : 0] ifid_pc;
logic [INST_MEMORY_ADDRESS_WIDTH  - 1 : 0] idex_pc = 0;


assign ifid_rs1 = ifid_ir [19:15];
assign ifid_rs2 = ifid_ir [24:20];
assign idex_op  = idex_ir [6:0];
assign exmem_op = exmem_ir [6:0];
assign memwb_rd = memwb_ir [11:7];

assign reg_read_data_0 = idex_reg_r0;
assign reg_read_data_1 = idex_reg_r1;




always @(posedge clk) begin
ifid_pc = instruction_address;
idex_pc <= ifid_pc;
ifid_ir <= instruction;
idex_ir <= ifid_ir;
memwb_ir <= idex_ir;
exmem_reg_r1 <= idex_reg_r1;

exmem_ctrl_reg_w <= idex_ctrl_reg_w ;
exmem_ctrl_mem_w <= idex_ctrl_mem_w ;
exmem_ctrl_mem_r <= idex_ctrl_mem_r  ;
exmem_ctrl_mem_to_reg <= idex_ctrl_mem_to_reg  ;
exmem_ctrl_branch <= idex_ctrl_branch ;


memwb_ctrl_mem_to_reg <= exmem_ctrl_mem_to_reg ;
memwb_ctrl_reg_w <= exmem_ctrl_reg_w ;
memwb_ALU_data_out <= exmem_ALU_data_out;
end


program_counter program_counter(
    .clk(clk),
    .rst(rst),
    .pc_src(exmem_ctrl_branch & exmem_ALU_zero_flag),
    .inst_offset_addr(exmem_offset),
    .inst_addr(instruction_address));

inst_memory instruction_memory(
    .inst_add(instruction_address),
    .inst_data(instruction));


control_unit control_unit(
    .clk(clk),
    .opcode(opcode_t'(ifid_ir[6:0])),
    .ctrl_ALU_op(idex_ctrl_ALU_op),
    .ctrl_ALU_src(idex_ctrl_ALU_src),
    .ctrl_reg_w(idex_ctrl_reg_w),
    .ctrl_mem_w(idex_ctrl_mem_w),
    .ctrl_mem_r(idex_ctrl_mem_r),
    .ctrl_mem_to_reg(idex_ctrl_mem_to_reg),
    .ctrl_branch(idex_ctrl_branch));



register_file register_file(
    .clk(clk),
    .rst(rst),
    .reg_num_r0(ifid_rs1),
    .reg_num_r1(ifid_rs2),
    .reg_num_w(memwb_rd),
    .r_data_0(idex_reg_r0),
    .r_data_1(idex_reg_r1),
    .w_data(memwb_ctrl_mem_to_reg ? memwb_mem_read_data : memwb_ALU_data_out),
    .ctrl_reg_w(memwb_ctrl_reg_w),
    .debug(debug));


imm_generator imm_generator(
    .clk(clk),
    .instruction(ifid_ir),
    .offset(idex_offset));


addr_offset addr_offset(
    .clk(clk),
    .offset(idex_offset),
    .pc(idex_pc),
    .offset_pc(exmem_offset));


ALU_control ALU_control(
    .funct3(idex_ir[14:12]),
    .funct7(idex_ir[31:25]),
    .ALU_ctrl(ALU_ctrl),
    .ctrl_ALU_op(idex_ctrl_ALU_op));


ALU ALU(
    .clk(clk),
    .data_in_A(reg_read_data_0),
    .data_in_B(idex_ctrl_ALU_src ? idex_offset : reg_read_data_1),
    .data_out(exmem_ALU_data_out),
    .zero(exmem_ALU_zero_flag),
    .ALU_ctrl(ALU_ctrl));


data_memory data_memory(
    .clk(clk),
    .rst(rst),
    .w_data(exmem_reg_r1),
    .r_data(memwb_mem_read_data),
    .address(exmem_ALU_data_out[DATA_MEMORY_ADDRESS_WIDTH - 1 : 0]),
    .ctrl_mem_w(exmem_ctrl_mem_w),
    .ctrl_mem_r(exmem_ctrl_mem_r));


endmodule
