module uart #(
    parameter CLK_FREQUENCE = 50_000_000,
              BAUD_RATE     = 9600,
              PARITY        = "NONE",
              FRAME_WD      = 8
) (
    input  logic                clk,
    input  logic                rst_n,
    input  logic                frame_en,
    input  logic [FRAME_WD-1:0] data_frame,
    output logic                tx_done,
    output logic [FRAME_WD-1:0] rx_frame,
    output logic                rx_done,
    output logic                frame_error
);

    logic uart_tx;
    tx #(
        .CLK_FREQUENCE ( CLK_FREQUENCE ) ,
        .BAUD_RATE  ( BAUD_RATE  ) ,
        .PARITY   ( PARITY   ) , //"NONE","EVEN","ODD"
        .FRAME_WD  ( FRAME_WD   )
    ) tx_inst (
        .clk       (clk),
        .rst_n     (rst_n),
        .frame_en  (frame_en),
        .data_frame(data_frame),
        .tx_done   (tx_done),
        .uart_tx   (uart_tx)
    );
    rx #(
        .CLK_FREQUENCE(CLK_FREQUENCE),
        .BAUD_RATE(BAUD_RATE),
        .PARITY(PARITY),
        .FRAME_WD(FRAME_WD)
    ) rx_inst (
        .clk        (clk),
        .rst_n      (rst_n),
        .uart_rx    (uart_tx),
        .rx_frame   (rx_frame),
        .rx_done    (rx_done),
        .frame_error(frame_error)

    );

//     fifo_generator_0 your_instance_name (
//   .clk(clk),        // input wire clk
//   .srst(!rst_n),      // input wire srst
//   .din(rx),        // input wire [7 : 0] din
//   .wr_en(wr_en),    // input wire wr_en
//   .rd_en(rd_en),    // input wire rd_en
//   .dout(dout),      // output wire [7 : 0] dout
//   .full(full),      // output wire full
//   .wr_ack(wr_ack),  // output wire wr_ack
//   .empty(empty),    // output wire empty
//   .valid(valid)    // output wire valid
// );
endmodule
