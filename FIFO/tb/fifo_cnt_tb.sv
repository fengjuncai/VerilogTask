`timescale 1ns/1ps	//时间单位/精度
module fifo_cnt_tb;
    parameter DATA_WIDTH = 32;
    parameter DATA_DEPTH = 512;
    parameter MODE = "FWFT";
    logic                  clk = 0;
    logic                  rst_n = 1;
    logic [DATA_WIDTH-1:0] din = 'd0;
    logic                  wen = 0;
    logic                  ren = 0;
    logic                  full = 0;
    logic                  empty = 1;
    logic [DATA_WIDTH-1:0] dout ;

    fifo_cnt #(
        .DATA_WIDTH(DATA_WIDTH),
        .DATA_DEPTH(DATA_DEPTH),
        .MODE(MODE)
    ) inst (
        .clk  (clk),
        .rst_n(rst_n),
        .din  (din),
        .wen  (wen),
        .ren  (ren),
        .full (full),
        .empty(empty),
        .dout (dout)
    );

    initial begin
        #10 clk = 1;
        forever #10 clk = ~clk;
    end

    task automatic rst();
        #30;
        rst_n = 0;
        #30;
        rst_n = 1;
    endtask  //automatic

    task automatic drv_w(input logic [DATA_WIDTH-1:0] data);
        @(posedge clk);
        wen <= 1;
        din <= data;
    endtask  //automatic 

    task automatic wr(input int start, input int finish);
        for (int i = start; i < finish; i++) begin
            drv_w(i * 5+5);
        end
        @(posedge clk);
        wen <= 0;
    endtask  //automatic 

    task automatic drv_r();
        @(posedge clk);
        ren <= 1;
    endtask  //automatic 

    task automatic rd(input int start, input int finish);
        for (int i = start; i < finish; i++) begin
            drv_r();
        end
        @(posedge clk);
        ren <= 0;
    endtask  //automatic 


    // initial begin
    //     #20;
    //     rst();
    //     #20;
    //     wr(0, 512);
    //     #20;
    //     rd(0, 512);
    //     #1000;
    //     $finish;
    // end

    initial begin
        #20;
        rst();
        // #20;
        // wr(0, 10);
    end
    initial begin
        #400;
        wr(0, 512);
        #1000;
        $finish;
    end
    initial begin
        #480;
        rd(0, 512);
    end
endmodule