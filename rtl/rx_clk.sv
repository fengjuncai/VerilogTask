`timescale 1ns / 1ps

module rx_clk
#(
	parameter	CLK_FREQUENCE	= 50_000_000,	//系统时钟频率
				BAUD_RATE		= 9600		 	//波特率9600常用
)
(
	input	logic				clk			,
	input   logic		        rst_n		,
	input	logic				rx_start	,
	input	logic 				rx_done		,
	output	logic				sample_clk	 
);//rx_start开始传输，rx_done传输完成，sample_clk采样时钟

localparam	SMP_CLK_CNT	=	CLK_FREQUENCE/BAUD_RATE/9 - 1,//1个波特率时钟周期对应的系统时钟周期
			CNT_WIDTH	=	$clog2(SMP_CLK_CNT)			 ;

logic		[CNT_WIDTH-1:0]	clk_count	;//时钟计数
typedef enum logic [1:0]{
	STATE1,//0
	STATE2//1
  } state_t;//状态机定义
state_t r,n;
//r为当前状态，n为下一状态
always_comb begin
	//r=n;//n=r;
	case(r)
	STATE1: begin
		if(rx_start)
		n = STATE2;
	end
	STATE2:begin
		if(rx_done)
		n = STATE1;
	end
	default: n = STATE1;
	endcase
end//状态机传输
always_ff@(posedge clk or negedge rst_n)begin
	if(!rst_n) begin
		r <= STATE1;
	end
	else 
		r <= n;
end//状态机更新
always_ff@(posedge clk or negedge rst_n)begin
	if(!rst_n)
	clk_count <= 'd0;
	else if(r == STATE1)
	clk_count <= 'd0;
	else if(clk_count == SMP_CLK_CNT)
	clk_count <= 'd0;
	else
	clk_count <= clk_count + 1'b1;
end
//计数器更新
always_ff@(posedge clk or negedge rst_n) begin
	if (!rst_n) 
		sample_clk <= 1'b0;
	else if (clk_count == SMP_CLK_CNT) 
		sample_clk <= 1'b1;
	else 
		sample_clk <= 1'b0;
end
//采样时钟
endmodule