`timescale 1ns/1ps
module RAM_single_tb;
parameter DATA_WIDTH = 32;
parameter ADDR_WIDTH = 10; 
parameter DATA_DEPTH = 1024;
parameter MODE = "READ_FIRST";
logic clk = 0;
logic rst_n = 1;
logic wrn = 0;
logic [DATA_WIDTH-1:0]din = 'd0;
logic [DATA_WIDTH-1:0]dout = 'd0;
logic [ADDR_WIDTH-1:0]addr = 'd0;

RAM_single #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_DEPTH(DATA_DEPTH),
    .MODE(MODE)
)
RAM_single_inst(
    .din(din),
    .wrn(wrn),
    .addr(addr),
    .rst_n(rst_n),
    .clk(clk),
    .dout(dout)
);
initial begin
     clk = 1;
    forever #10 clk = ~clk;
end

task automatic rst();
#10 rst_n = 0;
#30 rst_n = 1;
endtask

task automatic wr_drv(input logic [ADDR_WIDTH-1:0]add,input logic [DATA_WIDTH-1:0]data);
@(posedge clk);
addr <= add;
din <= data;
wrn <= 1;
endtask //automatic

task automatic wr(input int start = 0,input int f = 0);
    for(int i = start;i < f;i++) begin
        wr_drv(i,i*i);
    end
    @(posedge clk);
    wrn <= 0;
endtask //automatic

task automatic rd_drv(input logic [ADDR_WIDTH-1:0]add);
@(posedge clk);
addr <= add; 
wrn <= 0;
endtask //automatic

task automatic rd(input int start = 0,input int f = 0);
    for(int i = start;i<f;i++) begin
        rd_drv(i);
    end
endtask //automatic

// task automatic en(input int f);
// integer  i;
//     #10;
//     wrn = 1;
//     for(i = 0;i < f; i = i+1) begin
//        @(posedge clk) begin
//             addr = i;
//             din = din + 1;
//         end
//         end
//     #10;
//     wrn  =0;
//     for(i = 0;i < f; i = i+1) begin
//         @(posedge clk) begin
//             addr = i;
//         end
//     end
// endtask //automatic

initial begin
    #30;
    rst();
    #30;
    wr(0,10);
    rd(0,10);
    wr(0,10);
    rd(0,10);
    #1000;
    $finish;
end
endmodule