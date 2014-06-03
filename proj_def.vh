`ifndef PROJ_DEF_VH
`define PROJ_DEF_VH
`define REG_W 32
`define RF_REG_W 5 //Reg File Register width
`define RF_REG_NUM 32
`define DATA_W 32
`define ADDR_W 32
`define MEM_SIZE 16*1024 //16K
`define IMEM_SIZE 4*1024 //4K
`define ALU_CNTL_OP_W 6
`define INST_W  32

`define INST_OP_R_FORMAT 6'b000000 //0x0
`define INST_OP_LW       6'b100011 //0x23
`define INST_OP_SW       6'b101011 //0x2B
`define INST_OP_BEQ      6'b000100 //0x04
`define INST_OP_JMP      6'b000010 //0x02


`endif

