`timescale 1 ns / 1 ps

module pixelArrayFsm(
   input  logic clk,
   input  logic reset,
   input  logic start,
   output logic erase = 0,
   output logic expose = 0,
   output [3:0] read = 0,
   output logic reading,
   output logic convert = 0
   );

   //State duration in clock cycles
   parameter integer c_erase = 10;
   parameter integer c_expose = 255;
   parameter integer c_convert = 255;
   parameter integer c_read = 10;

   parameter ERASE=0, EXPOSE=1, CONVERT=2, READ=3, IDLE=4;
   parameter READ0 = 0, READ1 = 1, READ2 = 2, READ3 = 3, NOREAD = 4;

   logic          convert_stop;
   logic [2:0]    state, next_state;   //States
   logic [2:0]    readState;
   integer        counter;
   
   // Control the output signals
   always_ff @(negedge clk ) begin
      case(state)
        ERASE: begin
           erase <= 1;
           expose <= 0;
           convert <= 0;
        end
        EXPOSE: begin
           erase <= 0;
           expose <= 1;
           convert <= 0;
        end
        CONVERT: begin
           erase <= 0;
           expose <= 0;
           convert = 1;
        end
        READ: begin
           erase <= 0;
           expose <= 0;
           convert <= 0;
        end
        IDLE: begin
           erase <= 0;
           expose <= 0;
           convert <= 0;
        end
      endcase

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
         convert  = 0;
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
                     //$display("read0");
                  end
                  READ1: begin
                     readState = READ2;
                     next_state = READ;
                     state = IDLE;
                     //$display("read1");
                  end
                  READ2: begin
                     readState = READ3;
                     next_state = READ;
                     state = IDLE;
                     //$display("read2");
                  end
                  READ3: begin
                     readState = NOREAD;
                     next_state = IDLE;
                     state = IDLE;
                     //$display("read3"); 
                  end
                  endcase
              end
           end
           IDLE: state <= next_state;
         endcase
      
         if(state == IDLE) counter = 0;
         else counter = counter + 1;
   end

endmodule