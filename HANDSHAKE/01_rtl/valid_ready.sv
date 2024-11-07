module ready_valid(
    input logic clk,
    input logic rstn,
    input logic [7:0]data_i,
    input logic valid_i,
    output logic ready_o,
    output logic [7:0]data_o,
    output logic valid_o,
    input logic ready_i
);
logic valid_r;
logic [7:0]data_r;

assign ready_o = ready_i;//下一个准备好接收，这一个准备好接收
always_ff @( posedge clk or negedge rstn) begin
    if(~rstn)begin
        valid_r<='d0;
    end
    else begin
        if(ready_o)begin
        valid_r<=valid_i;//相当于寄存器打了一拍延迟,这个准备好接受，可以传递valid
    end
end
end
always_ff @( posedge clk or negedge rstn ) begin
        if(ready_i&valid_i)begin
            data_r<=data_i;//数据传输，下一个准备好接收，上一个数据有效则穿data
        end
end
assign valid_o=valid_r;
assign data_o=data_r;
endmodule