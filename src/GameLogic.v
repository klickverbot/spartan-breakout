`timescale 1ns / 1ps

/// The main game logic updating the game state once per frame.
///
/// To be able to use a simple collision detection approach, the logic
/// internally runs in three steps, i.e. effectively at 180 Hz.
module GameLogic(
   input CLK,
   input START_UPDATE,
   input BTN_LEFT,
   input BTN_RIGHT,
   output reg [9:0] PADDLE_X_PIXEL,
   output reg [9:0] BALL_X_PIXEL,
   output reg [9:0] BALL_Y_PIXEL
   );

   parameter PADDLE_LENGTH_PIXEL = 10'd60;

   initial begin
      PADDLE_X_PIXEL <= 10'd370;
      BALL_X_PIXEL <= 10'd395;
      BALL_Y_PIXEL = 10'd400;
   end

   parameter paddleSpeed = 10'd1;
   parameter gameBeginXPixel = 10'd8;
   parameter gameEndXPixel = 10'd792;

   // After we got the okay, run the update logic for three clock cycles.
   reg doUpdate = 1'b0;
   reg [1:0] updateCounter = 2'h0;

   always @(posedge CLK) begin
      if (doUpdate) begin
         if (updateCounter == 2'h2) begin
            doUpdate <= 1'b0;
            updateCounter <= 2'h0;
         end else begin
            updateCounter <= updateCounter + 2'h1;
         end
      end else if (START_UPDATE) begin
         doUpdate <= 1'b1;
      end
   end

   // Handle button input.
   always @(posedge CLK) begin
      if (doUpdate) begin
         if (!(BTN_LEFT && BTN_RIGHT)) begin
            if (BTN_LEFT) begin
               if (PADDLE_X_PIXEL < gameBeginXPixel + paddleSpeed) begin
                  PADDLE_X_PIXEL <= gameBeginXPixel;
               end else begin
                  PADDLE_X_PIXEL <= PADDLE_X_PIXEL - paddleSpeed;
               end
            end

            if (BTN_RIGHT) begin
               if (PADDLE_X_PIXEL > gameEndXPixel - PADDLE_LENGTH_PIXEL - paddleSpeed) begin
                  PADDLE_X_PIXEL <= gameEndXPixel - PADDLE_LENGTH_PIXEL;
               end else begin
                  PADDLE_X_PIXEL <= PADDLE_X_PIXEL + paddleSpeed;
               end
            end
         end
      end
   end
endmodule
