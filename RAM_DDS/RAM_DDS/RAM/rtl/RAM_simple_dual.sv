module RAM_simple_dual #(
    parameter DATA_WIDTH    = 32,             //位宽
              ADDR_WIDTH    = 10,             //地址位宽2^10
              DATA_DEPTH    = 1024,
              RAM_STYLE_VAL = "block",  //RAM的实现风格block/restributed
              MODE          = "NO CHANGE"     //读写地址冲突
) (
    input  logic                    clk,
    input  logic                    rst_n,
    input  logic                    wen,    //写使�?
    input  logic [ADDR_WIDTH-1 : 0] addra,
    input  logic [  DATA_WIDTH-1:0] din,
    //input logic ren,//读使�?
    input  logic [  ADDR_WIDTH-1:0] addrb,
    output logic [  DATA_WIDTH-1:0] dout
);

    (*RAM_STYLE = RAM_STYLE_VAL*) logic [DATA_WIDTH-1:0] mem[DATA_DEPTH] = '{default: '0};


    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            dout <= 'd0;
            for (int i = 0; i < DATA_DEPTH; i++) begin
                mem[i] <= 'd0;
            end
        end else begin
            case (MODE)
                "NO CHANGE": begin
                    if (wen) begin
                        mem[addra] <= din;
                    end else begin
                        dout <= mem[addrb];
                    end
                end
                "WRITE_FIRST": begin
                    if (addra == addrb) begin
                        if (wen) begin
                            dout       <= din;
                            mem[addra] <= din;
                        end else begin
                            dout <= mem[addrb];
                        end
                    end else begin
                        if (wen) begin
                            mem[addra] <= din;
                        end else begin
                            dout <= mem[addrb];
                        end
                    end
                end
                "READ_FIRST": begin
                    if (addra == addrb) begin
                        if (wen) begin
                            dout       <= mem[addrb];
                            mem[addra] <= din;
                        end else begin
                            dout <= mem[addrb];
                        end
                    end else begin
                        if (wen) begin
                            mem[addra] <= din;
                        end else begin
                            dout <= mem[addrb];
                        end
                    end
                end
                default: begin
                    if (addra == addrb) begin
                        if (wen) begin
                            mem[addra] <= din;
                        end else begin
                            dout <= mem[addrb];
                        end
                    end else begin
                        if (wen) begin
                            mem[addra] <= din;
                        end else begin
                            dout <= mem[addrb];
                        end
                    end
                end
            endcase
        end
    end
endmodule
