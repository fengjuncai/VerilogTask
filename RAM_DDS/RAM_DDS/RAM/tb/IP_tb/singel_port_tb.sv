`timescale 1ns/1ps
module singel_port_ram_tb;
logic clk = 0;
logic wea = 0; // wea=1表示写入，wea=0表示读取
logic [9:0] addr = 'd0;  // addr 是 10 位宽的地址，总共支持 1024 个地址
logic [31:0] wr_data = 'd0; // 写入的数据为 32 位宽，初始化为0
logic [31:0] re_data = 'd0; // 读取的数据


initial begin
    clk=0;
    #10;
    forever begin
        #10 clk=~clk;
    end
end//时钟生成

task automatic rd_drv(input logic [9:0] r_addr);
    @(posedge clk);
    addr <= r_addr;
    wea <= 1'b0; // 读操作
endtask//读操作的驱动任务


task automatic rd_data_task(input int cnt);
    for (int i = 0; i < cnt; i++ ) begin
        rd_drv(i);
    end
    @(posedge clk);
    wea <= 1'b1;
endtask//多次读操作任务

task automatic wr_drv(input logic [9:0] w_addr, input logic [31:0] w_data);
    @(posedge clk);
    addr <= w_addr;
    wr_data <= w_data;
    wea <= 1'b1; // 写操作
endtask//写操作驱动任务


task automatic wr_data_task(input int cnt);
    for (int i = 0; i < cnt; i++ ) begin
        wr_drv(i, i * i); // 将i^2写入地址i
    end
    @(posedge clk);
    wea <= 1'b0; // 停止写操作
endtask//多次写操作


blk_mem_gen_0 ram_inst (
  .clka(clk),    // input wire clka
  .wea(wea),      // input wire [0 : 0] wea
  .addra(addr),  // input wire [9 : 0] addra
  .dina(wr_data),    // input wire [31 : 0] dina
  .douta(re_data)  // output wire [31 : 0] douta
);
 

// initial begin
//     #100; // 等待 100ns 开始操作
//     wr_data_task(32);   // 写操作，写入 32 个地址
//     rd_data_task(32);   // 读操作，读取 32 个地址
//     #20 $finish(); // 结束仿真
// end//功能

initial begin
    #100;
    wr_data_task(10);
    rd_data_task(10);
    wr_data_task(10);
    rd_data_task(10);
    #1000;
    $finish;
end


endmodule