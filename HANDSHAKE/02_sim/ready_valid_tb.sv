`timescale 1ns/1ps
module ready_valid_tb;
logic clk=0;
logic rstn=1;
logic [7:0]data_i;
logic valid_i;
logic ready_o;
logic [7:0]data_o;
logic valid_o;
logic ready_i;

ready_valid inst(
    .clk(clk),
    .rstn(rstn),
    .data_i(data_i),
    .valid_i(valid_i),
    .ready_o(ready_o),
    .data_o(data_o),
    .valid_o(valid_o),
    .ready_i(ready_i)
);

initial begin
    forever begin
        #5 clk = ~clk;
    end
end
task automatic rst();
    #5 rstn=0;
    #30 rstn=1;
endtask //automatic

task automatic en();
    #25
    ready_i<=1;
    valid_i<=0;//下一个准备接受，上一个无�?
    data_i<=8'b00001000;
    #10
    data_i<=8'b00111100;
    valid_i<=1;//上一个有�?
    #10
    data_i<=8'b01001000;
    #10
    valid_i<=0;
    #10
    data_i<=8'b00100100;
    valid_i<=1;
    ready_i<=0;//上一个数据有效，下一个不接收
    #20
    ready_i<=1;
    #10
    valid_i<=0;
    #500;
    $finish;
endtask //automatic

initial begin
    rst;
    #10;
    en;
end
endmodule