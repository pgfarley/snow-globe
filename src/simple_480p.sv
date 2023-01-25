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

    parameter VERTICAL_ACTIVE = 480;
    parameter VERTICAL_FRONT_PORCH = 11;
    parameter VERTICAL_SYNC_PULSE = 2;
    parameter VERTICAL_BACK_PORCH = 31;
    
    //  Max sy value. Includes blanking region.
    localparam VERTICAL_LAST_POSITION = VERTICAL_ACTIVE 
                       + VERTICAL_FRONT_PORCH 
                       + VERTICAL_SYNC_PULSE 
                       + VERTICAL_BACK_PORCH 
                       - 1;
    
    localparam VERTICAL_ACTIVE_END_POSITION = VERTICAL_ACTIVE - 1;
    localparam VERTICAL_SYNC_START_POSITION = VERTICAL_ACTIVE_END_POSITION 
                                              + VERTICAL_FRONT_PORCH;
    localparam VERTICAL_SYNC_END_POSITION = VERTICAL_SYNC_START_POSITION 
                                            + VERTICAL_SYNC_PULSE;

    
    always_comb begin
        // invert: syncs have negative polarity
        hsync = ~(sx >= HORIZONTAL_SYNC_START_POSITION && sx < HORIZONTAL_SYNC_END_POSITION);
        vsync = ~(sy >= VERTICAL_SYNC_START_POSITION && sy < VERTICAL_SYNC_END_POSITION);
        de = (sx <= HORIZONTAL_ACTIVE_END_POSITION && sy <= VERTICAL_ACTIVE_END_POSITION);
    end

    // calculate horizontal and vertical screen position
    always_ff @(posedge clk_pix) begin
        if (sx == HORIZONTAL_LAST_POSITION) begin
            sx <= 0;
            sy <= (sy == VERTICAL_LAST_POSITION) ? 0 : sy + 1;
        end else begin
            sx <= sx + 1;
        end
        if (rst_pix) begin
            sx <= 0;
            sy <= 0;
        end
    end
endmodule
