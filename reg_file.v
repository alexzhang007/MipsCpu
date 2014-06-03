//Author      : Alex Zhang (cgzhangwei@gmail.com)
//Date        : May. 11. 2014
//Description : Implement the registers file
module reg_file (
iReg1,
iReg2,
iWrReg3,
iRegWr,
iWrData,
oReg1,
oReg2
);
input iReg1;
input iReg2;
input iWrReg3;
input iWrData;
input iRegWr;
output oReg1;
output oReg2;

reg [`DATA_W -1:0] oReg1;
reg [`DATA_W -1:0] oReg2;

reg [`DATA_W -1:0] general_regs[0:`RF_REG_NUM-1];

always @(iReg1 or iReg2 or iWrReg3 or iRegWr) begin 
      if (~iRegWr) begin //Read register
          oReg1 = general_regs[iReg1];
          oReg2 = general_regs[iReg2];
      end else begin //Write register
          general_regs[iWrReg3] = iWrData;
      end 
end 
endmodule 
