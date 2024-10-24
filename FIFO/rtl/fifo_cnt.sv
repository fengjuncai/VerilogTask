module fifo_cnt #(
    parameter DATA_WIDTH = 32,
              DATA_DEPTH = 512,
              MODE       = "Standard"  //FWFT
) (
    input  logic                  clk,
    input  logic                  rst_n,
    input  logic [DATA_WIDTH-1:0] din,
    input  logic                  wen,
    input  logic                  ren,
    output logic                  full,
    output logic                  empty,
    output logic [DATA_WIDTH-1:0] dout
);

    logic [$clog2(DATA_DEPTH)-1:0] addr;
    logic [$clog2(DATA_DEPTH)-1:0] addw;
    logic [        DATA_WIDTH-1:0] mem  [DATA_DEPTH];
    logic [  $clog2(DATA_DEPTH):0] cnt;

    assign empty = (cnt == 0);
    assign full  = (cnt == DATA_DEPTH);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            addr <= 0;
        end else if (MODE == "Standard") begin
            if (ren & !empty) begin
                addr <= (addr + 1'b1) % DATA_DEPTH;
                dout <= mem[addr];
            end else dout <= dout;
        end else if (MODE == "FWFT") begin
            addr = (ren & !empty) ? ((addr + 1'b1) % DATA_DEPTH) : addr;
            dout = mem[addr];
        end else begin
            if (ren & !empty) begin
                addr <= (addr + 1'b1) % DATA_DEPTH;
                dout <= mem[addr];
            end else dout <= dout;
        end
    end  //读操作

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            addw <= 0;
            cnt  <= 0;
        end else begin
            case ({
                wen, ren
            })
                2'b01: begin
                    if (!empty) begin
                        addw      <= addw;
                        mem[addw] <= mem[addw];
                        cnt       <= cnt - 1;
                    end
                end
                2'b10: begin
                    if (!full) begin
                        addw      <= (addw + 1'b1) % DATA_DEPTH;
                        mem[addw] <= din;
                        cnt       <= cnt + 1;
                    end
                end
                2'b11: begin
                    if (!full & !empty) begin
                        addw      <= (addw + 1'b1) % DATA_DEPTH;
                        mem[addw] <= din;
                        cnt       <= cnt;
                    end
                end
                default: begin
                end
            endcase
        end
    end  //写操作与计数器更新
endmodule
