module receiver (
    input  logic       clk,
    input  logic       rstn,
    input  logic [7:0] data_o,
    input  logic       req,
    output logic       ack
);
    logic [7:0] data_r;
    typedef enum logic [2:0] {
        Wait_req,
        Wait_ack,
        Handshake,
        Reset,
        Idle
       } state_t;
       state_t state, next_state;
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            state <= Idle;
        end else begin
            state <= next_state;
        end
    end
       always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            ack <= 0;
        end else begin
            case (state)
                Wait_req: begin
                    ack <= 0;
                end
                Wait_ack: begin
                    ack <= req;
                    data_r <= data_o;
                end
                Handshake: begin
                    ack    <= 1;
                end
                Reset: begin
                    ack <= req;
                end
                Idle: begin
                    ack <= 0;
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
