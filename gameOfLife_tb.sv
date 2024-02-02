`timescale 1ns / 1ps

module gameOfLife_tb();
  logic clk=1, clear=0;
  logic [3:0] rst_n=0;
  logic [7:0] vga_x, VGA_R, VGA_G, VGA_B;
  logic [6:0] vga_y, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
  logic [9:0] SW, LEDR;
  logic vga_plot, draw=0, start, done, rotate, stop, VGA_HS, VGA_VS, VGA_CLK;
  logic [2:0] VGA_COLOUR;

  gameOfLife DUT(.CLOCK_50(clk), .KEY(rst_n), .VGA_X(vga_x), .VGA_Y(vga_y),
     .VGA_PLOT(vga_plot), .*);
 
  drawImage drawIm(.clear(clear), .draw(draw), .clock(clk), .x(vga_x), .y(vga_y), .plot(vga_plot));

  initial forever begin #10; clk = ~clk; end

  initial
  begin 
    #20; 
    $readmemb("initialState.txt", DUT.mem);
    #20; rst_n=4'b1111;
    stop=0; rotate=1;
    clear=1; #10 clear=0;
    wait(done);
    #40;
    draw = 1; #20 draw = 0;
    clear=1; #10 clear=0;
    wait(done);
    #40;
    draw = 1; #20 draw = 0;
    clear=1; #10 clear=0;
    wait(done);
    #40;
    draw = 1; #20 draw = 0;
    clear=1; #10 clear=0;
    wait(done);
    #40;
    draw = 1; #20 draw = 0;
    clear=1; #10 clear=0;
    wait(done);
    #40;
    draw = 1; #20 draw = 0;
    clear=1; #10 clear=0;
    wait(done);
    $stop; 
  end


endmodule: gameOfLife_tb

module drawImage(
  input logic clear, input logic draw, input logic clock,
  input logic [7:0] x,
  input logic [6:0] y,
  input logic plot
);
  parameter X_SCREEN=49; 
  parameter Y_SCREEN=49; 

  logic [X_SCREEN:0][Y_SCREEN:0][7:0] ascii_mem;

  always @(posedge clock) begin
    if (draw) 
      draw_ascii();
    else if (clear) 
      clear_ascii();
    else if (plot) begin
      if(x<=X_SCREEN & y<=Y_SCREEN) 
         ascii_mem[x][y] = "@";
    end
  end

  task clear_ascii();
    for(int j=0;j<=Y_SCREEN;j++)
      for(int i=0;i<=X_SCREEN;i++)
        ascii_mem[i][j] = ".";
  endtask

  task draw_ascii();
    for(int j = 0; j <= Y_SCREEN; j++) begin 
       for(int i = 0; i <= X_SCREEN; i++) begin      
          $write("%0s", ascii_mem[i][j]);
       end
       $write("\n");
    end
  endtask


endmodule

