`timescale 1ns / 10ps
module bridge_tb;
    //Ports
    logic       clk = '0;
    logic       rstn = '1;
    logic [7:0] data_i = 'd0;
    logic       valid = '0;
    wire        ready;
    wire  [7:0] data_o;
    wire        req;
    logic       ack = 'd0;

    bridge inst (
        .clk   (clk),
        .rstn  (rstn),
        .data_i(data_i),
        .valid (valid),
        .ready (ready),
        .data_o(data_o),
        .req   (req),
        .ack   (ack)
    );
    receiver inst1(
      .clk(clk),
      .rstn(rstn),
      .data_o(data_o),
      .req(req),
      .ack(ack)
    );

    initial begin
        #5 clk = 1;
        forever begin
            #5 clk = ~clk;
        end
    end

    task automatic rst();
    #10 rstn=0;
      #5 rstn=1;
    endtask //automatic
    class Vec;
    rand bit [7:0] rand_data;  // 声明一个8位的随机变量rand_data，用于生成随机数据
endclass

Vec vec = new();  // 创建类Vec的一个实例vec

// 定义一个自动化任务wr_drv，用于驱动写入操作
task automatic wr_drv();
    // 使用随机化生成8位随机数据
    if (!vec.randomize) begin  // 尝试随机化数据，如果失败，输出错误信息
        $display("rand failed");  // 打印随机化失败的提示
    end

    @(posedge clk);  // 等待一个时钟上升沿，用于同步操作
    valid <= 1'b1;  // 将valid信号置为高，表示数据有效
    data_i <= vec.rand_data;  // 将随机生成的数据赋值给data_i，用于输入数据传输
    #1 wait (valid && ready);  // 等待valid和ready同时为高，表示数据可以传输
endtask  //automatic

// 定义一个自动化任务fin_wr，用于结束写入操作
task automatic fin_wr();
    @(posedge clk);  // 等待一个时钟上升沿，用于同步操作
    valid <= 1'b0;  // 将valid信号置为低，表示数据无效，完成数据写入操作
endtask //automatic

// 定义一个自动化任务write，接收一个整数cnt，表示写入数据的次数
task automatic write(input int cnt);
    for (int i = 0; i < cnt; i++) begin  // 使用循环控制写入次数
        wr_drv();  // 每次循环调用wr_drv任务进行数据写入
    end
    fin_wr();  // 完成写入后调用fin_wr任务，结束写入操作
endtask  //automatic

  initial begin
    rst;
  end
  initial begin
    write(40);
    #20 $finish();
  end
// initial begin
//   rst;
//   valid = 1;
//   data_i<=8'b00001000;
//   #10
//   data_i<=8'b00111100;
//   #10
//   data_i<=8'b01001000;
//   #10
//   data_i<=8'b00100100;
//   #10
//   data_i<=8'b00100110;
//   #10
//   data_i<=8'b00100101;
//   #10
//   data_i<=8'b01100100;
//   #10
//   data_i<=8'b10100100;
//   #10
//   data_i<=8'b00110100;
//   #500;
//   $finish;
// end
endmodule
