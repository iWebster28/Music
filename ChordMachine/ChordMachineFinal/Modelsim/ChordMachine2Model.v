
//4-Bit Shift Register (to be instantiated 4 times for 4 different chords.)
module shiftReg4bit(D, clk, loopEn, BPMShiftEn, Q, key, trackLEDIn, Qstatic);
	//Qstatic is the initial load pattern of Q. Does not shift. Used to show on LEDs where you placed a note rhythmically.
	
	output reg [3:0] Qstatic;
	input trackLEDIn; //activated if the tracking LED has instantiated this module
	reg trackLED;
	
	input key;
	input [3:0] D;
	input clk;
	input loopEn;
	input BPMShiftEn;
	output reg [3:0] Q; //shifting output register	
	
	always @ (posedge clk) begin

		//trackLED <= trackLEDIn; //For Tracking LED
		if (trackLED < 1 & trackLEDIn) begin //One-time load if this is the counter!
			Q <= D;
			trackLED <= trackLED + 1; //(2/50000000ths) of a second to ensure Q loads! 
		end
		
		if (loopEn & key) begin //SW[5] must be on, and the key must be pressed to set the chord into position for this chord loop. - HAVING key HERE WILL PREVENT FROM PLAYING DURING LOOP!!!!!!!!!
			Q <= D; //load the shift register
			Qstatic <= D;
		end
		
		if (loopEn & BPMShiftEn) //Load right bit to shift bits left.
		begin 
			Q[3] <= Q[0];
			Q[2] <= Q[3];
			Q[1] <= Q[2];
			Q[0] <= Q[1];
		end
		
		if (!loopEn) begin
			Q <= 4'b000; //reset when looper mode turned off.
		end
	end

endmodule