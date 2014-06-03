//Author      : Alex Zhang (cgzhangwei@gmail.com)
//Date        : May. 11. 2014
//Description : Implement the data memory 
module dmem (
iAddr,
iWrData,
iMemWr,
iMemRd,
oRdData
);
input iAddr;
input iWrData;
input iMemWr;
input iMemRd;
output oRdData;

wire [`ADDR_W-1:0] iAddr;
wire [`DATA_W-1:0] iWrData;             
reg  [`DATA_W-1:0] oRdData;

reg[`DATA_W-1:0] mem[0:`MEM_SIZE-1]; //16K

always @(iAddr or iMemWr or iMemRd) begin 
    case ({iMemWr, iMemRd})
        2'b01 : oRdData = mem[iAddr];
        2'b10 : mem[iAddr] = iWrData;
        2'b11 : $display ("Error: memory write and read assert simultaneously.");
    endcase 
end 

endmodule 
