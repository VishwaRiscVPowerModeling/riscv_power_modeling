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
`include "forwarding_unit.sv"
`include "hazard_unit.sv"
`include "branch_comparator.sv"
`include "ifid_addr_offset.sv"
`include "2bit_bpredictor.sv"



module cpu (
    clk,
    rst,
    debug
);

input   logic           clk;
input   logic           rst;
output  logic [15:0]    debug;

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
logic signed  [INST_MEMORY_ADDRESS_WIDTH  - 1 : 0]   branch_offset;


ALU_ctrl_t  ALU_ctrl;
logic [RISC_V_DATA_WIDTH - 1 : 0]   exmem_ALU_data_out;
logic                               exmem_ALU_zero_flag;

logic [RISC_V_DATA_WIDTH - 1 : 0]   memwb_ALU_data_out;
logic [RISC_V_DATA_WIDTH - 1 : 0]   memwb_mem_read_data;

logic [RISC_V_DATA_WIDTH - 1 : 0]   memwb_mux_read_data;

reg [RISC_V_DATA_WIDTH  -1 : 0] idex_reg_r0,idex_reg_r1,exmem_reg_r1;

reg [INST_WIDTH -1 : 0] ifid_ir, idex_ir,exmem_ir, memwb_ir = NOP;

logic [REGISTER_FILE_ADDRESS_WIDTH -1:0] ifid_rs1,ifid_rs2,idex_rs1,idex_rs2,exmem_rd,memwb_rd,idex_rd;
logic [RISC_V_OPCODE_WIDTH -1 :0] idex_op, exmem_op, memwb_op;
logic [INST_MEMORY_ADDRESS_WIDTH  - 1 : 0] ifid_pc;
logic [INST_MEMORY_ADDRESS_WIDTH  - 1 : 0] idex_pc = 0;

logic [RISC_V_DATA_WIDTH  -1 : 0] forward_r_data_0,forward_r_data_1;

logic pc_hold, ifid_hold, ctrl_hold;
logic branch_decision_incorrect_flag;

logic  [INST_MEMORY_ADDRESS_WIDTH - 1 : 0]  branch_inst_addr,ifid_branch_inst_addr,idex_branch_inst_addr;  
logic  branch_decision,ifid_branch_decision,idex_branch_decision; 
logic  signed  [RISC_V_DATA_WIDTH - 1 : 0]  pc_branch_offset,ifid_branch_offset,idex_branch_offset;

logic branch_decision_take;


wire branch_eq_flag, if_flush;

assign if_flush = branch_decision_incorrect_flag ? 1'b1 : 1'b0;

assign ifid_rs1 = if_flush ? REGISTER_FILE_ADDRESS_WIDTH'('b0) : (ifid_hold ? ifid_rs1 : ifid_ir [19:15]);
assign ifid_rs2 = if_flush ? REGISTER_FILE_ADDRESS_WIDTH'('b0) : (ifid_hold ? ifid_rs2 : ifid_ir [24:20]);
assign ifid_pc =  if_flush ? INST_MEMORY_ADDRESS_WIDTH'('b0) : (ifid_hold ? ifid_pc :instruction_address);
assign ifid_ir =  if_flush ? INST_WIDTH'('b0) : (ifid_hold ? ifid_ir :instruction);

assign idex_op  = idex_ir [6:0];
assign exmem_op = exmem_ir [6:0];
assign memwb_rd = memwb_ir [11:7];
assign exmem_rd = exmem_ir [11:7];
assign idex_rd  =  idex_ir[11:7];

assign reg_read_data_0 = forward_r_data_0;
assign reg_read_data_1 = forward_r_data_1;


assign memwb_mux_read_data = memwb_ctrl_mem_to_reg ? memwb_mem_read_data : memwb_ALU_data_out; 

always @(posedge clk or posedge rst ) begin
if (rst) begin 

    ifid_branch_inst_addr = INST_MEMORY_ADDRESS_WIDTH'('b0);
    ifid_branch_decision  = 1'b1;
    ifid_branch_offset    = RISC_V_DATA_WIDTH'('b0);

    idex_branch_inst_addr    =     INST_MEMORY_ADDRESS_WIDTH'('b0);
    idex_branch_decision     =      1'b1;
    idex_branch_offset       =       RISC_V_DATA_WIDTH'('b0);

    
    idex_rs1 = 1'b0;
    idex_rs2 =1'b0;
    idex_pc = 1'b0;
    idex_ir = 1'b0;
    memwb_ir = 1'b0;
    exmem_ir = 1'b0;

    exmem_reg_r1 = 1'b0;
    exmem_ctrl_reg_w = 1'b0;
    exmem_ctrl_mem_w = 1'b0;
    exmem_ctrl_mem_r = 1'b0;
    exmem_ctrl_mem_to_reg = 1'b0;
    exmem_ctrl_branch = 1'b0;
    

    memwb_ctrl_mem_to_reg = 1'b0;
    memwb_ctrl_reg_w = 1'b0;
    memwb_ALU_data_out = 1'b0;

    end else begin

    ifid_branch_inst_addr <= branch_inst_addr;
    ifid_branch_decision  <= branch_decision;
    ifid_branch_offset    <= pc_branch_offset;

    idex_branch_inst_addr    <=       ifid_branch_inst_addr;
    idex_branch_decision     <=       ifid_branch_decision ;
    idex_branch_offset       <=       ifid_branch_offset  ; 

    
    idex_rs1 <= ifid_rs1;
    idex_rs2 <= ifid_rs2;
    
    idex_pc <= ifid_pc;
    idex_ir <= ifid_ir;

    exmem_ir <= idex_ir;
    memwb_ir <= exmem_ir;

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
end


hazard_unit hazard_unit(
    .ifid_ir(ifid_ir),
    .exmem_ctrl_mem_r(exmem_ctrl_mem_r),
    .exmem_rd(exmem_rd),
    .idex_ctrl_mem_r(idex_ctrl_mem_r), 
    .idex_rd(idex_rd), 
    .ifid_rs1(ifid_rs1),
    .ifid_rs2(ifid_rs2),
    .pc_hold(pc_hold),
    .ifid_hold(ifid_hold),
    .ctrl_hold(ctrl_hold));

//program_counter program_counter(
//    .clk(clk),
//    .rst(rst),
//    .pc_hold(pc_hold),
//    .pc_src(exmem_ctrl_branch & exmem_ALU_zero_flag),
//    .inst_offset_addr(exmem_offset),
//    .inst_addr(instruction_address));



two_bit_bpredictor two_bit_predictor(
    .clk(clk),
    .rst(rst),
    .branch_taken_flag(branch_eq_flag),
    .branch_flag(idex_ctrl_branch),
    .branch_decision_take(branch_decision_take));

program_counter program_counter(
    .clk(clk),
    .rst(rst),
    .pc_hold(pc_hold),
    .pc_src(idex_ctrl_branch & branch_eq_flag ),
    .inst_offset_addr(branch_offset),
    .inst_addr(instruction_address),
    .current_inst(instruction),
    .branch_decision_take(branch_decision_take),
    .branch_decision_incorrect_flag(branch_decision_incorrect_flag),
    .branch_inst_addr(branch_inst_addr),
    .branch_decision(branch_decision),
    .branch_offset(pc_branch_offset),
    .idex_branch_inst_addr(idex_branch_inst_addr),
    .idex_branch_offset(idex_branch_offset),
    .idex_branch_decision(idex_branch_decision));


inst_memory instruction_memory(
    .inst_add(instruction_address),
    .inst_data(instruction));


forwarding_unit forwarding_unit (
    .idex_rs1(idex_rs1),
    .idex_rs2(idex_rs2),
    .memwb_rd(memwb_rd),
    .exmem_rd(exmem_rd),
    .memwb_ctrl_reg_w(memwb_ctrl_reg_w),
    .exmem_ctrl_reg_w(exmem_ctrl_reg_w),
    .idex_reg_r0(idex_reg_r0),
    .idex_reg_r1(idex_reg_r1),
    .exmem_ALU_data_out(exmem_ALU_data_out),
    .memwb_mux_read_data(memwb_mux_read_data),
    .forward_r_data_0(forward_r_data_0),
    .forward_r_data_1(forward_r_data_1));

control_unit control_unit(
    .clk(clk),
    .rst(rst),
    .ctrl_hold(ctrl_hold),
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
    .w_data(memwb_mux_read_data),
    .ctrl_reg_w(memwb_ctrl_reg_w),
    .debug(debug));

branch_comparator branch_comparator(
    .clk(clk),
    .rst(rst),
    .r_data_0(forward_r_data_0),
    .r_data_1(forward_r_data_1),
    .branch_eq_flag(branch_eq_flag),
    .idex_ir(idex_ir),
    .idex_branch_decision(idex_branch_decision),
    .branch_decision_incorrect_flag(branch_decision_incorrect_flag));



imm_generator imm_generator(
    .clk(clk),
    .rst(rst),
    .instruction(ifid_ir),
    .offset(idex_offset));


//addr_offset addr_offset(
//    .clk(clk),
//    .rst(rst),
//    .offset(idex_offset),
//    .pc(idex_pc),
//    .offset_pc(exmem_offset));


ifid_addr_offset ifid_addr_offset(
    .rst(rst),
    .offset(idex_offset),
    .pc(idex_pc),
    .offset_pc(branch_offset));






ALU_control ALU_control(
    .funct3(idex_ir[14:12]),
    .funct7(idex_ir[31:25]),
    .ALU_ctrl(ALU_ctrl),
    .ctrl_ALU_op(idex_ctrl_ALU_op));


ALU ALU(
    .clk(clk),
    .rst(rst),
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
