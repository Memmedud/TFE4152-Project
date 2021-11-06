`timescale 1 ns / 1 ps

//====================================================================
// Testbench for pixelSensor
// - clock
// - instanciate pixel
// - State Machine for controlling pixel sensor
// - Model the ADC and ADC
// - Readout of the databus
// - Stuff neded for testbench. Store the output file etc.
//====================================================================
module pixelSensor_tb;

   //------------------------------------------------------------
   // Testbench clock
   //------------------------------------------------------------
   logic clk =0;
   logic reset =0;
   parameter integer clk_period = 500;
   parameter integer sim_end = clk_period*2400;
   always #clk_period clk=~clk;

   //------------------------------------------------------------
   // Pixel
   //------------------------------------------------------------
   parameter real    dv_pixel = 0.5;  //Set the expected photodiode current (0-1)

   //Analog signals
   logic              anaBias1;
   logic              anaRamp;
   logic              anaReset;
   logic start = 0;

   //Tie off the unused lines
   assign anaReset = 1;

   //Digital
   wire              erase;
   wire              expose;
   logic[3:0]        read;
   logic             reading;
   wire              convert;

   tri[7:0]         pixData; //  We need this to be a wire, because we're tristating it

   //Instanciate the pixel
   PixelArray ps1(anaBias1, anaRamp, anaReset, erase, expose, read, pixData);

   pixelArrayFsm #(.c_erase(5),.c_expose(255),.c_convert(255),.c_read(5))
   fsm1(.clk(clk),.reset(reset), .start(start),.erase(erase),.expose(expose),.read(read),.reading(reading),.convert(convert));


   //------------------------------------------------------------
   // DAC and ADC model
   //------------------------------------------------------------
   logic[7:0] data;

   // If we are to convert, then provide a clock via anaRamp
   // This does not model the real world behavior, as anaRamp would be a voltage from the ADC
   // however, we cheat
   assign anaRamp = convert ? clk : 0;

   // During expoure, provide a clock via anaBias1.
   // Again, no resemblence to real world, but we cheat.
   assign anaBias1 = expose ? clk : 0;

   // If we're not reading the pixData, then we should drive the bus
   assign pixData = reading ? 8'bZ: data;

   // When convert, then run a analog ramp (via anaRamp clock) and digtal ramp via
   // data bus.
   always_ff @(posedge clk or posedge reset) begin
      if(reset) begin
         data = 0;
      end
      if(convert) begin
         data +=  1;
      end
      else begin
         data = 0;
      end
   end // always @ (posedge clk or reset)

   //------------------------------------------------------------
   // Readout from databus
   //------------------------------------------------------------
   logic [7:0] pixelDataOut;
   always_ff @(posedge clk or posedge reset) begin
      if(reset) begin
         pixelDataOut = 8'bZZZZZZZZ;
      end
      else begin
         if(reading)
           pixelDataOut <= pixData;
         else
            pixelDataOut = 8'bZZZZZZZZ;
      end
   end

   //------------------------------------------------------------
   // Testbench stuff
   //------------------------------------------------------------
   initial
     begin
        $dumpfile("Output.vcd");
        $dumpvars(0,pixelSensor_tb);
        
         #clk_period
        reset = 1;

        #clk_period  reset=0;

        start = 1;

        #clk_period  start = 0;

        #sim_end
          $stop;

     end

endmodule // test