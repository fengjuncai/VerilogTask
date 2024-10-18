`timescale 1ns / 1ps
module tx #(
    parameter CLK_FREQUENCE = 50_000_000,
              BAUD_RATE     = 9600,
              PARITY        = "NONE",
              FRAME_WD      = 8
) (
    clk,
    rst_n,
    frame_en,
    tx_done,
    data_frame,
    uart_tx
);
  input logic clk, rst_n, frame_en;
  input logic [FRAME_WD-1:0] data_frame;
  output logic tx_done, uart_tx;
  logic bqs_clk;
  tx_clk #(
      .CLK_FREQUENCE(CLK_FREQUENCE),
      .BAUD_RATE(BAUD_RATE)
  ) tx_clk_inst (
      clk,
      frame_en,
      tx_done,
      bqs_clk,
      rst_n
  );
  logic [1:0] verify_mode;
  generate
    if (PARITY == "EVEN") assign verify_mode = 2'b10;
    else if (PARITY == "ODD") assign verify_mode = 2'b01;
    else assign verify_mode = 2'b00;
  endgenerate
  logic [      FRAME_WD-1:0] data_reg;
  logic [$clog2(FRAME_WD):0] cnt;
  logic                      parity_even;
  typedef enum logic [2:0] {
    IDLE,  //0
    READY,  //1
    START_BIT,
    SHIFT_PRO,
    PARITY_BIT,
    STOP_BIT,
    DONE
  } state_t;
  state_t r, n;

  always_comb begin
    n = r;
    case (r)
      IDLE: begin
        if (frame_en) n = READY;
      end
      READY: begin
        if (bqs_clk == 1'b1) n = START_BIT;
      end
      START_BIT: begin
        if (bqs_clk == 1'b1) n = SHIFT_PRO;
      end
      SHIFT_PRO: begin
        if (cnt == FRAME_WD - 1 & bqs_clk == 1'b1) n = PARITY_BIT;
      end
      PARITY_BIT: begin
        if (bqs_clk == 1'b1) n = STOP_BIT;
      end
      STOP_BIT: begin
        if (bqs_clk == 1'b1) n = DONE;
      end
      DONE:    n = IDLE;
      default: n = IDLE;
    endcase
  end  //状态转移
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) r <= IDLE;  // 如果复位回到初始状态
    else r <= n;  // 更新到下个状态
  end  //状态更新
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) cnt <= 'd0;  // 
    else if (r == SHIFT_PRO & bqs_clk == 1'b1)
      if (cnt == FRAME_WD - 1) cnt <= 'd0;
      else cnt <= cnt + 1'b1;
    else cnt <= cnt;
  end  //计数
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      data_reg    <= 'd0;
      uart_tx     <= 1'b1;
      tx_done     <= 1'b0;
      parity_even <= 1'b0;
    end else begin
      case (n)
        IDLE: begin
          data_reg <= 'd0;
          tx_done  <= 1'b0;
          uart_tx  <= 1'b1;
        end
        READY: begin
          data_reg <= 'd0;
          tx_done  <= 1'b0;
          uart_tx  <= 1'b1;
        end
        START_BIT: begin
          data_reg    <= data_frame;
          parity_even <= ^data_frame;
          uart_tx     <= 1'b0;
          tx_done     <= 1'b0;
        end
        SHIFT_PRO: begin
          if (bqs_clk == 1'b1) begin
            data_reg <= {1'b0, data_reg[FRAME_WD-1:1]};
            uart_tx  <= data_reg[0];
          end else begin
            data_reg <= data_reg;
            uart_tx  <= uart_tx;
          end
          tx_done <= 1'b0;
        end
        PARITY_BIT: begin
          data_reg <= data_reg;
          tx_done  <= 1'b0;
          case (verify_mode)
            2'b00:   uart_tx <= 1'b1;  
            2'b01:   uart_tx <= ~parity_even;
            2'b10:   uart_tx <= parity_even;
            default: uart_tx <= 1'b1;
          endcase
        end
        STOP_BIT: uart_tx <= 1'b1;
        DONE:     tx_done <= 1'b1;
        default: begin
          data_reg    <= 'd0;
          uart_tx     <= 1'b1;
          tx_done     <= 1'b0;
          parity_even <= 1'b0;
        end
      endcase
    end
  end
endmodule
