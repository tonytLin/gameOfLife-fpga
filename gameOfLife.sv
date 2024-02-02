module gameOfLife(input logic CLOCK_50, input logic [3:0] KEY,
         input logic [9:0] SW, output logic [9:0] LEDR,
         output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
         output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
         output logic [7:0] VGA_R, output logic [7:0] VGA_G, output logic [7:0] VGA_B,
         output logic VGA_HS, output logic VGA_VS, output logic VGA_CLK,
         output logic [7:0] VGA_X, output logic [6:0] VGA_Y,
         output logic [2:0] VGA_COLOUR, output logic VGA_PLOT); // output logic done
    enum { RUN, INC_X, INC_Y, STALL } state;
    parameter height = 60;
    parameter width = 80;

    logic [7:0] vga_x;
    logic [6:0] vga_y;
    logic vga_plot;
    logic [2:0] vga_colour;
    logic mem[0:(height*width)-1]; // 160x120, perimeter all zero
	 initial $readmemb("initialState.txt", mem);
    logic game_clk;
	 logic [32:0] count;

    logic [9:0] VGA_R_10;
    logic [9:0] VGA_G_10;
    logic [9:0] VGA_B_10;
    logic VGA_BLANK, VGA_SYNC;

    // assign outputs for testing purposes
    assign VGA_X = vga_x;
    assign VGA_Y = vga_y;
    assign VGA_PLOT = vga_plot;
    assign VGA_COLOUR = vga_colour;
    assign VGA_R = VGA_R_10[9:2];
    assign VGA_G = VGA_G_10[9:2];
    assign VGA_B = VGA_B_10[9:2];

    vga_adapter#(.RESOLUTION("80x60")) vga_u0(.resetn(KEY[3]), .clock(CLOCK_50), .colour(vga_colour), .x(vga_x), .y(vga_y), .plot(vga_plot), .VGA_R(VGA_R_10), .VGA_G(VGA_G_10), .VGA_B(VGA_B_10), .VGA_HS(VGA_HS), .VGA_VS(VGA_VS), .VGA_BLANK(VGA_BLANK), .VGA_SYNC(VGA_SYNC), .VGA_CLK(VGA_CLK));

    // update game state
    generate
	     genvar i;
        for (i = 0; i < (height*width); i = i + 1) begin: update_game_state
            if (i > (width-1) && i < (height*width-width) && (i % width) != 0 && ((i+1) % width) != 0) begin // if within bounds 
                logic [2:0] sum;
                counter c0({mem[i-width-1], mem[i-width], mem[i-width+1], mem[i-1], mem[i+1], mem[i+width-1], mem[i+width], mem[i+width+1]}, sum);
                always_ff @(posedge game_clk) begin
                    if (sum > 3 || sum < 2) begin
                        mem[i] <= 0;
                    end
                    if (sum == 2) begin
                        mem[i] <= mem[i];
                    end
                    if (sum == 3) begin
                        mem[i] <= 1;
                    end
                end
            end
        end
    endgenerate

    // display game state
    always_ff @(posedge CLOCK_50) begin
        if (~KEY[3]) begin
            state <= RUN;
            vga_colour <= 3'b000;
            vga_plot <= 1;
            game_clk <= 0;
			   //$readmemb("initialState.txt", mem);
            //done <= 0; // REMOVE LATER
        end
        else begin
            case (state)
                RUN: begin
                    state <= INC_X;
                    vga_x <= 0;
                    vga_y <= 0;
						  vga_colour[1] <= mem[0];
                    game_clk <= 0;
                    //done <= 0; // REMOVE LATER
                end
                INC_X: begin
                    if (vga_x > (width-1)) begin
                        state <= INC_Y;
                        vga_y <= vga_y + 1;
                    end
                    else begin
                        vga_x <= vga_x + 1;
                        
								if (vga_x + 1 <= (width-1))
                            vga_colour[1] <= mem[vga_y*(width)+vga_x+1];
                        else 
                            vga_colour[1] <= 0;
								
                    end
                end
                INC_Y: begin
                    if (vga_y > height-1) begin
                        state <= STALL;
                        count <= 0;
                        vga_colour[1] <= 0;
                        //done <= 1; // REMOVE LATER
                    end
                    else begin
                        state <= INC_X;
                        vga_x <= 0;
                        vga_colour[1] <= mem[vga_y*width];
                    end
                end
					 STALL: begin
					     if (count >= 7332000) begin
						      state <= RUN;
								game_clk <= 1;
						  end
						  count <= count + 1;
					 end
            endcase
        end
    end
endmodule: gameOfLife

