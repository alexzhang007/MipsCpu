//Author      : Alex Zhang (cgzhangwei@gmail.com)
//Date        : Jun. 09. 2014
//Description : Implement the hazard detection function with Figure 6.36
//              Fix Bug14: Data hazard and stall the pipeline
module hazard_unit (
iID_EX_ppMemRd,
iID_EX_ppRt,
iIF_ID_ppRs,
iIF_ID_ppRt,
oPCWr,
oIFDWr,
oHazard
);

input  iID_EX_ppMemRd;
input  iID_EX_ppRt;
input  iIF_ID_ppRs;
input  iIF_ID_ppRt;
output oPCWr;
output oIFDWr;
output oHazard;
wire [`RF_REG_W-1:0] iID_EX_ppRt;
wire [`RF_REG_W-1:0] iIF_ID_ppRt;
wire [`RF_REG_W-1:0] iIF_ID_ppRs;
reg                  oPCWr;
reg                  oIFDWr;
reg                  oHazard;

always @(*) begin 
    if (iID_EX_ppMemRd && ((iID_EX_ppRt==iIF_ID_ppRs) || (iID_EX_ppRt==iIF_ID_ppRt))) begin 
        oPCWr   = 1'b1;
        oHazard = 1'b1;
        oIFDWr  = 1'b1;
    end else begin 
        oPCWr   = 1'b0;
        oHazard = 1'b0;
        oIFDWr  = 1'b0;
    end
end 

endmodule 
