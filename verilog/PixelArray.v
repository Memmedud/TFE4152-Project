
module PixelArray
(   
   input logic      VBN1,
   input logic      RAMP,
   input logic      RESET,
   input logic      ERASE,
   input logic      EXPOSE,
   input [3:0]      READ,
   inout [7:0]      DATA
);

parameter real    dv_pixel1 = 0.5; //Number between 0 and 1
parameter real    dv_pixel2 = 0.55; //Number between 0 and 1
parameter real    dv_pixel3 = 0.3; //Number between 0 and 1
parameter real    dv_pixel4 = 0.75; //Number between 0 and 1

//Instanciate pixels
PIXEL_SENSOR #(.dv_pixel(dv_pixel1)) p1(VBN1, RAMP, RESET, ERASE, EXPOSE, READ[0], DATA);
PIXEL_SENSOR #(.dv_pixel(dv_pixel2)) p2(VBN1, RAMP, RESET, ERASE, EXPOSE, READ[1], DATA);
PIXEL_SENSOR #(.dv_pixel(dv_pixel3)) p3(VBN1, RAMP, RESET, ERASE, EXPOSE, READ[2], DATA);
PIXEL_SENSOR #(.dv_pixel(dv_pixel4)) p4(VBN1, RAMP, RESET, ERASE, EXPOSE, READ[3], DATA);

endmodule
