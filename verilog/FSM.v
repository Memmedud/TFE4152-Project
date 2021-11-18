//====================================================================
//        Copyright (c) 2021 Carsten Wulff Software, Norway
// ===================================================================
// Created       : wulff at 2021-7-21
// ===================================================================
//  The MIT License (MIT)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
//====================================================================
`timescale 1 ns / 1 ps

module pixelArrayFsm(
   input  logic clk, reset, start,
   output logic erase = 0,
   output logic expose = 0,
   output [3:0] read = 0,
   output logic reading,
   output logic convert = 0);

   //State duration in clock cycles
   parameter integer c_erase = 10, c_expose = 255, c_convert = 255, c_convert = 255;

   parameter ERASE=0, EXPOSE=1, CONVERT=2, READ=3, IDLE=4;
   parameter READ0 = 0, READ1 = 1, READ2 = 2, READ3 = 3, NOREAD = 4;

   logic [2:0] state, next_state, readState;

   logic [9:0] counter;
   
   // Control the output signals
   always_comb begin
      case(state)
        ERASE: begin
           erase = 1; expose = 0; convert = 0;
        end
        EXPOSE: begin
           erase = 0; expose = 1; convert = 0;
        end
        CONVERT: begin
           erase = 0; expose = 0; convert = 1;
        end
        READ: begin
           erase = 0; expose = 0; convert = 0;
        end
        IDLE: begin
           erase = 0; expose = 0; convert = 0;
        end
      endcase
   end

   always_comb begin
      case (readState)
         NOREAD: read = 4'b0000;
         READ0: read = 4'b0001;
         READ1: read = 4'b0010;
         READ2: read = 4'b0100;
         READ3: read = 4'b1000;
      endcase
   end
   
   always_comb begin
      if (readState == NOREAD) reading = 0;
      else reading = 1;
   end

   always_ff @(posedge start) begin
      if (state == IDLE) next_state = ERASE;
   end

   always_ff @(posedge reset) begin
      if(reset) begin
         state = IDLE;
         next_state = IDLE;
         readState = NOREAD;
         counter  = 0;
      end
   end

   always_ff @(posedge clk) begin
         case (state)
           ERASE: begin
              if(counter == c_erase) begin
                 next_state <= EXPOSE;
                 state <= IDLE;
              end
           end
           EXPOSE: begin
              if(counter == c_expose) begin
                 next_state <= CONVERT;
                 state <= IDLE;
              end
           end
           CONVERT: begin
              if(counter == c_convert) begin
                 next_state <= READ;
                 state <= IDLE;
              end
           end
           READ: begin
              if (readState == NOREAD) begin 
                 readState = READ0; 
                 next_state = READ;
                 state = IDLE;
              end

              if (counter == c_read) begin
                  case (readState)
                  READ0: begin
                     readState = READ1;
                     next_state = READ;
                     state = IDLE;
                  end
                  READ1: begin
                     readState = READ2;
                     next_state = READ;
                     state = IDLE;
                  end
                  READ2: begin
                     readState = READ3;
                     next_state = READ;
                     state = IDLE;
                  end
                  READ3: begin
                     readState = NOREAD;
                     next_state = IDLE;
                     state = IDLE;
                  end
                  endcase

              end
           end
           IDLE: state <= next_state;
         endcase
      
         if (state == IDLE) counter = 0;
         else counter = counter + 1;
   end

endmodule