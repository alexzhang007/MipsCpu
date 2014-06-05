//Author      : Alex Zhang (cgzhangwei@gmail.com)
//Date        : May. 11. 2014
//Description : Implement the registers file
//              Fix Bug7: alu_32's input data have X when executing load instruction
//              Fix Bug8: ID and EX stages are misaligned
module reg_file (
clk,
resetn,
iReg1,
iReg2,
iWrReg3,
iRegWr,
iWrData,
oReg1,
oReg2
);
input clk;
input resetn;
input iReg1;
input iReg2;
input iWrReg3;
input iWrData;
input iRegWr;
output oReg1;
output oReg2;

reg [`DATA_W -1:0]   oReg1;
reg [`DATA_W -1:0]   oReg2;
wire [`RF_REG_W-1:0] iReg1;
wire [`RF_REG_W-1:0] iReg2;
wire [`RF_REG_W-1:0] iWrReg3;
wire [`DATA_W-1:0]   iWrData;
wire                 iRegWr;

reg [`DATA_W -1:0] rMem[0:`RF_REG_NUM-1];
always @(posedge clk or negedge resetn)  begin 
    if (~resetn) begin 
        oReg1 <= 32'b0;
        oReg2 <= 32'b0;
    end else begin 
        if (iRegWr) begin 
            rMem[iWrReg3] <= iWrData;
        end
        oReg1 <= rMem[iReg1];
        oReg2 <= rMem[iReg2];
    end 
end
endmodule 
