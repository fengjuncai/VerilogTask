`timescale  1ns/1ps
module RAM_dual_tb;
parameter DATA_DEPTH = 1024;
parameter DATA_WIDTH = 32;
parameter ADDR_WIDTH = 10;
parameter RAM_STYLE_VAL = "block";
parameter MODEA = "NO CHANGE";
parameter MODEB = "NO CHANGE";
logic clka = 0;
logic clkb = 0;
logic rst_n = 1;
logic wea = 0;
// logic rea = 0;
logic web = 0;
// logic reb = 0;
logic [DATA_WIDTH-1:0] dina = 'd0;
logic [DATA_WIDTH-1:0] douta = 'd0;
logic [DATA_WIDTH-1:0] dinb = 'd0;
logic [DATA_WIDTH-1:0] doutb = 'd0;
logic [ADDR_WIDTH-1:0] addra = 'd0;
logic [ADDR_WIDTH-1:0] addrb = 'd0;

initial begin
    #10 clka = 1;
    forever begin
        #10 clka = ~clka;
    end
end

initial begin
    #20 clkb = 1;
    forever begin
        #10 clkb = ~clkb;
    end
end
RAM_dual #(
    .DATA_DEPTH(DATA_DEPTH),
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH),
    .RAM_STYLE_VAL(RAM_STYLE_VAL),
    .MODEA(MODEA),
    .MODEB(MODEB)
)INST(
    .clka(clka),
    .clkb(clkb),
    .rst_n(rst_n),
    .wea(wea),
    // .rea(rea),
    .web(web),
    // .reb(reb),
    .dina(dina),
    .dinb(dinb),
    .addra(addra),
    .addrb(addrb),
    .douta(douta),
    .doutb(doutb)
);

task automatic rst();
    #30;
    rst_n = 0; 
    #30;
    rst_n = 1;
endtask //automatic

task automatic wr_drva(input logic [ADDR_WIDTH-1:0]addr,input logic [DATA_WIDTH-1:0]data);
    @(posedge clka);
    wea <= 1;
    addra <= addr;
    dina <= data;
endtask //automatic a端口写驱�?

task automatic wra(input int start,input int cnt);
for(int i = start;i < cnt;i++) begin
    wr_drva(i,i*5);
end
@(posedge clka);
wea <= 0;
endtask //automatic a端口写入

task automatic rd_drva(input logic [ADDR_WIDTH-1:0]addr);
    @(posedge clka);
    wea <= 0;
    addra <= addr;
endtask //automatic a端口读驱�?

task automatic rda(input int start,input int cnt);
    for(int i = start;i < cnt;i++) begin
        rd_drva(i);
    end
endtask //automatic a端口读入

task automatic wr_drvb(input logic [ADDR_WIDTH-1:0]addr,input logic [DATA_WIDTH-1:0]data);
    @(posedge clkb);
    web <= 1;
    addrb <= addr;
    dinb <= data;
endtask //automatic b端口写驱�?

task automatic wrb(input int start,input int cnt);
for(int i = start;i < cnt;i++) begin
    wr_drvb(i,i*i);
end
@(posedge clkb);
web <= 0;
endtask //automatic b端口写入

task automatic rd_drvb(input logic [ADDR_WIDTH-1:0]addr);
    @(posedge clkb);
    web <= 0;
    addrb <= addr;
endtask //automatic b端口读驱动

task automatic rdb(input int start,input int cnt);
    for(int i = start;i < cnt;i++) begin
        rd_drvb(i);
    end
endtask //automatic b端口读入

task automatic wrab_drv(input logic [ADDR_WIDTH-1:0]addr,input logic [DATA_WIDTH-1:0]data);
    @(posedge clka);
    wea <= 1;
    addra <= addr;
    addrb <= addr;
    dina <= data;
endtask //automatic a端口写驱�?

task automatic wrab(input int start,input int cnt);
for(int i = start;i < cnt;i++) begin
    wrab_drv(i,i*5);
end
@(posedge clka);
wea <= 0;
endtask //automatic a端口写入
// initial begin
//     rst();
//     #30;
//     wrab(0,10);
//     rdb(0,10);
//     wrab(0,10);
//     rdb(0,10);
//     #1000;
//     $finish;
// end

initial begin
    #100;
    rst();
    #30;
    wra(0,10);
    rda(0,10);
    wra(0,10);
    rda(0,10);
    #1000;
    $finish;
end

initial begin
    #100;
    rst();
    #30;
    wrb(11,20);
    rdb(11,20);
    wrb(11,20);
    rdb(11,20);
    #1000;
    $finish;
end

endmodule