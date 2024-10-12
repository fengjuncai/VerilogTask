`timescale 1ns/1ps
module rx_tb;
parameter CLK_FREQUENCE = 50_000_000;
parameter BAUD_RATE = 9600;
parameter PARITY ="NONE";
parameter FRAME_WD = 8;
parameter data_delay = 1000_000_000/BAUD_RATE;
logic clk ;
logic rst_n = 1'b0;
logic uart_rx = 1'b1;
logic [FRAME_WD-1:0] rx_frame; //= {FRAME_WD{1'b0}}
logic rx_done ;//= 1'b0;
logic frame_error;// = 1'b0;

rx#(
    .CLK_FREQUENCE(CLK_FREQUENCE),
    .BAUD_RATE(BAUD_RATE),
    .PARITY(PARITY),
    .FRAME_WD(FRAME_WD)
)
rx_inst(
    .clk(clk),
    .rst_n(rst_n),
    .uart_rx(uart_rx),
    .rx_frame(rx_frame),
    .rx_done(rx_done),
    .frame_error(frame_error)
);
initial begin
    clk = 1'b1;
    forever begin 
        #10 clk = ~clk;
    end
end

task automatic rst();
#10;
rst_n = 1'b0;
#20;
rst_n = 1'b1;
#20;
endtask

task automatic en();
     // Wait for clock edge
    uart_rx = 1'b0; // Start bit
    #data_delay;
    // Send data bits (for example, sending '10101010')
    uart_rx = 1'b1;
    #data_delay;
    uart_rx = 1'b0; 
    #data_delay;
    uart_rx = 1'b1; 
    #data_delay;
    uart_rx = 1'b0; 
    #data_delay;
    uart_rx = 1'b1; 
    #data_delay;
    uart_rx = 1'b0; 
    #data_delay;
    uart_rx = 1'b1; 
    #data_delay;
    uart_rx = 1'b1; 
    #data_delay;


    uart_rx = 1'b1; // Stop bit
    #data_delay;
endtask

// task automatic en();
// forever begin
// @(posedge clk);
// uart_rx = 1'b1;
// @(posedge clk);
// uart_rx = 1'b0;
// end
// endtask

initial begin
    rst();
    #20;
    en();
    #10000;
    $finish;
end
endmodule