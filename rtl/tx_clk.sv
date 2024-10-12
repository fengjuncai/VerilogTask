`timescale 1ns/1ps
module tx_clk#(parameter CLK_FREQUENCE = 50_000_000,BAUD_RATE = 9600)
(clk,tx_start,tx_done,bqs_clk,rst_n);//生成波特率的时钟
    input logic clk,tx_start,tx_done,rst_n;
    output logic bqs_clk;
    localparam BPS_CNT = CLK_FREQUENCE/BAUD_RATE-1,
    BPS_WD = $clog2(BPS_CNT);
    logic [BPS_WD-1:0] count;
    typedef enum logic [2:0]{
        STATE1,//0
        STATE2//1
      } state_t;
    state_t r,n;//状态机定义
    always_comb begin
        n=r;
        case(r)
        STATE1: begin
            if(tx_start)
            n=STATE2;
        end
        STATE2: begin
            if(tx_done)
            n=STATE1;
        end
        endcase
    end//״̬状态更新
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            r <= STATE1; 
        else
            r <= n;  
    end//״状态转移
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            count <= {BPS_WD{1'b0}};  
        else if(r==STATE1)
            count <= {BPS_WD{1'b0}}; 
        else begin
		if (count == BPS_CNT) 
			count <= {BPS_WD{1'b0}};
		else
			count <= count + 1'b1;
    end
end//计数器更新
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            bqs_clk <= 1'b0;  // 
        else if(count == BPS_CNT)
            bqs_clk <= 1'b1;  // 
        else
            bqs_clk <= 1'b0;
    end//生成波特率时钟



endmodule