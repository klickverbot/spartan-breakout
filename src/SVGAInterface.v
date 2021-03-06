`timescale 1ns / 1ps

/// Handles 800x600 @ 60 Hz video output, using 8 color bits.
///
/// The pixel clock is 40 MHz, timings taken from
/// http://tinyvga.com/vga-timing.
///
/// The position counters start at (0, 0) for the top left edge of the visible
/// area. Front porch/sync pulse/back porch follow after 800 resp. 600. This
/// should work, as the relative alignment of the sync pulses is not specified.
///
/// The color is treated as an opaque 8 bit value, although a 3R3G2B format will
/// typically be used.
module SVGAInterface(
   input CLK,
   input [7:0] COLOR_IN,
   output [10:0] X_PIXEL,
   output [9:0] Y_PIXEL,
   output reg [7:0] COLOR_OUT,
   output reg HSYNC,
   output reg VSYNC
   );

   // x timing contants.
   parameter visibleEndPixel = 11'd800;
   parameter frontPorchEndPixel = 11'd840;
   parameter hsyncEndPixel = 11'd968;
   parameter lineEndPixel = 11'd1056;

   // y timing constants.
   parameter visibleEndLine = 10'd600;
   parameter frontPorchEndLine = 10'd601;
   parameter vsyncEndLine = 10'd605;
   parameter frameEndLine = 10'd628;

   // Counter for the x coordinate.
   GenericCounter #(
      .COUNTER_WIDTH(11),
      .COUNTER_MAX(lineEndPixel - 1)
   ) xPixelCounter (
      .CLK(CLK),
      .RESET(1'b0),
      .ENABLE_IN(1'b1),
      .COUNT(X_PIXEL)
   );

   // Counter for the y coordinate. Note that we want it to flip when
   // X_PIXEL == 0, so we need to enable the counter not on xPixelCounter
   // overflow, but one frame before that.
   GenericCounter #(
      .COUNTER_WIDTH(10),
      .COUNTER_MAX(frameEndLine - 1)
   ) yLineCounter (
      .CLK(CLK),
      .RESET(1'b0),
      .ENABLE_IN(X_PIXEL == lineEndPixel - 1),
      .COUNT(Y_PIXEL)
   );

   // Generate sync signals. Both horizontal and vertical sync are specified
   // to be triggered on the positive edge for this mode.
   always @(posedge CLK) begin
      if (X_PIXEL >= frontPorchEndPixel && X_PIXEL < hsyncEndPixel) begin
         HSYNC <= 1'b1;
      end else begin
         HSYNC <= 1'b0;
      end

      if (Y_PIXEL >= frontPorchEndLine && Y_PIXEL < vsyncEndLine) begin
         VSYNC <= 1'b1;
      end else begin
         VSYNC <= 1'b0;
      end
   end

   // If in the visible area, pull in the new color.
   always @(posedge CLK) begin
      if (X_PIXEL < visibleEndPixel && Y_PIXEL < visibleEndLine) begin
         COLOR_OUT <= COLOR_IN;
      end else begin
         COLOR_OUT <= 8'b0;
      end
   end
endmodule
