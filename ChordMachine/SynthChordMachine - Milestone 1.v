//Ian Webster and Karman Lochab
//ECE241 Final Project
//11-9-19 

//Milestone 1: Proof of concept with LEDs instead of audio
//I.e. store the chord combinations in registers, and output the combinations in the form 
//of different LEDs lighting up instead of different notes.


//If SW[9:0] = 0, then in WRITE/LOADING MODE
//If SW[9:0] != 0, then in PLAY MODE

/*
	• Flip SW[9:0] to store individual notes in a 10-bit register (a single “chord”), then activate/send all 
	the selected pitches through the audio output when a key corresponding to the register is pressed. 
	(plays all those notes of switches activated)
	• EX: for KEY[0], it should play the corresponding pitches for whichever register[0] outputs are high. 
	(Play the pitches at the same time). I.e. the register values that are high will each play a corresponding 
	tone from the audio IP core. 
	• Store 4 chords in 4 registers, selectable via KEY[3:0].
	- Hitting the keys plays the chords.
*/

module ChordMachine1Top(CLOCK_50, SW, KEY, LEDR); //add finalOut if want register.
	input CLOCK_50;
	input [9:0] SW;
	input [3:0] KEY;
	output [9:0] LEDR;
	
	wire [9:0] qbus0;
	wire [9:0] qbus1;
	wire [9:0] qbus2;
	wire [9:0] qbus3;
	wire [9:0] finalOutBus = finalOut;
	reg [9:0] finalOut;
	//To show switch outputs when in write mode:
	assign LEDR[9:0] = writeEn ? SW : finalOutBus; //Show note outputs for current chord register on LEDs
	//This LEDR can become a wire bus to send data to a bunch of note-producing modules.
	
	wire writeEn;
	assign writeEn = (SW[9:0] != 0); //If @ least 1 switch selected, in WRITE MODE. If NO switches are selected, in PLAY mode.
	
	//NOTE: KEY IS INVERTED BEFORE BEING SENT IN.
	chordRegister c3(.sw(SW[9:0]), .clk(CLOCK_50), .key(~KEY[3]), .writeEn(writeEn), .q(qbus3[9:0]));
	chordRegister c2(.sw(SW[9:0]), .clk(CLOCK_50), .key(~KEY[2]), .writeEn(writeEn), .q(qbus2[9:0]));
	chordRegister c1(.sw(SW[9:0]), .clk(CLOCK_50), .key(~KEY[1]), .writeEn(writeEn), .q(qbus1[9:0]));
	chordRegister c0(.sw(SW[9:0]), .clk(CLOCK_50), .key(~KEY[0]), .writeEn(writeEn), .q(qbus0[9:0]));
	
	//mux - ORIGINAL
	//assign finalOut = (writeEn ? 10'd0 : ~KEY[0] ? qbus0 : ~KEY[1] ? qbus1 : ~KEY[2] ? qbus2 : ~KEY[3] ? qbus3 : 10'd0); 
	
	//Play mode
	//assign finalOut = (~writeEn & (~KEY[0] | ~KEY[1] | ~KEY[2] | ~KEY[3])) ? qbus : 10'b0; //If read enabled and key pressed, send qbus to finalOut to the LEDS, assign 0 if writing
	
	//PLAY MODE 
	always @ (*) begin
		if (writeEn == 1'b0) begin //i.e. in read/PLAY mode:
			if (~KEY[0]) begin 
				for (finalOut[n] = 0 && qbus0[n] = 1; n < 10; n++) 
					finalOut[n] = 1; //Bitwise and will allow multiple chords to be played simultaneously
			end
			if (~KEY[1]) finalOut = finalOut + qbus1;
			if (~KEY[2]) finalOut = finalOut + qbus2;
			if (~KEY[3]) finalOut = finalOut + qbus3;
		end
		else 
			finalOut = 0; //Therefore in write mode; don't output sound from chord machine.
	end
	
	

endmodule

//Instantiate 4 of these 10-bit note registers to store 4 different chords, which can be selected via a keypress.
//**Want the keypress to activate it's register's outputs (notes) for only as long as the key is pressed.
module chordRegister(sw, clk, key, writeEn, q);

	input [9:0] sw;
	input clk;
	input key;
	input writeEn;
	output reg [9:0] q;
	
	always @ (posedge clk) begin
		if (key == 1'b1) begin
			if (writeEn == 1'b1) begin
				q <= sw;
			end
		end
	end
	
endmodule

















