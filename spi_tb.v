module spi_tb;
  reg[7:0] in_slave_data, in_master_data;
  reg clk, reset;
  wire[7:0] out_slave_data, out_master_data;
  wire new_data, mosi, miso, sck, slave_done;
  integer i;
  reg ss, start;
  spi_master spi_m(.clk(clk),       
                   .rst(reset),       
                   .miso(miso),       
                   .mosi(mosi),     
                   .sck(sck),     
                   .start(start),     
                   .data_in(in_master_data), 
                   .data_out(out_master_data), 
                   .busy(),     
                   .new_data(new_data));
  spi_slave spi_s(.clk(clk),     
                  .rst(reset),    
                  .ss(ss),    
                  .mosi(mosi),  
                  .miso(miso),  
                  .sck(sck),    
                  .done(slave_done), 
                  .din(in_slave_data),  
                  .dout(out_slave_data));
  
  always #2 clk = ~clk;
  
  always @(posedge slave_done) begin //{
    in_master_data = in_master_data + 3'h3;
    in_slave_data = in_slave_data +4'h8;
  end //}
  
  initial begin
    clk = 1'b0; reset = 1'b0; ss = 1'b1; start = 1'b0; 
    in_slave_data= 8'h0;
    in_master_data = 8'h0;
    
    #3 reset = 1'b1;
    #4 reset = 1'b0;
    #10;
    #1 in_master_data = 8'h1c;
    in_slave_data = 8'hc1;
    #50;
    ss = 1'b0;
    start = 1'b1;
    $monitor("Sim time %t, in_master_data %h, new_master_data %b, out_slave_data %h, slave_done %b, in_slave data %h, out_master_data %h", $time,in_master_data,new_data,out_slave_data,slave_done,in_slave_data, out_master_data);
    #1000 $finish;
  end
  
  
  
  initial begin
    $dumpfile("dump.vcd");
   $dumpvars;
  end    
endmodule
