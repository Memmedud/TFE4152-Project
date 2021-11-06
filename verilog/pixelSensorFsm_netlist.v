/* Generated by Yosys 0.9 (git sha1 1979e0b1, gcc 10.3.0-1ubuntu1~20.10 -fPIC -Os) */

(* top =  1  *)
(* src = "FSM.v:3" *)
module pixelArrayFsm(clk, reset, start, erase, expose, read, reading, convert);
  (* src = "FSM.v:4" *)
  input clk;
  (* src = "FSM.v:11" *)
  output convert;
  (* src = "FSM.v:26" *)
  wire [16:0] counter;
  (* src = "FSM.v:7" *)
  output erase;
  (* src = "FSM.v:8" *)
  output expose;
  (* src = "FSM.v:24" *)
  wire [2:0] next_state;
  (* src = "FSM.v:9" *)
  output [3:0] read;
  (* src = "FSM.v:25" *)
  wire [2:0] readState;
  (* src = "FSM.v:10" *)
  output reading;
  (* src = "FSM.v:5" *)
  input reset;
  (* src = "FSM.v:6" *)
  input start;
  (* src = "FSM.v:24" *)
  wire [2:0] state;
  assign convert = 1'h0;
  assign counter = 17'h00000;
  assign erase = 1'h0;
  assign expose = 1'h0;
  assign next_state = 3'h4;
  assign read = 4'h0;
  assign readState = 3'h4;
  assign reading = 1'h0;
  assign state = 3'h4;
endmodule
