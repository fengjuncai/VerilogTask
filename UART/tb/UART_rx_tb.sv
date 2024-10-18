`include "define.sv"
module UART_rx_tb;
// parameter CLK_FREQUENCE = 50_000_000  ,
//               BAUD_RATE      = 9600        ,
//               PARITY         = "NONE"      ,
//               FRAME_WD       = 8  ;
             logic                clk   ;
             logic                rst_n ;
             logic                uart_rx;
             logic [`FRAME_WD-1:0] rx_frame;
             logic                rx_done;
             logic                frame_error;

            //  initial begin
            //     clk = 1;
            //     forever #10 clk = ~clk;
            //   end
            
            // initial begin
            //     rst_n = 1'b0;
            //     #22 rst_n = 1'b1;
            //   end

              task uart_send_byte(input [7:0] data);
              integer i;
              begin
                  // Send start bit (0)
                  uart_rx = 1'b0;
                  # (`CLK_FREQUENCE / `BAUD_RATE*20);
      
                  // Send data bits (LSB first)
                  for (i = 0; i < `FRAME_WD; i = i + 1) begin
                      uart_rx = data[i];
                      # (`CLK_FREQUENCE / `BAUD_RATE*20);
                  end
      
                  // Send stop bit (1)
                  uart_rx = 1'b1;
                  # (`CLK_FREQUENCE / `BAUD_RATE*20);
              end
          endtask
      
          initial begin
            clk = 1;
            forever #10 clk = ~clk;
          end
        
        initial begin
            rst_n = 1'b0;
            #22 rst_n = 1'b1;
          end
          // Initialize and reset
          initial begin
              // Initialize signals
              //clk     = 1'b0;
              //rst_n   = 1'b0;
              uart_rx = 1'b1;  // Idle state
      
              // Reset the design
             // # 100;
            //  rst_n = 1'b1;
      
              // Wait for a while before sending data
              # 200;
      
              // Send a byte (e.g., 0xA5)
              uart_send_byte(8'b10010110);
      
              // Wait for the reception to complete
           //   # (`FRAME_WD * `CLK_FREQUENCE / `BAUD_RATE*20);
      
              // Check if rx_done is asserted and the received frame is correct
              if (rx_done && rx_frame == 8'b10010110)
                  $display("Test passed: Received byte 0xA5 correctly");
              else
                  $display("Test failed: Incorrect reception");
      
              // Finish the simulation
              # 10000;
              $finish;
          end




             UART_rx 
        //   #(
            //     .CLK_FREQUENCE(`CLK_FREQUENCE),
            //     .BAUD_RATE(`BAUD_RATE),
            //     .FRAME_WD(`FRAME_WD)
            // )
              uut (
                .clk(clk),
                .rst_n(rst_n),
                .uart_rx(uart_rx),
                .rx_frame(rx_frame),
                .rx_done(rx_done),
                .frame_error(frame_error)
            );

endmodule