`timescale 1ns/1ps
module simple_dual_pora_tb;
logic clka = 0;
logic clkb = 0;
logic wea = 0;
logic [9:0]addra = 'd0;
logic [9:0]addrb = 'd0;
logic [31:0]dina = 'd0;
logic [31:0]doutb = 'd0;

blk_mem_gen_1 your_instance_name (
  .clka(clka),    // input wire clka
  .wea(wea),      // input wire [0 : 0] wea
  .addra(addra),  // input wire [9 : 0] addra
  .dina(dina),    // input wire [31 : 0] dina
  .clkb(clkb),    // input wire clkb
  .addrb(addrb),  // input wire [9 : 0] addrb
  .doutb(doutb)  // output wire [31 : 0] doutb
);

initial begin
    #10 clka = 1;
    forever #10 clka = ~clka; 
end

initial begin
    #10 clkb = 1;
    forever #10 clkb = ~clkb;
end

task automatic wr_drv(input logic [9:0]addr,input logic [31:0]wr_data);//写操作
    @(posedge clka);
    addra <= addr;
    addrb <= addr;
    dina <= wr_data;
    wea <= 1;
endtask //automatic  

task automatic wr_drv1(input logic [9:0]addr,input logic [31:0]wr_data);//写操作
    @(posedge clka);
    addra <= addr;
    addrb <= 'd10 + addr;
    dina <= wr_data;
    wea <= 1;
endtask //automatic  


task automatic wr(input int cnt);
    int i;
    for(i = 0; i < cnt; i++) begin
        wr_drv(i,i*i);
    end
    @(posedge clka);
    wea <= 0;
endtask //automatic

task automatic wr1(input int cnt);
    int i;
    for(i = 0; i < cnt; i++) begin
        wr_drv(i,i*2);
    end
    @(posedge clka);
    wea <= 0;
endtask //automatic  换一个din

task automatic wr2(input int cnt);
    int i;
    for(i = 0; i < cnt; i++) begin
        wr_drv1(i,i*i);
    end
    @(posedge clka);
    wea <= 0;
endtask //automatic


task automatic rd_drv(input [9:0]addr);//读操作
    @(posedge clkb);
    addrb <= addr;
    wea <= 0;
endtask //automatic

task automatic rd(input int cnt);
    int i;
    for(i = 0;i < cnt; i++) begin
        rd_drv(i);
    end
    @(posedge clkb);
    wea <= 1'b1;
endtask //automatic

task automatic wr_rd(input int cnt);
    for(int i = 0;i < cnt;i++) begin
        
    end
endtask //automatic


// initial begin
//     #100;
//     wr(10);
//     rd(10);
//     wr1(10);
//     rd(10);
//     #1000;
//     $finish;
// end//读写冲突

initial begin
    #100;
    wr(20);
    #100;
    wr2(10);
    #1000;
    $finish;
end//功能展示，同时A读B写


endmodule