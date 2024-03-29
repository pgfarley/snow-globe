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

   
    parameter H_ACTIVE = 640;
    parameter H_FRONT_PORCH = 16;
    parameter H_SYNC_PULSE = 96;
    parameter H_BACK_PORCH = 48;
    
    //  Max sx value. Includes blanking region.
    localparam H_LAST_POSITION = H_ACTIVE 
                       + H_FRONT_PORCH 
                       + H_SYNC_PULSE 
                       + H_BACK_PORCH 
                       - 1;
    
    localparam H_ACTIVE_END_POSITION = H_ACTIVE - 1;
    localparam H_SYNC_START_POSITION = H_ACTIVE_END_POSITION + H_FRONT_PORCH;
    localparam H_SYNC_END_POSITION = H_SYNC_START_POSITION + H_SYNC_PULSE;

    parameter V_ACTIVE = 480;
    parameter V_FRONT_PORCH = 11;
    parameter V_SYNC_PULSE = 2;
    parameter V_BACK_PORCH = 31;
    
    //  Max sy value. Includes blanking region.
    localparam V_LAST_POSITION = V_ACTIVE 
                       + V_FRONT_PORCH 
                       + V_SYNC_PULSE 
                       + V_BACK_PORCH 
                       - 1;
    
    localparam V_ACTIVE_END_POSITION = V_ACTIVE - 1;
    localparam V_SYNC_START_POSITION = V_ACTIVE_END_POSITION + V_FRONT_PORCH;
    localparam V_SYNC_END_POSITION = V_SYNC_START_POSITION + V_SYNC_PULSE;

    
    always_comb begin
        // invert: syncs have negative polarity
        hsync = ~(sx >= H_SYNC_START_POSITION && sx < H_SYNC_END_POSITION);
        vsync = ~(sy >= V_SYNC_START_POSITION && sy < V_SYNC_END_POSITION);
        de = (sx <= H_ACTIVE_END_POSITION && sy <= V_ACTIVE_END_POSITION);
    end

    // calculate horizontal and vertical screen position
    always_ff @(posedge clk_pix) begin
        if (sx == H_LAST_POSITION) begin
            sx <= 0;
            sy <= (sy == V_LAST_POSITION) ? 0 : sy + 1;
        end else begin
            sx <= sx + 1;
        end
        if (rst_pix) begin
            sx <= 0;
            sy <= 0;
        end
    end
endmodule
