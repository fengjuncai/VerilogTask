`timescale 1ns / 1ps
module FIFO_A_tb;
    parameter DATA_DEPTH = 1024;
    parameter DATA_WIDTH = 32;
    logic                  wr_clk = 0;
    logic                  rd_clk = 0;
    logic                  wr_rstn = 1;
    logic                  rd_rstn = 1;
    logic                  wen = 0;
    logic                  ren = 0;
    logic [DATA_WIDTH-1:0] din = 'd0;
    logic [DATA_WIDTH-1:0] dout;
    logic                  full;
    logic                  empty;

    fifo_a #(
        .DATA_DEPTH(DATA_DEPTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) inst (
        .wr_clk (wr_clk),
        .rd_clk (rd_clk),
        .wr_rstn(wr_rstn),
        .rd_rstn(rd_rstn),
        .wen    (wen),
        .ren    (ren),
        .din    (din),
        .dout   (dout),
        .full   (full),
        .empty  (empty)
    );

    initial begin
        forever begin
            #5 wr_clk = ~wr_clk;
        end
    end
    initial begin
        forever begin
            #10 rd_clk = ~rd_clk;
        end
    end
    task automatic rst();
        #20 wr_rstn = 0;
        rd_rstn = 0;
        #20 wr_rstn = 1;
        rd_rstn = 1;
    endtask  //automatic
    task automatic wr_en();
        wen = 1;
        ren = 0;
        repeat (1200) begin
            @(negedge wr_clk);
            din = {$random};
        end

    endtask  //automatic
    task automatic rd_en();
        wen = 0;
        ren = 1;
        repeat (1200) begin
            @(negedge rd_clk);
            din = {$random};
        end
    endtask  //automatic
    task automatic wrrd_en();
        wen = 1;
        ren = 1;
        repeat (1200) begin
            @(negedge wr_clk);
            din = {$random};
        end
    endtask  //automatic

    initial begin
        rst();
        #20 wr_en();
        #50;
        rd_en();
        #50;
        wrrd_en();
        #500;
        //$finish;
    end
endmodule
