module fifo_a #(
    parameter DATA_DEPTH = 1024,
    parameter DATA_WIDTH = 32
) (
    input  logic                  wr_clk,
    input  logic                  rd_clk,
    input  logic                  wr_rstn,
    input  logic                  rd_rstn,
    input  logic                  wen,
    input  logic                  ren,
    input  logic [DATA_WIDTH-1:0] din,
    output logic [DATA_WIDTH-1:0] dout,
    output logic                  full,
    output logic                  empty
);
    logic [  $clog2(DATA_DEPTH):0] wr_pointer;  //多一位表示指针是否在同一圈
    logic [$clog2(DATA_DEPTH)-1:0] wr_addr;
    logic [  $clog2(DATA_DEPTH):0] wr_gray;
    logic [  $clog2(DATA_DEPTH):0] wr_gray1;
    logic [  $clog2(DATA_DEPTH):0] wr_gray2;
    logic [  $clog2(DATA_DEPTH):0] rd_pointer;
    logic [$clog2(DATA_DEPTH)-1:0] rd_addr;
    logic [  $clog2(DATA_DEPTH):0] rd_gray;
    logic [  $clog2(DATA_DEPTH):0] rd_gray1;
    logic [  $clog2(DATA_DEPTH):0] rd_gray2;
    logic [        DATA_WIDTH-1:0] RAM                                                    [DATA_DEPTH];

    assign wr_addr = wr_pointer[$clog2(DATA_DEPTH)-1:0];
    assign rd_addr = rd_pointer[$clog2(DATA_DEPTH)-1:0];

    always_ff @(posedge wr_clk or negedge wr_rstn) begin
        if (!wr_rstn) begin
            wr_pointer   <= 0;
            RAM[wr_addr] <= 0;
        end else begin
            if (wen && ~full) begin
                wr_pointer   <= wr_pointer + 1'b1;
                RAM[wr_addr] <= din;
            end
        end
    end  //写控制端

    always_ff @(posedge rd_clk or negedge rd_rstn) begin
        if (!rd_rstn) begin
            rd_pointer <= 0;
            dout       <= 0;
        end else begin
            if (ren && ~empty) begin
                rd_pointer <= rd_pointer + 1'b1;
                dout       <= RAM[rd_addr];
            end
        end
    end  //读控制端

    assign wr_gray = wr_pointer ^ (wr_pointer >> 1);
    assign rd_gray = rd_pointer ^ (rd_pointer >> 1);  //二进制地址转化为格雷码

    assign full    = (wr_gray[$clog2(DATA_DEPTH):$clog2(DATA_DEPTH)-1] == ~rd_gray2[$clog2(DATA_DEPTH):$clog2(DATA_DEPTH)-1]) && (wr_gray[$clog2(DATA_DEPTH)-2:0] == rd_gray2[$clog2(DATA_DEPTH)-2:0]);
    assign empty   = (rd_gray == wr_gray2);  //满空信号

    always_ff @(posedge wr_clk or negedge wr_rstn) begin
        if (!wr_rstn) begin
            rd_gray1 <= 0;
            rd_gray2 <= 0;
        end else begin
            rd_gray1 <= rd_gray;
            rd_gray2 <= rd_gray1;
        end
    end

    always_ff @(posedge rd_clk or negedge rd_rstn) begin
        if (!rd_rstn) begin
            wr_gray1 <= 0;
            wr_gray2 <= 0;
        end else begin
            wr_gray1 <= wr_gray;
            wr_gray2 <= wr_gray1;
        end
    end  //两个时钟同步
endmodule
