
ps:
	iverilog -g2012 -o Output -c pixelSensor.fl
	vvp -n Output

ysfsm:
	yosys pixelSensorFsm.ys
	dot pixelSensorFsm.dot -Tpng > pixelSensorFsm.png
