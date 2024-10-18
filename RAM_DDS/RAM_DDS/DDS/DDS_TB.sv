`timescale 1ns / 1ps
module DDS_TB;
    parameter WAVE1 = "TRI";
    parameter WAVE2 = "SIN";
    parameter WAVE3 = "SQU";
    parameter DATA_DEPTH = 3072;
    parameter DATA_WIDTH = 32;
    parameter ADDR_WIDTH = 10;
    logic                  en = 0;
    logic                  clk = 0;
    logic                  rst_n = 1;
    logic [ADDR_WIDTH-1:0] phase_start1 = 'd0;
    logic [           3:0] step1 = 'd0;
    logic [DATA_WIDTH-1:0] dout1;
    logic [ADDR_WIDTH-1:0] phase_start2 = 'd0;
    logic [           3:0] step2 = 'd0;
    logic [DATA_WIDTH-1:0] dout2;
    logic [ADDR_WIDTH-1:0] phase_start3 = 'd0;
    logic [           3:0] step3 = 'd0;
    logic [DATA_WIDTH-1:0] dout3;

    DDS #(
        .WAVE(WAVE1),
        .DATA_DEPTH(DATA_DEPTH),
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) dds1 (
        .clk        (clk),
        .rst_n      (rst_n),
        .en         (en),
        .phase_start(phase_start1),
        .step       (step1),
        .dout       (dout1)
    );

    DDS #(
        .WAVE(WAVE2),
        .DATA_DEPTH(DATA_DEPTH),
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) dds2 (
        .clk        (clk),
        .rst_n      (rst_n),
        .en         (en),
        .phase_start(phase_start2),
        .step       (step2),
        .dout       (dout2)
    );

    DDS #(
        .WAVE(WAVE3),
        .DATA_DEPTH(DATA_DEPTH),
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) dds3 (
        .clk        (clk),
        .rst_n      (rst_n),
        .en         (en),
        .phase_start(phase_start3),
        .step       (step3),
        .dout       (dout3)
    );

    initial begin
        #20 clk = 1;
        forever #10 clk = ~clk;
    end

    task automatic rst();
        #20;
        rst_n = 0;
        #30;
        rst_n = 1;
    endtask  //automatic

    task automatic dds_init();
        @(posedge clk);
        phase_start1 = 120;
        step1        = 1;

        phase_start2 = 250;
        step2        = 2;

        phase_start3 = 360;
        step3        = 4;

    endtask  //automatic

    initial begin
        #50;
        en = 1;
        #30;
        dds_init();
        #20;
        rst();
        #1000;
        $finish;
    end
endmodule
