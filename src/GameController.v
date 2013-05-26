`timescale 1ns / 1ps

module GameController(
   input CLK,
   input FRAME_RENDERED,
   input BTN_LEFT,
   input BTN_RIGHT,
   input BTN_RELEASE,
   input SW_PAUSE,
   output [9:0] PADDLE_X_PIXEL,
   output [9:0] BALL_X_PIXEL,
   output [9:0] BALL_Y_PIXEL,
   output [71:0] BLOCK_STATE
   );

   reg reset = 1'b1;
   always @(posedge CLK) begin
      reset <= 1'b0;
   end

   GamePhysics physics(
      .CLK(CLK),
      .RESET(reset),
      .START_UPDATE(FRAME_RENDERED && !SW_PAUSE),
      .BTN_LEFT(BTN_LEFT),
      .BTN_RIGHT(BTN_RIGHT),
      .BTN_RELEASE(BTN_RELEASE),
      .PADDLE_X_PIXEL(PADDLE_X_PIXEL),
      .BALL_X_PIXEL(BALL_X_PIXEL),
      .BALL_Y_PIXEL(BALL_Y_PIXEL),
      .BLOCK_STATE(BLOCK_STATE)
   );
endmodule