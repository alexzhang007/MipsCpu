//Author      : Alex Zhang (cgzhangwei@gmail.com)
//Date        : Jun. 04. 2014
//Description : Create the testbench
//              Fix Bug7: Loading the register_file with 0 data. Sequential logic should be used in that block. But i notice that when computer is sleeping, resuming can call back the original data. So i try to use the loading. 
module test;
reg clk;
reg resetn;
event start_sim_evt;
event end_sim_evt;

cpu  MIPS_CPU(
  .clk(clk),
  .resetn(resetn)
);
initial begin 
    basic;
end 
initial begin 
    $fsdbDumpfile("./out/mips_cpu.fsdb");
    $fsdbDumpvars(0, test);
end 

always @(posedge clk) begin 
    $fsdbDumpMem(MIPS_CPU.iMem);
    $fsdbDumpMem(MIPS_CPU.ram.dMem);
    $fsdbDumpMem(MIPS_CPU.register_file.rMem);
end 

task basic ;
    begin 
        $display("MIPS-RISC32 1.0: This is the basic sanity test.");
        #1;
        $display("Loading program memory wth %s", "add.rom");
        $readmemh("bug14.rom",MIPS_CPU.iMem );
        $readmemh("add.drom",MIPS_CPU.ram.dMem );
        $readmemh("reg.rom",MIPS_CPU.register_file.rMem );
        fork
            drive_clock;
            reset_unit;
            drive_sim;
            monitor_sim;
        join 
    end 
endtask 
task monitor_sim;
   begin 
   @(end_sim_evt);
   #10;
   $display("Test End");
   $finish;
   end 
endtask
task reset_unit;
    begin 
        #5;
        resetn = 1;
        #10;
        resetn = 0;
        #20;
        resetn = 1;
        ->start_sim_evt;
        $display("Reset is done");
        end
endtask 
task  drive_clock;
    begin 
        clk = 0;
        forever begin 
        #5 clk = ~clk;
        end 
    end 
endtask
task  drive_sim;
    @(start_sim_evt);
   
    @(posedge clk);
    //        0    1     2   3    4    5    6     7
    //Same exp, overflow, unsigned A,B, Add
    repeat (100) @(posedge clk);
    ->end_sim_evt;
endtask 

endmodule 
