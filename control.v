//Author      : Alex Zhang (cgzhangwei@gmail.com)
//Date        : May. 12. 2014
//Description : Implement the control
module control (
clk, 
resetn,
iOp,
iOverflow,
oRegDst,
oRegWr,
oMemtoReg,
oALUOp,
oALUSrc,
oBranch,
oMemRd,
oMemWr
);
input clk; 
input resetn;
input iOp;
input iOverflow;
output oRegDst;
output oRegWr;
output oMemtoReg;
output oALUOp;
output oALUSrc;
output oBranch;
output oMemRd;
output oMemWr;

wire [5:0] iOp;
reg        oRegDst;
reg        oRegWr;
reg        oALUSrc;
reg        oMemRd;
reg        oMemWr;
reg  [1:0] oALUOp;
reg        oBranch;
reg        oMemtoReg;

reg [3:0] state;
parameter RTYPE_INST = 6'h0;
parameter BEQ_INST   = 6'h4;
parameter LW_INST    = 6'h23;
parameter SW_INST    = 6'h2B;
parameter JMP_INST   = 6'h2;

parameter S_INS_LW  = 4'b0000;
parameter S_INS_SW  = 4'b0001;
parameter S_INS_RT  = 4'b0010;
parameter S_INS_BEQ = 4'b0100;
parameter S_INS_JMP = 4'b0110;
parameter S_INS_OTH = 4'b0111;
parameter S_INS_DEC = 4'b1000;

always @(posedge clk or negedge resetn) begin 
    if (~resetn) 
        state <= S_INS_DEC;
    else begin  
        casex (iOp) 
            LW_INST   : state <= S_INS_LW;
            SW_INST   : state <= S_INS_SW;
            RTYPE_INST: state <= S_INS_RT;
            BEQ_INST  : state <= S_INS_BEQ;
            JMP_INST  : state <= S_INS_JMP;
            default   : state <= S_INS_OTH;
        endcase 
    end 
end 
always @(*) begin 
    casex (state) 
        //35 18 17 100 <= lw  $s1, 100($s2) $s1= mem[$s2+100]
        S_INS_LW : begin 
                       oRegDst   = 1'b0;
                       oRegWr    = 1'b1;
                       oMemtoReg = 1'b0;
                       oALUOp    = 2'b00;
                       oALUSrc   = 1'b1;
                       oMemWr    = 1'b0;
                       oMemRd    = 1'b1;
                       oBranch   = 1'b0;
                   end 
        //43 18 17 100 <= sw  $s1, 100($s2) mem[$s2+100]=$s1
        S_INS_SW : begin 
                       oRegDst   = 1'b0;
                       oRegWr    = 1'b0;
                       oMemtoReg = 1'b0;
                       oALUOp    = 2'b00;
                       oALUSrc   = 1'b1;
                       oMemWr    = 1'b1;
                       oMemRd    = 1'b0;
                       oBranch   = 1'b0;
                   end
        //31-26 25-21 20-16 15-11 10-6  5-0
        //Op    Rs    Rt    Rd    Shamt Funct  
        //0     18    19    17    0     32   add $s1, $s2, $s3
        S_INS_RT : begin 
                       oRegDst   = 1'b1;
                       oRegWr    = 1'b1;
                       oMemtoReg = 1'b1;
                       oALUOp    = 2'b10; //ALU depend on the functor
                       oALUSrc   = 1'b0;  //ALU B-branch is from Rt
                       oMemWr    = 1'b0;  //
                       oMemRd    = 1'b0;
                       oBranch   = 1'b0;
                   end 
        //31-26 25-21 20-16 15-0
        //Op    Rs    Rt    Immediater  
        //4     17    18    25     beq $s1, $s2, 100 <= if ($s1==$s2) goto PC+100
        S_INS_BEQ: begin 
                       oRegDst   = 1'b0;
                       oRegWr    = 1'b0;
                       oMemtoReg = 1'b0;
                       oALUOp    = 2'b01; //ALU sub opertion on $s1-$s2
                       oALUSrc   = 1'b0;
                       oMemWr    = 1'b0;
                       oMemRd    = 1'b0;
                       oBranch   = 1'b1;
                   end
        //31-26 25-21 20-16      15-0
        //Op    Rs    Rt         Immediater  
        //2     16    16         2500     jmp 10000 <= jmp to PC+10000
        S_INS_JMP: begin 
                       oRegDst   = 1'b0;
                       oRegWr    = 1'b0;
                       oMemtoReg = 1'b0;
                       oALUOp    = 2'b01; //ALU sub opertion on $s0-$s0
                       oALUSrc   = 1'b0;
                       oMemWr    = 1'b0;
                       oMemRd    = 1'b0;
                       oBranch   = 1'b1;
                   end
        S_INS_OTH: begin 
                       oRegDst   = 1'b0;
                       oRegWr    = 1'b0;
                       oMemtoReg = 1'b0;
                       oALUOp    = 2'b00; 
                       oALUSrc   = 1'b0;
                       oMemWr    = 1'b0;
                       oMemRd    = 1'b0;
                       oBranch   = 1'b0;
                   end
    endcase
end 

endmodule
