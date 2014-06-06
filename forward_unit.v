//Author      : Alex Zhang (cgzhangwei@gmail.com)
//Date        : Jun. 06. 2014
//Description : Implement the forwarding function with Figure 6.32
//              Fix Bug11: Data hazard found in the add.rom
module forward_unit(
iID_EX_ppRs,
iID_EX_ppRt,
iEX_MEM_ppRd,
iMEM_WB_ppRd,
iEX_MEM_ppRegWr,
iMEM_WB_ppRegWr,
oForwardSelE,
oForwardSelF
);
input iID_EX_ppRs;
input iID_EX_ppRt;
input iEX_MEM_ppRd;
input iMEM_WB_ppRd;
input iEX_MEM_ppRegWr;
input iMEM_WB_ppRegWr;
output oForwardSelE;
output oForwardSelF;
wire [`RF_REG_W-1:0]     iID_EX_ppRs;
wire [`RF_REG_W-1:0]     iID_EX_ppRt;
wire [`RF_REG_W-1:0]     iEX_MEM_ppRd;
wire [`RF_REG_W-1:0]     iMEM_WB_ppRd;
wire                     iEX_MEM_ppRegWr;
wire                     iMEM_WB_ppRegWr;
reg  [1:0]               oForwardSelE;
reg  [1:0]               oForwardSelF;

always @(*) begin 
    if (iEX_MEM_ppRegWr && (iEX_MEM_ppRd!=0) && (iEX_MEM_ppRd == iID_EX_ppRs ) )
        oForwardSelE = 2'b10;
    else if (iMEM_WB_ppRegWr && (iMEM_WB_ppRd!=0) && (iEX_MEM_ppRd != iID_EX_ppRs ) && (iMEM_WB_ppRd == iID_EX_ppRs))
        oForwardSelE = 2'b01;
    else 
        oForwardSelE = 2'b00;
    if (iEX_MEM_ppRegWr && (iEX_MEM_ppRd!=0) && (iEX_MEM_ppRd == iID_EX_ppRt ) )
        oForwardSelF = 2'b10;
    else if (iMEM_WB_ppRegWr && (iMEM_WB_ppRd!=0) && (iEX_MEM_ppRd != iID_EX_ppRt ) && (iMEM_WB_ppRd == iID_EX_ppRt))
        oForwardSelF = 2'b01;
    else 
        oForwardSelF = 2'b00;
end 

endmodule 
