`timescale 1ns / 1ps
module tb_RAM_simple_dual ();

    // 参数定义，与待测试模块一�???
    parameter DATA_WIDTH = 32;
    parameter DATA_DEPTH = 1024;
    parameter ADDR_WIDTH = 10;
    parameter RAM_STYLE_VAL = "block";  //RAM的实现风格block/distributed
    parameter MODE = "WRITE_FIRST";  //读写地址冲突

    // 信号定义
    logic                  clk = 0;
    logic                  rst_n = 1;
    logic                  wen = 0;
    // logic ren = 0;
    logic [ADDR_WIDTH-1:0] addra = 'd0;
    logic [ADDR_WIDTH-1:0] addrb = 'd0;
    logic [DATA_WIDTH-1:0] din = 'd0;
    logic [DATA_WIDTH-1:0] dout = 'd0;

    // 被测试模块实例化
    RAM_simple_dual #(
        .DATA_WIDTH(DATA_WIDTH),
        .DATA_DEPTH(DATA_DEPTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .RAM_STYLE_VAL(RAM_STYLE_VAL),
        .MODE(MODE)
    ) dut (
        .clk  (clk),
        .rst_n(rst_n),
        .wen  (wen),
        .addra(addra),
        .din  (din),
        // .ren(ren),
        .addrb(addrb),
        .dout (dout)
    );

    // 时钟生成
    initial begin
        clk = 0;
        forever #10 clk = ~clk;  // �??10个时间单位翻转一次时�???
    end

    task automatic rst();
        #20;
        rst_n = 0;
        #20;
        rst_n = 1;
    endtask  //automatic

    task automatic wr_drv(input logic [ADDR_WIDTH-1:0] addr, input logic [DATA_WIDTH-1:0] data);
        @(posedge clk);
        wen   <= 1;
        addra <= addr;
        addrb <= addr;
        din   <= data;
    endtask  //automatic

    task automatic wr(input int start = 0, input int cnt);
        for (int i = start; i < cnt; i++) begin
            wr_drv(i, i * i);
        end
        @(posedge clk);
        wen <= 0;
    endtask  //automatic

    task automatic rd_drv(input logic [ADDR_WIDTH-1:0] addr);
        @(posedge clk);
        addrb <= addr;
        // wen   <= 0;
    endtask  //automatic

    task automatic rd(input int start, input int cnt);
        for (int i = start; i < cnt; i++) begin
            rd_drv(i);
        end
    endtask  //automatic

    task automatic AWBR(input int start, input int cnt);
        for (int i = start; i < cnt; i++) begin
            wr_drv(i, i * i);
            rd_drv(i);
        end
    endtask  //automatic

    // initial begin
    //     rst();
    //     #100;
    //     // wr(0,10);
    //     // rd(0,10);
    //     // wr(0,10);
    //     // rd(0,10);
    //     AWBR(0,10);
    //     #1000;
    //     $finish;
    // end

    // initial begin
    //     rst();
    //     #100;
    //     wr(0,10);
    //     rd(0,10);
    //     wr(0,10);
    //     rd(0,10);
    //     #1000;
    //     $finish;
    // end

    initial begin
        rst();
        #100;
        wr(0, 20);
        #100;
    end
    initial begin
        #1000;
        wr(0, 10);
        #1000;
        $finish;
    end
    initial begin
        #1000;
        rd(10, 20);
        #1000;
        $finish;
    end
endmodule
