// Modified from simple_480p.sv. Copywrite reproduced below.
//
// Project F: FPGA Graphics - Simple 640x480p60 Display
// (C)2022 Will Green, open source hardware released under the MIT License
// Learn more at https://projectf.io/posts/fpga-graphics/

`default_nettype none
`timescale 1ns / 1ps

module simple_480p (
    input  wire logic clk_pix,   // pixel clock
    input  wire logic rst_pix,   // reset in pixel clock domain
    output      logic [9:0] sx,  // horizontal screen position
    output      logic [9:0] sy,  // vertical screen position
    output      logic hsync,     // horizontal sync
    output      logic vsync,     // vertical sync
    output      logic de         // data enable (low in blanking interval)
    );

   
    parameter HORIZONTAL_ACTIVE = 640;
    parameter HORIZONTAL_FRONT_PORCH = 16;
    parameter HORIZONTAL_SYNC_PULSE = 96;
    parameter HORIZONTAL_BACK_PORCH = 48;
    
    //  Max sx value. Includes blanking region.
    localparam HORIZONTAL_LAST_POSITION = HORIZONTAL_ACTIVE 
                       + HORIZONTAL_FRONT_PORCH 
                       + HORIZONTAL_SYNC_PULSE 
                       + HORIZONTAL_BACK_PORCH 
                       - 1;
    
    localparam HORIZONTAL_ACTIVE_END_POSITION = HORIZONTAL_ACTIVE - 1;
    localparam HORIZONTAL_SYNC_START_POSITION = HORIZONTAL_ACTIVE_END_POSITION 
                                               + HORIZONTAL_FRONT_PORCH;
    localparam HORIZONTAL_SYNC_END_POSITION = HORIZONTAL_SYNC_START_POSITION 
                                             + HORIZONTAL_SYNC_PULSE;

    // vertical timings
    parameter VA_END = 479;           // end of active pixels
    parameter VS_STA = VA_END + 10;   // sync starts after front porch
    parameter VS_END = VS_STA + 2;    // sync ends
    parameter SCREEN = 524;           // last line on screen (after back porch)

    always_comb begin
        // invert: syncs have negative polarity
        hsync = ~(sx >= HORIZONTAL_SYNC_START_POSITION && sx < HORIZONTAL_SYNC_END_POSITION);
        vsync = ~(sy >= VS_STA && sy < VS_END);
        de = (sx <= HORIZONTAL_ACTIVE_END_POSITION && sy <= VA_END);
    end

    // calculate horizontal and vertical screen position
    always_ff @(posedge clk_pix) begin
        if (sx == HORIZONTAL_LAST_POSITION) begin
            sx <= 0;
            sy <= (sy == SCREEN) ? 0 : sy + 1;  // last line on screen?
        end else begin
            sx <= sx + 1;
        end
        if (rst_pix) begin
            sx <= 0;
            sy <= 0;
        end
    end
endmodule
