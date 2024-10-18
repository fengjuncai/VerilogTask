`timescale 1ns / 1ps
module uart_loop_tb;
    parameter CLK_FREQUENCE = 50_000_000;
    parameter BAUD_RATE = 9600;
    parameter PARITY = "NONE";
    parameter FRAME_WD = 8;
    parameter data_delay = 1000_000_000 / BAUD_RATE;
    logic clk;
    logic rst_n = 1'b0;
    logic uart_rx = 1'b1;
    logic uart_tx;

    uart #(
        .CLK_FREQUENCE(CLK_FREQUENCE),
        .BAUD_RATE(BAUD_RATE),
        .PARITY(PARITY),
        .FRAME_WD(FRAME_WD)
    ) uart_inst (
        .clk    (clk),
        .rst_n  (rst_n),
        .uart_rx(uart_rx),
        .uart_tx(uart_tx)
    );

    initial begin
        clk = 1'b0;
        forever begin
            #10;
            clk = !clk;
        end

    end

    task automatic rst();
        #30;
        rst_n = 1'b0;
        #30;
        rst_n = 1'b1;
    endtask

    task automatic en();
        // Wait for clock edge
	     #data_delay;
        uart_rx = 1'b0;  // Start bit
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


        uart_rx = 1'b1;  // Stop bit
        #data_delay;
    endtask

    task automatic en1();
        // Wait for clock edge
	    #data_delay;
        uart_rx = 1'b0;  // Start bit
        #data_delay;
        // Send data bits (for example, sending '10101010')
        uart_rx = 1'b1;
        #data_delay;
        uart_rx = 1'b0;
        #data_delay;
        uart_rx = 1'b0;
        #data_delay;
        uart_rx = 1'b0;
        #data_delay;
        uart_rx = 1'b1;
        #data_delay;
        uart_rx = 1'b0;
        #data_delay;
        uart_rx = 1'b0;
        #data_delay;
        uart_rx = 1'b1;
        #data_delay;


        uart_rx = 1'b1;  // Stop bit
        #data_delay;
    endtask
    initial begin
        rst();
        #25;
		@(posedge clk);
        en();
        #data_delay;
		#data_delay;
		@(posedge clk);
        en1();
        #data_delay;$finish();
    end


endmodule
