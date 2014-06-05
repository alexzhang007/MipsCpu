//Author      : Alex Zhang (cgzhangwei@gmail.com)
//Date        : May. 16. 2014
//Description : Implement the pipelined MIPS CPU with Figure 6.27 w/o Hazards detection and Data stall
//              Fix Bug8: ID and EX stages are misaligned
module cpu(
clk,
resetn
);

input clk;
input resetn;
wire [`ALU_CNTL_OP_W-1 : 0] wOp;
//Declaration for Instruction Fetch pipeline 
reg [`REG_W-1:0]      rPC;
reg [`INST_W-1:0]     iMem[0:`IMEM_SIZE-1]; 
reg [`INST_W-1:0]     rInstFetch;
reg [`REG_W-1:0]      IF_ID_ppPC;          //rPC pipelined register at IF/ID
reg [`INST_W-1:0]     IF_ID_ppInstFetch;   //rInstFetch pipelined register at IF/ID

//Declaration for Instruction Decode pipeline 
wire [`REG_W-1:0]     wRtData;
wire [`REG_W-1:0]     wRsData;
reg  [`REG_W-1:0]     ID_EX_ppPC;
reg  [`RF_REG_W-1:0]  ID_EX_ppRd;
reg  [`RF_REG_W-1:0]  ID_EX_ppRt;
reg  [`RF_REG_W-1:0]  ID_EX_ppRs;
reg  [`REG_W-1:0]     ID_EX_ppRtData;   //wRtData pipelined register at ID/EX
reg  [`REG_W-1:0]     ID_EX_ppRdData;   //wRtData pipelined register at ID/EX
reg  [`REG_W-1:0]     ID_EX_ppRsData;   //wRsData pipelined register at ID/EX
reg  [`REG_W-1:0]     ID_EX_ppImmed;
//Add the pp2 since the control has one extra delay.
reg  [`REG_W-1:0]     ID_EX_pp2PC;
reg  [`RF_REG_W-1:0]  ID_EX_pp2Rd;
reg  [`RF_REG_W-1:0]  ID_EX_pp2Rt;
reg  [`RF_REG_W-1:0]  ID_EX_pp2Rs;
reg  [`REG_W-1:0]     ID_EX_pp2Immed;
wire                  wRegWr;            
reg                   ID_EX_ppRegWr;    //wRegWr pipelined register at ID/EX
wire                  wMemtoReg;
reg                   ID_EX_ppMemtoReg; //wMemtoReg pipelined register at ID/EX
wire                  wMemRd;
reg                   ID_EX_ppMemRd;    //wMemRd pipelined register at ID/EX
wire                  wMemWr;
reg                   ID_EX_ppMemWr;    //wMemWr pipelined register at ID/EX
wire                  wRegDst;  
reg                   ID_EX_ppRegDst;   //wRegDst pipelined register at ID/EX
wire [1:0]            wALUOp;
reg  [1:0]            ID_EX_ppALUOp;    //wALUOp pipelined register at ID/EX
wire                  wALUSrc;
reg                   ID_EX_ppALUSrc;   //wMemWr pipelined register at ID/EX
wire                  wBranch;
reg                   ID_EX_ppBranch;

//Declaration for Execution pipeline 
reg [`INST_W-1:0]     EX_MEM_ppPC;        //rPC pipelined register at EX/MEM 
reg [`INST_W-1:0]     rNextPC;
wire [`INST_W-1:0]    wMuxBOut;
wire [`RF_REG_W-1:0]  wMuxCOut;
wire [`DATA_W-1 : 0]  wALUOut;
wire                  wOverflow;
reg  [`RF_REG_W-1:0]  EX_MEM_ppWrReg;
reg                   EX_MEM_ppZero;
reg  [`DATA_W-1:0]    EX_MEM_ppALUOut;
reg  [`DATA_W-1:0]    EX_MEM_ppRtData;
reg                   EX_MEM_ppMemWr;
reg                   EX_MEM_ppMemRd;
reg                   EX_MEM_ppBranch;
reg                   EX_MEM_ppRegWr;
reg                   EX_MEM_ppMemtoReg;

//Declaration for Memory pipeline 
reg [`RF_REG_W -1:0 ] MEM_WB_ppWrReg; //rWrReg pipelined register at MEM/WB, WrReg and WrData pair
reg                   MEM_WB_ppRegWr; //rRegWr pipelined register at MEM/WB 
wire                  wPCSrc;
wire [`DATA_W-1:0]    wMemData;
reg [`DATA_W-1:0]     MEM_WB_ppMemData;
reg [`DATA_W-1:0]     MEM_WB_ppALUOut;
reg                   MEM_WB_ppRegWr;
reg                   MEM_WB_ppMemtoReg;

//Declaration for Write Back pipeline 
wire [`DATA_W-1:0]    wWrData;

//Function implementation of Instruction Fetech pipeline 
always @(posedge clk or negedge resetn) begin 
    if (~resetn) begin
        rPC               <= 32'b0;
        IF_ID_ppPC        <= 32'b0;
        IF_ID_ppInstFetch <= 32'b0;
    end else begin 
        rPC               <= wPCSrc ? EX_MEM_ppPC: rPC +32'h4 ; //muxTowA
        IF_ID_ppPC        <= rPC +32'h4;
        IF_ID_ppInstFetch <= rInstFetch; 
    end 
end 
always @(rPC) begin
    rInstFetch = iMem[rPC];
end

//Function implementation of Instruction Decode pipeline 
reg_file register_file (
  .clk(clk),
  .resetn(resetn),
  .iReg1(IF_ID_ppInstFetch[25:21]),
  .iReg2(IF_ID_ppInstFetch[20:16]),
  .iWrReg3(MEM_WB_ppWrReg),
  .iRegWr(MEM_WB_ppRegWr),
  .iWrData(wWrData),
  .oReg1(wRsData),
  .oReg2(wRtData)
);
always @(posedge clk or negedge resetn) begin 
    if (~resetn) begin 
        ID_EX_ppPC      <= 32'h0;
        ID_EX_ppRdData  <= 32'h0;
        ID_EX_ppRsData  <= 32'h0;
        ID_EX_ppRtData  <= 32'h0;
        ID_EX_ppRs      <= 5'h0;
        ID_EX_ppRt      <= 5'h0;
        ID_EX_ppRd      <= 5'h0;
        ID_EX_ppImmed   <= 32'h0;
        ID_EX_pp2PC     <= 32'h0;
        ID_EX_pp2Rs     <= 5'h0;
        ID_EX_pp2Rt     <= 5'h0;
        ID_EX_pp2Rd     <= 5'h0;
        ID_EX_pp2Immed  <= 32'h0;

        ID_EX_ppRegWr   <= 1'b0; 
        ID_EX_ppMemtoReg<= 1'b0;
        ID_EX_ppMemRd   <= 1'b0; 
        ID_EX_ppMemWr   <= 1'b0; 
        ID_EX_ppRegDst  <= 1'b0;
        ID_EX_ppALUOp   <= 2'b0; 
        ID_EX_ppALUSrc  <= 1'b0;
        ID_EX_ppBranch  <= 1'b0;
    end else begin 
        ID_EX_ppPC      <= IF_ID_ppPC;
        ID_EX_ppRsData  <= wRsData;
        ID_EX_ppRtData  <= wRtData;
        ID_EX_ppRt      <= IF_ID_ppInstFetch[20:16];
        ID_EX_ppRd      <= IF_ID_ppInstFetch[15:11];
        ID_EX_ppImmed   <= IF_ID_ppInstFetch[15] ? {IF_ID_ppInstFetch[15], 16'hFFFF, IF_ID_ppInstFetch[14:0]}  //neg integer
                                                 : {17'h0, IF_ID_ppInstFetch[14:0]};                           //pos integer
        ID_EX_pp2PC     <= ID_EX_ppPC;
        ID_EX_pp2Rt     <= ID_EX_ppRt;
        ID_EX_pp2Rd     <= ID_EX_ppRd;
        ID_EX_pp2Immed  <= ID_EX_ppImmed;
  
        //Control pipelined bundles
        ID_EX_ppRegWr   <= wRegWr; 
        ID_EX_ppMemtoReg<= wMemtoReg;
        ID_EX_ppMemRd   <= wMemRd; 
        ID_EX_ppMemWr   <= wMemWr; 
        ID_EX_ppRegDst  <= wRegDst;
        ID_EX_ppALUOp   <= wALUOp; 
        ID_EX_ppALUSrc  <= wALUSrc;
        ID_EX_ppBranch  <= wBranch;
    end 
end 

control controlID(
    .clk(clk),
    .resetn(resetn),
    .iOp(IF_ID_ppInstFetch[31:26]),
    .iOverflow(wOverflow),
    .oRegDst(wRegDst),
    .oRegWr(wRegWr),
    .oMemtoReg(wMemtoReg),
    .oALUOp(wALUOp),
    .oALUSrc(wALUSrc),
    .oBranch(wBranch),
    .oMemRd(wMemRd),
    .oMemWr(wMemWr)
);
//Function implementation of Instruction Execute pipeline 
//
always @(ID_EX_pp2PC or ID_EX_pp2Immed) begin 
    rNextPC = ID_EX_pp2PC + {ID_EX_pp2Immed[31], ID_EX_pp2Immed[30:0]<<2, 2'b00};  //Is it right for neg value?
end 
//Fix Bug8: wALUSrc already pipelined once in the controlID
assign wMuxBOut = ID_EX_ppALUSrc ? ID_EX_pp2Immed: ID_EX_ppRtData ;
assign wMuxCOut = ID_EX_ppRegDst ? ID_EX_pp2Rd   : ID_EX_pp2Rt ;

alu_32 alu(
  .iA(ID_EX_ppRsData),
  .iB(wMuxBOut),
  .iOp(wOp),
  .oALU(wALUOut),
  .oZero(wZero),
  .oOverflow(wOverflow),
  .oUnderflow()
);
alu_cntl alu_control(
  .iInstFunct(ID_EX_pp2Immed[5:0]),
  .iALUOp(ID_EX_ppALUOp),
  .oOp(wOp)
);
always @(posedge clk or negedge resetn) begin 
    if (~resetn) begin 
        EX_MEM_ppPC <= 32'b0;
        EX_MEM_ppZero       <= 1'b0;
        EX_MEM_ppALUOut     <= 32'b0;
        EX_MEM_ppRtData     <= 32'b0;
        EX_MEM_ppWrReg      <= 5'b0;
        EX_MEM_ppMemWr      <= 1'b0;
        EX_MEM_ppMemRd      <= 1'b0;
        EX_MEM_ppBranch     <= 1'b0;
        EX_MEM_ppRegWr      <= 1'b0;
        EX_MEM_ppMemtoReg   <= 1'b0;
    end else begin 
        EX_MEM_ppPC         <= rNextPC;
        EX_MEM_ppZero       <= wZero;
        EX_MEM_ppALUOut     <= wALUOut;
        EX_MEM_ppRtData     <= ID_EX_ppRtData;
        EX_MEM_ppWrReg      <= wMuxCOut;
        EX_MEM_ppMemWr      <= ID_EX_ppMemWr;
        EX_MEM_ppMemRd      <= ID_EX_ppMemRd;
        EX_MEM_ppBranch     <= ID_EX_ppBranch;
        EX_MEM_ppRegWr      <= ID_EX_ppRegWr;
        EX_MEM_ppMemtoReg   <= ID_EX_ppMemtoReg;
    end 
end 

//Function implementation of Memory pipeline 
//
assign wPCSrc = EX_MEM_ppZero & EX_MEM_ppBranch;
dmem ram(
  .iAddr(EX_MEM_ppALUOut),
  .iWrData(EX_MEM_ppRtData),
  .iMemWr(EX_MEM_ppMemWr),
  .iMemRd(EX_MEM_ppMemRd),
  .oRdData(wMemData)
);

always @(posedge clk or negedge resetn) begin 
    if (~resetn) begin 
        MEM_WB_ppMemData <= 32'b0;
        MEM_WB_ppALUOut  <= 32'b0;
        MEM_WB_ppRegWr   <= 1'b0;
        MEM_WB_ppMemtoReg<= 1'b0;
        MEM_WB_ppWrReg   <= 5'b0;
    end else begin 
        MEM_WB_ppMemData <= wMemData;
        MEM_WB_ppALUOut  <= EX_MEM_ppALUOut;
        MEM_WB_ppRegWr   <= EX_MEM_ppRegWr;
        MEM_WB_ppMemtoReg<= EX_MEM_ppMemtoReg;
        MEM_WB_ppWrReg   <= EX_MEM_ppWrReg;
    end 
end 
assign wWrData = MEM_WB_ppMemtoReg ? MEM_WB_ppALUOut: MEM_WB_ppMemData ;

endmodule  
