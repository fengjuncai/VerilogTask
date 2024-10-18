`timescale 1ns/1ps
module dual_port_tb;
logic clka = 0;
logic wea = 0;
logic clkb = 0;
logic web = 0;
logic [9:0]addra = 'd0;
logic [9:0]addrb = 'd0;
logic [31:0]dina = 'd0;
logic [31:0]douta = 'd0;
logic [31:0]dinb = 'd0;
logic [31:0]doutb = 'd0;

blk_mem_gen_2 your_instance_name (
  .clka(clka),    // input wire clka
  .wea(wea),      // input wire [0 : 0] wea
  .addra(addra),  // input wire [9 : 0] addra
  .dina(dina),    // input wire [31 : 0] dina
  .douta(douta),  // output wire [31 : 0] douta
  .clkb(clkb),    // input wire clkb
  .web(web),      // input wire [0 : 0] web
  .addrb(addrb),  // input wire [9 : 0] addrb
  .dinb(dinb),    // input wire [31 : 0] dinb
  .doutb(doutb)  // output wire [31 : 0] doutb
);

initial begin
    #10 clka = 1;
    forever #10 clka = ~clka;
end

initial begin
    #20 clkb = 1;
    forever #10 clkb = ~clkb;
end

task automatic wr_drva(input logic [9:0]addr,input logic [31:0]wr_data);
    @(posedge clka);
    addra <= addr;
    dina <= wr_data;
    wea <= 1;
endtask //automatic

task automatic wra(input int cnt);
int i;
for(i = 0;i < cnt;i++) begin
    wr_drva(i,i*i);
end
@(posedge clka);
wea <= 0;
endtask //automatic

task automatic rd_drva(input logic [9:0]addr);
    @(posedge clka);
    addra <= addr;
    wea <= 0;
endtask //automatic

task automatic rda(input int cnt);
    int i;
    for(i= 0;i < cnt;i++) begin
        rd_drva(i);
    end
endtask //automatic

task automatic wr_drvb(input logic [9:0]addr,input logic [31:0]wr_data);
    @(posedge clkb);
    addrb <= addr;
    dinb <= wr_data;
    web <= 1;
endtask //automatic

task automatic wrb(input int cnt);
int i;
for(i = 0;i < cnt;i++) begin
    wr_drvb(i,i*i);
end
@(posedge clkb);
web <= 0;
endtask //automatic

task automatic rd_drvb(input logic [9:0]addr);
    @(posedge clkb);
    addrb <= addr;
    web <= 0;
endtask //automatic

task automatic rdb(input int cnt);
    int i;
    for(i= 0;i < cnt;i++) begin
        rd_drvb(i);
    end
endtask //automatic

task automatic wrb1(input int cnt);
int i;
for(i = 10;i < 'd10 + cnt;i++) begin
    wr_drvb(i,i*i);
end
@(posedge clkb);
web <= 0;
endtask //automatic

task automatic rdb1(input int cnt);
    int i;
    for(i= 10;i < 'd10 + cnt;i++) begin
        rd_drvb(i);
    end
endtask //automatic


// initial begin
//     #100;
//     wra(50);
//     #100;
//     rdb(50);
//     #1000;
//     $finish;
// end//功能 A写B读

// initial begin
//     #100;
//     wra(10);
//     #100;
//     rda(10);
// end//（A写A读，B写B读，体现两个端口的独立性）

// initial begin
//     #100;
//     wrb1(10);
//     #100;
//     rdb1(10);
//     #1000;
//     $finish;
// end


initial begin
    #100;
    wra(10);
    rda(10);
    wra(10);
    rda(10);
end//（A写A读，B写B读，体现两个端口的独立性）

initial begin
    #100;
    wrb1(10);
    rdb1(10);
    wrb1(10);
    rdb1(10);
    #1000;
    $finish;
end
endmodule