module bridge (
    input  logic       clk,
    input  logic       rstn,
    input  logic [7:0] data_i,
    input  logic       valid,
    output logic       ready,
    output logic [7:0] data_o,
    output logic       req,
    input  logic       ack
);
    logic full;
    logic empty;
    logic ren;
    logic [7:0]data_r;
    typedef enum logic [2:0] {
     Wait_req,
     Wait_ack,
     Handshake,
     Reset,
     Idle
    } state_t;
    state_t state, next_state;
    fifo_cnt inst (
        .clk(clk),
        .rst_n(rstn),
        .din  (data_i),
        .wen  (valid & ready),
        .full (full),
        .empty(empty),
        .dout (data_r),
        .ren  (ren)
    );
    assign data_o=req?data_r:'d0;
    assign ready = ~full;  //

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            state <= Idle;
        end else begin
            state <= next_state;
        end
    end
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            ren <= 0;
            req <= 0;
        end else begin
            case (next_state)
                Wait_req: begin
                    ren <= 1;
                    req <= 0;
                end
                Wait_ack: begin
                    ren <= 0;
                    req <= 1;
                end
                Handshake: begin
                    ren <= 0;
                    req <= 1;
                end
                Reset: begin
                    ren <= 0;
                    req <= 0;
                end
                Idle: begin
                    ren <= 0;
                    req <= 0;
                end
            endcase
        end
    end
    always_comb begin
        case (state)
            Wait_req: begin
                next_state = Wait_ack;
            end
            Wait_ack: begin
                next_state = (req == 1 & ack == 0) ? Handshake : Wait_ack;
            end
            Handshake: begin
                next_state = (req == 1 & ack == 1) ? Reset : Handshake;
            end
            Reset: begin
                next_state = (req == 0 & ack == 1) ? Idle : Reset;
            end
            Idle: begin
                next_state = (req == 0 & ack == 0) ? Wait_req : Idle;
            end
        endcase
    end
endmodule
