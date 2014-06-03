//Author      : Alex Zhang (cgzhangwei@gmail.com)
//Date        : May. 12. 2014
//Description : Implement the ALU control. Funct code is at Figure 2.20
module alu_cntl (
iInstFunct,
iALUOp,
oOp
);
input iInstFunct;
input iALUOp;
output oOp;
wire [5:0]                  iInstFunct;
wire [1:0]                  iALUOp;
reg  [`ALU_CNTL_OP_W-1 : 0] oOp;

parameter ALUOP_ADD = 6'h22;
parameter ALUOP_SUB = 6'h26;
parameter ALUOP_AND = 6'h24;
parameter ALUOP_OR  = 6'h25;
parameter ALUOP_SLT = 6'h2A;
parameter ALUOP_BEQ = 6'h16;
parameter ALUOP_LW  = 6'h00;
parameter ALUOP_SW  = 6'h10;
always @(iInstFunct or iALUOp) begin 
    casex ({iALUOp, iInstFunct}) 
       8'b00?????? : oOp = 6'h02; //Add operation  
       8'b01?????? : oOp = 6'h06; //Substract operation
       8'b10010000 : oOp = 6'h02; //R-format Add 
       8'b10010010 : oOp = 6'h06; //R-format Sub
       8'b10010100 : oOp = 6'h00; //R-format And
       8'b10010101 : oOp = 6'h01; //R-format Or
       8'b10011010 : oOp = 6'h07; //R-format Slt
       default : $display("Error encoding in alu_cntl");
    endcase
end 
endmodule 
