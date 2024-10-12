`timescale 1ns / 1ps

module rx #(
    parameter CLK_FREQUENCE = 50_000_000,
              BAUD_RATE     = 9600,
              PARITY        = "NONE",
              FRAME_WD      = 8
) (
    input  logic                clk,
    input  logic                rst_n,
    input  logic                uart_rx,
    output logic [FRAME_WD-1:0] rx_frame,
    output logic                rx_done,
    output logic                frame_error
);
    logic                          sample_clk;  //采样时钟
    logic                          frame_en;  //使能信号
    logic                          cnt_en;  //计数器使能
    logic [                   3:0] sample_clk_cnt;  //采样时钟计数
    logic [$clog2(FRAME_WD+1)-1:0] sample_bit_cnt;  //采样位数计数
    logic                          baud_rate_clk;  //传完1个波特的时钟周期

    logic [                   1:0] verify_mode;//奇偶校验模式

    rx_clk #(
        .CLK_FREQUENCE(CLK_FREQUENCE),  //hz
        .BAUD_RATE(BAUD_RATE)  //9600、19200 、38400 、57600 、115200、230400、460800、921600
    ) rx_clk_inst (
        .clk       (clk),
        .rst_n     (rst_n),
        .rx_start  (frame_en),
        .rx_done   (rx_done),
        .sample_clk(sample_clk)
    );//采样时钟实例化


    generate
        if (PARITY == "ODD") assign verify_mode = 2'b01;
        else if (PARITY == "EVEN") assign verify_mode = 2'b10;
        else assign verify_mode = 2'b00;

    endgenerate  //奇偶校验

    logic uart_rx0, uart_rx1, uart_rx2, uart_rx3;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            uart_rx0 <= 1'b0;
            uart_rx1 <= 1'b0;
            uart_rx2 <= 1'b0;
            uart_rx3 <= 1'b0;
        end else begin
            uart_rx0 <= uart_rx;
            uart_rx1 <= uart_rx0;
            uart_rx2 <= uart_rx1;
            uart_rx3 <= uart_rx2;
        end
    end  //找最后位起始位的交界

    assign frame_en = uart_rx3 & uart_rx2 & ~uart_rx1 & ~uart_rx0;  //1100clk很短，找到一瞬间的交�??

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) cnt_en <= 1'b0;
        else if (frame_en) cnt_en <= 1'b1;
        else if (rx_done) cnt_en <= 1'b0;
        else cnt_en <= cnt_en;
    end  //计数器使能

    //波特率时钟，完成1次传输的时钟
    assign baud_rate_clk = sample_clk & sample_clk_cnt == 4'd8;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) sample_clk_cnt <= 4'd0;
        else if (cnt_en) begin
            if (baud_rate_clk) sample_clk_cnt <= 4'd0;
            else if (sample_clk) begin
                sample_clk_cnt <= sample_clk_cnt + 1'b1;
            end else sample_clk_cnt <= sample_clk_cnt;
        end else sample_clk_cnt <= 4'd0;
    end


    typedef enum logic [2:0] {
        IDLE,
        START_BIT,
        DATA_FRAME,
        PARITY_BIT,
        STOP_BIT,
        DONE
    } state_t;
    state_t r, n;
    //状态机定义

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) sample_bit_cnt <= 'd0;
        else if (r == IDLE) sample_bit_cnt <= 'd0;
        else if (baud_rate_clk) sample_bit_cnt <= sample_bit_cnt + 1'b1;
        else sample_bit_cnt <= sample_bit_cnt;
    end

    logic [1:0] sample_result;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) sample_result <= 1'b0;
        else if (sample_clk) begin
            case (sample_clk_cnt)
                4'd0:             sample_result <= 2'd0;
                4'd3, 4'd4, 4'd5: sample_result <= sample_result + uart_rx;
                default:          sample_result <= sample_result;
            endcase
        end
    end

    always_comb begin
        n = r;
        case (r)
            IDLE: begin
                if (frame_en) n <= START_BIT;
            end
            START_BIT: begin
                if (baud_rate_clk & sample_result[1] == 1'b0) n <= DATA_FRAME;
            end
            DATA_FRAME: begin
                case (verify_mode[1] ^ verify_mode[0])
                    1'b1:    n = (sample_bit_cnt == FRAME_WD & baud_rate_clk) ? PARITY_BIT : DATA_FRAME;
                    1'b0:    n = (sample_bit_cnt == FRAME_WD & baud_rate_clk) ? STOP_BIT : DATA_FRAME;
                    default: n = (sample_bit_cnt == FRAME_WD & baud_rate_clk) ? STOP_BIT : DATA_FRAME;
                endcase
            end
            PARITY_BIT: begin
                if (baud_rate_clk) n <= STOP_BIT;
            end
            STOP_BIT: begin
                if (baud_rate_clk & sample_result[1] == 1'b1) n <= DONE;
            end
            DONE: begin
                n <= IDLE;
            end
            default: n <= IDLE;
        endcase
    end  //状态转移
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) r <= IDLE;
        else r <= n;
    end  //状态更新
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_frame    <= 'd0;
            rx_done     <= 1'b0;
            frame_error <= 1'b0;
        end else begin
            case (r)
                IDLE: begin
                    rx_frame    <= 'd0;
                    rx_done     <= 1'b0;
                    frame_error <= 1'b0;
                end
                START_BIT: begin
                    rx_frame    <= 'd0;
                    rx_done     <= 1'b0;
                    frame_error <= 1'b0;
                end
                DATA_FRAME: begin
                    if (sample_clk & sample_clk_cnt == 4'd6) rx_frame <= {sample_result[1], rx_frame[FRAME_WD-1:1]};
                    else rx_frame <= rx_frame;
                    rx_done     <= 1'b0;
                    frame_error <= 1'b0;
                end
                PARITY_BIT: begin
                    rx_frame <= rx_frame;
                    rx_done  <= 1'b0;
                    if (sample_clk_cnt == 4'd8) frame_error <= ^rx_frame ^ sample_result[1];
                    else frame_error <= frame_error;
                end
                STOP_BIT: begin
                    rx_frame    <= rx_frame;
                    rx_done     <= 1'b0;
                    frame_error <= frame_error;
                end
                DONE: begin
                    frame_error <= frame_error;
                    rx_done     <= 1'b1;
                    rx_frame    <= rx_frame;
                end
                default: begin
                    rx_frame    <= rx_frame;
                    rx_done     <= 1'b0;
                    frame_error <= frame_error;
                end
            endcase
        end
    end//状态机功能
endmodule
