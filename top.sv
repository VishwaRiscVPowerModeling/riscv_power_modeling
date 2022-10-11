`include "params.sv"
`include "alu.sv"
`include "alu_control.sv"
`include "control_unit.sv"
`include "data_memory.sv"
`include "imm_generator.sv"
`include "instruction_memory.sv"
`include "pc.sv"
`include "register_file.sv"



import params_pkg::*;

module top (
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

logic [INST_WIDTH - 1 : 0] instruction;
logic [INST_MEMORY_ADDRESS_WIDTH - 1 : 0] instruction_address;

logic [RISC_V_DATA_WIDTH - 1 : 0] reg_read_data_0;
logic [RISC_V_DATA_WIDTH - 1 : 0] reg_read_data_1;

logic signed [RISC_V_DATA_WIDTH - 1 : 0] offset;

ALU_ctrl_t  ALU_ctrl;
logic [RISC_V_DATA_WIDTH - 1 : 0]   ALU_data_out;
logic                               ALU_zero_flag;

logic [RISC_V_DATA_WIDTH - 1 : 0] mem_read_data;





control_unit control_unit(
    .opcode(opcode_t'(instruction[6:0])),
    .ctrl_ALU_op(ctrl_ALU_op),
    .ctrl_ALU_src(ctrl_ALU_src),
    .ctrl_reg_w(ctrl_reg_w),
    .ctrl_mem_w(ctrl_mem_w),
    .ctrl_mem_r(ctrl_mem_r),
    .ctrl_mem_to_reg(ctrl_mem_to_reg),
    .ctrl_branch(ctrl_branch));


PROGRAM_COUNTER PROGRAM_COUNTER(
    .CLK(clk),
    .RST(rst),
    .ALU_ZERO(ALU_zero_flag),
    .OFFSET(offset),
    .CTRL_BRANCH(ctrl_branch),
    .INST_ADDR(instruction_address));


INST_MEMORY instruction_memory(
    .INST_ADD(instruction_address),
    .INST_DATA(instruction));


register_file register_file(
    .clk(clk),
    .rst(rst),
    .reg_num_r0(instruction[19:15]),
    .reg_num_r1(instruction[24:20]),
    .reg_num_w(instruction[11:7]),
    .r_data_0(reg_read_data_0),
    .r_data_1(reg_read_data_1),
    .w_data(ctrl_mem_to_reg ? mem_read_data : ALU_data_out),
    .ctrl_reg_w(ctrl_reg_w),
    .debug(debug));


imm_generator imm_generator(
    .instruction(instruction),
    .offset(offset));


ALU_control ALU_control(
    .funct3(instruction[14:12]),
    .funct7(instruction[31:25]),
    .ALU_ctrl(ALU_ctrl),
    .ctrl_ALU_op(ctrl_ALU_op));


ALU ALU(
    .data_in_A(reg_read_data_0),
    .data_in_B(ctrl_ALU_src ? offset : reg_read_data_1),
    .data_out(ALU_data_out),
    .zero(ALU_zero_flag),
    .ALU_ctrl(ALU_ctrl));


data_memory data_memory(
    .clk(clk),
    .rst(rst),
    .w_data(reg_read_data_1),
    .r_data(mem_read_data),
    .address(ALU_data_out[DATA_MEMORY_ADDRESS_WIDTH - 1 : 0]),
    .ctrl_mem_w(ctrl_mem_w),
    .ctrl_mem_r(ctrl_mem_r));


endmodule
