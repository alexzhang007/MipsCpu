//Author      : Alex Zhang (cgzhangwei@gmail.com)
//Date        : May. 11. 2014
//Description : Implement the ALU with Figure 5-39. 
module alu_32 (
iA, 
iB,
iOp,
oALU,
oZero,
oOverflow,
oUnderflow
);
input iA;
input iB;
input iOp;
output oALU;
output oZero;
output oOverflow;
output oUnderflow;

parameter OP_ADD = 6'h02;
parameter OP_SUB = 6'h06;
parameter OP_AND = 6'h00;
parameter OP_OR  = 6'h01;
parameter OP_SLT = 6'h07;
parameter OP_LW  = 6'h02; //Load word has to add the address. 
parameter OP_SW  = 6'h02;
parameter OP_BEQ = 6'h06;

wire [`DATA_W-1 : 0] iA;
wire [`DATA_W-1 : 0] iB;
wire [`ALU_CNTL_OP_W-1 : 0] iOp;
reg                 oZero;
reg                 oOverflow;
reg                 oUnderflow;
reg [`DATA_W-1 : 0] oALU;


always @(oALU) 
     oZero = (oALU == 32'h0) ? 1'b1 : 1'b0; 

always @(iA or iB or iOp) begin 
     case (iOp) 
         OP_SW,  OP_LW, OP_ADD : {oOverflow , oALU} = iA + iB;
         OP_BEQ, OP_SUB : {oUnderflow, oALU} = iA - iB;
         OP_AND : {            oALU} = iA & iB;
         OP_OR  : {            oALU} = iA | iB;
         OP_SLT : {            oALU} = iA < iB ? 32'b1 : 32'b0 ;
         default :{            oALU} = 32'h0;
     endcase
end 

endmodule 
