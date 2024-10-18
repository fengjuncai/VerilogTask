module DDS #(
    parameter WAVE       = "TRI",
              DATA_DEPTH = 3072,
              DATA_WIDTH = 32,
              ADDR_WIDTH = 10
) (
    input  logic                  en,
    input  logic                  clk,
    input  logic                  rst_n,
    input  logic [ADDR_WIDTH-1:0] phase_start,
    input  logic [           3:0] step,
    output logic [DATA_WIDTH-1:0] dout
);

    logic                  wra = 0;
    logic [DATA_WIDTH-1:0] dina = 'd0;
    logic [          11:0] addra = 'd0;
    logic [DATA_WIDTH-1:0] douta = 'd0;

    RAM_single #(
        .DATA_DEPTH(DATA_DEPTH),
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) inst (
        .clk  (clk),
        .wrn  (wra),
        .din  (dina),
        .rst_n(rst_n),
        .addr (addra),
        .dout (douta)
    );

    logic [ADDR_WIDTH-1:0] phase = 'd0;
    logic [           1:0] phase_MSB = 'd0;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            phase <= phase_start;
            dout  <= 'd0;
        end else begin
            if (en) begin
                case (WAVE)
                    "TRI": begin
                        phase_MSB <= 2'b00;
                    end
                    "SIN": begin
                        phase_MSB <= 2'b01;
                    end
                    "SQU": begin
                        phase_MSB <= 2'b10;
                    end
                    default: begin
                        phase_MSB <= 2'b00;
                    end
                endcase
                phase <= phase + step;
                addra <= {phase_MSB, phase};
                dout  <= douta;
            end else begin
                dout <= 0;
            end
        end
    end
endmodule
