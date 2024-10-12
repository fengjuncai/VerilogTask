`timescale 1ns / 1ps

module rx_clk_tb;
    parameter CLK_FREQUENCE = 50_000_000;
    parameter BAUD_RATE = 9600;

    logic clk = 1'b1;
    logic rst_n = 1'b1;
    logic rx_start = 1'b0;
    logic rx_done = 1'b0;
    logic sample_clk = 1'b0;//输入以及参数赋初值

    rx_clk #(
        .CLK_FREQUENCE(CLK_FREQUENCE),
        .BAUD_RATE(BAUD_RATE)
    ) rx_clk_inst (
        .clk       (clk),
        .rst_n     (rst_n),
        .rx_start  (rx_start),
        .rx_done   (rx_done),
        .sample_clk(sample_clk)
    );//实例化模块

    initial begin
        clk = 1'b1;
        forever begin
            #10 clk = ~clk;//与FREQUENCE一致
        end
    end//设定时钟

    task automatic reset_mod();
        #20;
        rst_n = 1'b0;
        #20;
        rst_n = 1'b1;
        #30;
    endtask  //automatic，rst开始时有一个复位

    task automatic sig_gen(input int lag);
        @(posedge clk);
        rx_start <= 1'b1;
        @(posedge clk);
        rx_start <= 1'b0;
        #lag;
        @(posedge clk);
        rx_done <= 1'b1;
        @(posedge clk) rx_done <= 1'b0;
    endtask  //automatic

    initial begin
        reset_mod();
        #300;
        sig_gen(400);
        // #500 rx_done  = 1'b1;
        #600;
        $finish;

    end




endmodule
