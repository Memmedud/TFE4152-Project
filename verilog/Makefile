
ps:
	iverilog -g2012 -o pixelSensor -c pixelSensorFsm.fl
	vvp -n pixelSensor

ysfsm:
	yosys pixelSensorFsm.ys
	dot pixelSensorFsm.dot -Tpng > pixelSensorFsm.png
