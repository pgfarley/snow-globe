`default_nettype none
`timescale 1ns / 1ps

module top_snow_globe (
    input  wire logic clk_12m,      // 12 MHz clock
    input  wire logic btn_rst,      // reset button
    output      logic vga_hsync,    // VGA horizontal sync
    output      logic vga_vsync,    // VGA vertical sync
    output      logic [3:0] vga_r,  // 4-bit VGA red
    output      logic [3:0] vga_g,  // 4-bit VGA green
    output      logic [3:0] vga_b   // 4-bit VGA blue
    );


    reg [15:0] lfsr_slow;
    reg [15:0] lfsr_fast;
    reg [15:0] lfsr_fastest;


    // generate pixel clock
    logic clk_pix;
    logic clk_pix_locked;
    clock_480p clock_pix_inst (
       .clk_12m,
       .rst(btn_rst),
       .clk_pix,
       .clk_pix_locked
    );

    // display sync signals and coordinates
    localparam CORDW = 10;  // screen coordinate width in bits
    logic [CORDW-1:0] sx, sy;
    logic hsync, vsync, de;
    simple_480p display_inst (
        .clk_pix,
        .rst_pix(!clk_pix_locked),  // wait for clock lock
        .sx,
        .sy,
        .hsync,
        .vsync,
        .de
    );


  reg [4:0] screen_count;
  reg [4:0] last_screen_count;
  wire new_screen = sy == 0 & sx == 0;
  
  reg [2:0] screen_mem [255*255-1:0];
  wire is_snow;
  
  always @(posedge clk_pix)
    begin
      if (btn_rst) begin
        last_screen_count <= 0;
        screen_count <= 0;

      end else begin
        if (new_screen) begin
           last_screen_count <= screen_count;
           screen_count <= screen_count + 1;
        end
      end
    end
  
  always @(posedge clk_pix) begin
      if (snow_slow)
        screen_mem[{sy[7:0],sx[7:0]}][0] <= &lfsr_slow[14:8];
 
      if (snow_fast)
        screen_mem[{sy[7:0],sx[7:0]}][1] <= &lfsr_fast[15:8];

      if (snow_fastest)
        screen_mem[{sy[7:0],sx[7:0]}][2] <= &lfsr_fastest[13:8];
  end

  
    
  wire snow_slow = ~(sy > 255) & ~(sx > 254) & screen_count[2] & ~last_screen_count[2];
  wire snow_fast = ~(sy > 255) & ~(sx > 254) & screen_count[1] & ~last_screen_count[1];
  wire snow_fastest = ~(sy > 255) & ~(sx > 254) & screen_count[0] & ~last_screen_count[0];



  lfsr #(.LEN(16), .TAPS(16'b1101000000001000)) lfsr_gen_slow(
    .clk(clk_pix),
    .rst(btn_rst),
    .en(snow_slow),
    .seed(16'd0),
    .sreg(lfsr_slow));

  lfsr #(.LEN(16), .TAPS(16'b1101000000001000)) lfsr_gen_fast(
    .clk(clk_pix),
    .rst(btn_rst),
    .en(snow_fast),
    .seed(16'd0),
    .sreg(lfsr_fast));

  lfsr #(.LEN(16), .TAPS(16'b1101000000001000)) lfsr_gen_fastest(
    .clk(clk_pix),
    .rst(btn_rst),
    .en(snow_fastest),
    .seed(16'd0),
    .sreg(lfsr_fastest));

  ;

    wire is_snow = |screen_mem[{sy[7:0],sx[7:0]}] ? 7 : 0;


    always_ff @(posedge clk_pix) begin
        vga_hsync <= hsync;
        vga_vsync <= vsync;
        if (de) begin

            vga_r <= {4{is_snow}};
            vga_g <= {4{is_snow}};
            vga_b <= {4{is_snow}};
        end else begin  // VGA colour should be black in blanking interval
            vga_r <= 0;
            vga_g <= 0;
            vga_b <= 0;
        end
    end
endmodule
