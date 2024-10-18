module RAM_dual #(
    parameter DATA_DEPTH    = 1024,
              DATA_WIDTH    = 32,
              ADDR_WIDTH    = 10,
              RAM_STYLE_VAL = "block",      //RAM的实现风格block/restributed
              MODEA         = "NO CHANGE",  //读写地址冲突
              MODEB         = "NO CHANGE"
) (
    input  logic                  clka,
    input  logic                  clkb,
    input  logic                  rst_n,
    input  logic                  wea,
    input  logic                  web,
    input  logic [DATA_WIDTH-1:0] dina,
    input  logic [DATA_WIDTH-1:0] dinb,
    input  logic [ADDR_WIDTH-1:0] addra,
    input  logic [ADDR_WIDTH-1:0] addrb,
    output logic [DATA_WIDTH-1:0] douta,
    output logic [DATA_WIDTH-1:0] doutb
);



    (*RAM_STYLE = RAM_STYLE_VAL*)
    logic [DATA_WIDTH-1:0] mem[DATA_DEPTH] = '{default: '0};



    //A port
    always_ff @(posedge clka or negedge rst_n) begin
        if (!rst_n) begin
            douta <= 0;
        end else begin
            case (MODEA)
                "NO CHANGE": begin
                    if (wea) begin
                        mem[addra] <= dina;
                    end else begin
                        douta <= mem[addra];
                    end
                end
                "WRITE_FIRST": begin
                    if (wea) begin
                        douta      <= dina;
                        mem[addra] <= dina;
                    end else begin
                        douta <= mem[addra];
                    end
                end
                "READ_FIRST": begin
                    if (wea) begin
                        douta      <= mem[addra];
                        mem[addra] <= dina;
                    end else begin
                        douta <= mem[addra];
                    end
                end
                default: begin
                    if (wea) begin
                        mem[addra] <= dina;
                    end else begin
                        douta <= mem[addra];
                    end
                end

            endcase
        end
    end


    //B port
    always_ff @(posedge clkb or negedge rst_n) begin
        if (!rst_n) begin
            doutb <= 0;
        end else begin
            case (MODEB)
                "NO CHANGE": begin
                    if (web & !(addra == addrb)) begin
                        mem[addrb] <= dinb;
                    end else begin
                        doutb <= mem[addrb];
                    end
                end
                "WRITE_FIRST": begin
                    if (web & !(addra == addrb)) begin
                        doutb      <= dinb;
                        mem[addrb] <= dinb;
                    end else begin
                        doutb <= mem[addrb];
                    end
                end
                "READ_FIRST": begin
                    if (web & !(addra == addrb)) begin
                        doutb      <= mem[addrb];
                        mem[addrb] <= dinb;
                    end else begin
                        doutb <= mem[addrb];
                    end
                end
                default: begin
                    if (web & !(addra == addrb)) begin
                        mem[addrb] <= dinb;
                    end else begin
                        doutb <= mem[addrb];
                    end
                end
            endcase
        end
    end
endmodule
