module RAM_single#(
    parameter  DATA_WIDTH = 32,
               ADDR_WIDTH = 10,
               DATA_DEPTH = 1024,
               RAM_STYLE_VAL = "block",
               MODE = "NO CHANGE"
)
(
    input logic [DATA_WIDTH-1:0]din,
    input logic wrn,
    input logic [ADDR_WIDTH-1:0]addr,
    input logic rst_n,
    input logic clk,
    output logic [DATA_WIDTH-1:0]dout
);
(*RAM_STYLE = RAM_STYLE_VAL*)logic [DATA_WIDTH-1:0]ram_data[DATA_DEPTH-1:0] ='{default :'0};
initial begin
    $readmemb("coe_tb.txt", ram_data, 0, 1023);
end
always_ff@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        dout <= 'd0;
        for(int i = 0;i<DATA_DEPTH;i++) begin
            ram_data[i] <= 'd0;
        end
    end
    else begin
        case (MODE)
            "WRITE_FIRST": begin
                if(wrn) begin
                    ram_data[addr] <= din;
                    dout <= din;
                end
                else begin
                   dout <= ram_data[addr];
                end
            end
            "READ_FIRST":begin
            if(wrn) begin
                dout <= ram_data[addr];
                ram_data[addr] <= din;
            end
            else begin
               dout <= ram_data[addr];
            end
        end
            "NO CHANGE": begin
                if(wrn) begin
                    ram_data[addr] <= din;
                end
                else begin
                   dout <= ram_data[addr];
                end
            end
            default:  begin
                if(wrn) begin
                    ram_data[addr] <= din;
                end
                else begin
                   dout <= ram_data[addr];
                end
            end
        endcase
    end
end
endmodule