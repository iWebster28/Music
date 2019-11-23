
module ChordMachine2 (
	// Inputs
	CLOCK_50,
	KEY,

	AUD_ADCDAT,

	// Bidirectionals
	AUD_BCLK,
	AUD_ADCLRCK,
	AUD_DACLRCK,

	FPGA_I2C_SDAT,

	// Outputs
	AUD_XCK,
	AUD_DACDAT,

	FPGA_I2C_SCLK,
	SW,
	LEDR
);

	/*****************************************************************************
	 *                           Parameter Declarations                          *
	 *****************************************************************************/


	/*****************************************************************************
	 *                             Port Declarations                             *
	 *****************************************************************************/
	// Inputs
	input				CLOCK_50;
	input		[3:0]	KEY;
	input		[9:0]	SW;

	input				AUD_ADCDAT;

	// Bidirectionals
	inout				AUD_BCLK;
	inout				AUD_ADCLRCK;
	inout				AUD_DACLRCK;

	inout				FPGA_I2C_SDAT;

	// Outputs
	output				AUD_XCK;
	output				AUD_DACDAT;

	output				FPGA_I2C_SCLK;

	output [9:0] LEDR;

	/*****************************************************************************
	 *                 Internal Wires and Registers Declarations                 *
	 *****************************************************************************/
	// Internal Wires
	wire				audio_in_available;
	wire		[31:0]	left_channel_audio_in;
	wire		[31:0]	right_channel_audio_in;
	wire				read_audio_in;

	wire				audio_out_allowed;
	wire		[31:0]	left_channel_audio_out;
	wire		[31:0]	right_channel_audio_out;
	wire				write_audio_out;
	
	wire [20:0] delay_cnt0, delay_cnt1, delay_cnt2, delay_cnt3, delay_cnt4, delay_cnt5, delay_cnt6, delay_cnt7, delay_cnt8; //were reg signed. now in module.
	wire [20:0] delay, delay2, delay3, delay4, delay5, delay6, delay7, delay8;

	wire snd0, snd1, snd2, snd3, snd4, snd5, snd6, snd7, snd8; //(were reg - but now reg is in the module. Just need a bus to connect to outs here.)

	// Internal Registers

	// State Machine Registers

	/*****************************************************************************
	 *                         Finite State Machine(s)                           *
	 *****************************************************************************/


	/*****************************************************************************
	 *                             Sequential Logic                              *
	 *****************************************************************************/


	/*****************************************************************************
	 *                            Combinational Logic                            *
	 *****************************************************************************/

	//assign delay = {SW[3:0], 15'd3000};

	parameter clock = 50000000;
	parameter A4 = clock/440;
	parameter Bb4 = clock/466;
	parameter B4 = clock/494;
	parameter C5 = clock/523;
	parameter Db5 = clock/554;
	parameter D5 = clock/587;
	parameter Eb5 = clock/622;
	parameter E5 = clock/659;
	parameter F5 = clock/698;
	parameter Gb5 = clock/740;
	parameter G5 = clock/784;
	parameter Ab5 = clock/831;
	parameter A5 = clock/880;
	parameter Bb5 = clock/932;
	parameter B5 = clock/988;

	//parameter maxAmplitude = 32'd10000000;
	/*parameter A4 = clock/440;
	parameter Bb4 = clock/466.1638;
	parameter B4 = clock/493.8833;
	parameter C5 = clock/523.2511;
	parameter Db5 = clock/554.3653;
	parameter D5 = clock/587.3295;
	parameter Eb5 = clock/622.2540;
	parameter E5 = clock/659.2551;
	parameter F5 = clock/698.4565;
	parameter Gb5 = clock/739.9888;
	parameter G5 = clock/783.9909;
	parameter Ab5 = clock/830.6094;
	parameter A5 = clock/880.0000;*/
	//parameter frequency = (2 ** ((n-49)/12))*440; // A4 = A440 is 49th key (n = key) ** is to the power of

	wire squareEn = SW[9];
	wire triEn = SW[8];
	wire sawEn = SW[7];
	wire phaseEn = SW[6];

	parameter phaseDiff = 2;

	//WAVE GENERATION MODULE INSTANTIATION
	//squareWave(CLOCK_50, snd, delay);
	squareWave s0(CLOCK_50, squareOut0, A4, squareEn);
	squareWave s1(CLOCK_50, squareOut1, B4, squareEn);
	squareWave s2(CLOCK_50, squareOut2, C5, squareEn);
	squareWave s3(CLOCK_50, squareOut3, D5, squareEn);
	squareWave s4(CLOCK_50, squareOut4, E5, squareEn);
	squareWave s5(CLOCK_50, squareOut5, F5, squareEn);
	squareWave s6(CLOCK_50, squareOut6, G5, squareEn);
	squareWave s7(CLOCK_50, squareOut7, A5, squareEn);
	squareWave s8(CLOCK_50, squareOut8, B5, squareEn);

	squareWave s0p(CLOCK_50, squareOut0p, A4 + A4/phaseDiff, squareEn & phaseEn);
	squareWave s1p(CLOCK_50, squareOut1p, B4 + B4/phaseDiff, squareEn & phaseEn);
	squareWave s2p(CLOCK_50, squareOut2p, C5 + C5/phaseDiff, squareEn & phaseEn);
	squareWave s3p(CLOCK_50, squareOut3p, D5 + D5/phaseDiff, squareEn & phaseEn);
	squareWave s4p(CLOCK_50, squareOut4p, E5 + E5/phaseDiff, squareEn & phaseEn);
	squareWave s5p(CLOCK_50, squareOut5p, F5 + F5/phaseDiff, squareEn & phaseEn);
	squareWave s6p(CLOCK_50, squareOut6p, G5 + G5/phaseDiff, squareEn & phaseEn);
	squareWave s7p(CLOCK_50, squareOut7p, A5 + A5/phaseDiff, squareEn & phaseEn);
	squareWave s8p(CLOCK_50, squareOut8p, B5 + B5/phaseDiff, squareEn & phaseEn);
	
	
	sawWave st0(CLOCK_50, sawOut0, A4, sawEn);
	sawWave st1(CLOCK_50, sawOut1, B4, sawEn); //to put out of phase, just do B4 + 0.5*B4 right? for delay. Then 180 degrees out of phase?. Need two modules of same pitch playing at same time!
	sawWave st2(CLOCK_50, sawOut2, C5, sawEn);
	sawWave st3(CLOCK_50, sawOut3, D5, sawEn);
	sawWave st4(CLOCK_50, sawOut4, E5, sawEn);
	sawWave st5(CLOCK_50, sawOut5, F5, sawEn);
	sawWave st6(CLOCK_50, sawOut6, G5, sawEn);
	sawWave st7(CLOCK_50, sawOut7, A5, sawEn);
	sawWave st8(CLOCK_50, sawOut8, B5, sawEn);
	
	//Out-of Phase sawWave Generators (p is for phase)
	sawWave st0p(CLOCK_50, sawOut0p, A4 + A4/phaseDiff, sawEn & phaseEn);
	sawWave st1p(CLOCK_50, sawOut1p, B4 + B4/phaseDiff, sawEn & phaseEn); //to put out of phase, just do B4 + 0.5*B4 right? for delay. Then 180 degrees out of phase?. Need two modules of same pitch playing at same time!
	sawWave st2p(CLOCK_50, sawOut2p, C5 + C5/phaseDiff, sawEn & phaseEn);
	sawWave st3p(CLOCK_50, sawOut3p, D5 + D5/phaseDiff, sawEn & phaseEn);
	sawWave st4p(CLOCK_50, sawOut4p, E5 + E5/phaseDiff, sawEn & phaseEn);
	sawWave st5p(CLOCK_50, sawOut5p, F5 + F5/phaseDiff, sawEn & phaseEn);
	sawWave st6p(CLOCK_50, sawOut6p, G5 + G5/phaseDiff, sawEn & phaseEn);
	sawWave st7p(CLOCK_50, sawOut7p, A5 + A5/phaseDiff, sawEn & phaseEn);
	sawWave st8p(CLOCK_50, sawOut8p, B5 + B5/phaseDiff, sawEn & phaseEn);
	
	triWave t0(CLOCK_50, triOut0, A4, triEn);
	triWave t1(CLOCK_50, triOut1, B4, triEn); //to put out of phase, just do B4 + 0.5*B4 right? for delay. Then 180 degrees out of phase?. Need two modules of same pitch playing at same time!
	triWave t2(CLOCK_50, triOut2, C5, triEn);
	triWave t3(CLOCK_50, triOut3, D5, triEn);
	triWave t4(CLOCK_50, triOut4, E5, triEn);
	triWave t5(CLOCK_50, triOut5, F5, triEn);
	triWave t6(CLOCK_50, triOut6, G5, triEn);
	triWave t7(CLOCK_50, triOut7, A5, triEn);
	triWave t8(CLOCK_50, triOut8, B5, triEn);

	triWave t0p(CLOCK_50, triOut0p, A4 + A4/phaseDiff, triEn & phaseEn);
	triWave t1p(CLOCK_50, triOut1p, B4 + B4/phaseDiff, triEn & phaseEn); //to put out of phase, just do B4 + 0.5*B4 right? for delay. Then 180 degrees out of phase?. Need two modules of same pitch playing at same time!
	triWave t2p(CLOCK_50, triOut2p, C5 + C5/phaseDiff, triEn & phaseEn);
	triWave t3p(CLOCK_50, triOut3p, D5 + D5/phaseDiff, triEn & phaseEn);
	triWave t4p(CLOCK_50, triOut4p, E5 + E5/phaseDiff, triEn & phaseEn);
	triWave t5p(CLOCK_50, triOut5p, F5 + F5/phaseDiff, triEn & phaseEn);
	triWave t6p(CLOCK_50, triOut6p, G5 + G5/phaseDiff, triEn & phaseEn);
	triWave t7p(CLOCK_50, triOut7p, A5 + A5/phaseDiff, triEn & phaseEn);
	triWave t8p(CLOCK_50, triOut8p, B5 + B5/phaseDiff, triEn & phaseEn);

	//Chose square or triangle wave
	//wire waveType = SW[9]; //0 is square, 1 is triangle
	//assign LEDR[9] = waveType;

	//wire [31:0] sound = (SW == 0) ? 0 : snd ? 32'd10000000 : -32'd10000000;
	wire [31:0] o0, o1, o2, o3, o4, o5, o6, o7, o8;
	
	wire [31:0] squareOut0, squareOut1, squareOut2, squareOut3, squareOut4, squareOut5, squareOut6, squareOut7, squareOut8;
	wire [31:0] squareOut0p, squareOut1p, squareOut2p, squareOut3p, squareOut4p, squareOut5p, squareOut6p, squareOut7p, squareOut8p;
	wire [31:0] triOut0, triOut1, triOut2, triOut3, triOut4, triOut5, triOut6, triOut7, triOut8;
	wire [31:0] triOut0p, triOut1p, triOut2p, triOut3p, triOut4p, triOut5p, triOut6p, triOut7p, triOut8p;
	wire [31:0] sawOut0, sawOut1, sawOut2, sawOut3, sawOut4, sawOut5, sawOut6, sawOut7, sawOut8;
	wire [31:0] sawOut0p, sawOut1p, sawOut2p, sawOut3p, sawOut4p, sawOut5p, sawOut6p, sawOut7p, sawOut8p;
	//Assign outputs from wave generators to the finaloutput bus to the audio output.
	
	
	//To combine waveforms: could do snd0 (as 24-bit bus - change inside module), and say o0 = s0 + sndOut0;
	
	
	//To add triangle wave too
	//wire waveType2 = SW[8];
	//assign LEDR[8] = waveType2;
	
	//Should probably do a mux? OR JUST ASSIGN STATEMENTS - to do mixing wave types.
	parameter ampDiv = 4;
	parameter numNotes = 5; //num notes - 1
	
	
	assign o0 = (finalOutBus[0] == 0) ? 0 : squareOut0 | triOut0 | sawOut0 | squareOut0p | triOut0p |sawOut0p; //squareOut0 + sawOut0; //delay_cnt0*88; //88 is maxAmplitude/A4 //sawOut0 | sawOut0p;
	assign o1 = (finalOutBus[1] == 0) ? 0 : squareOut1 | triOut1 | sawOut1 | squareOut1p | triOut1p |sawOut1p;
	assign o2 = (finalOutBus[2] == 0) ? 0 : squareOut2 | triOut2 | sawOut2 | squareOut2p | triOut2p |sawOut2p;
	assign o3 = (finalOutBus[3] == 0) ? 0 : squareOut3 | triOut3 | sawOut3 | squareOut3p | triOut3p |sawOut3p;
	assign o4 = (finalOutBus[4] == 0) ? 0 : squareOut4 | triOut4 | sawOut4 | squareOut4p | triOut4p |sawOut4p;
	assign o5 = (finalOutBus[5] == 0) ? 0 : squareOut5 | triOut5 | sawOut5 | squareOut5p | triOut5p |sawOut5p;
	assign o6 = (finalOutBus[6] == 0) ? 0 : squareOut6 | triOut6 | sawOut6 | squareOut6p | triOut6p |sawOut6p;
	assign o7 = (finalOutBus[7] == 0) ? 0 : squareOut7 | triOut7 | sawOut7 | squareOut7p | triOut7p |sawOut7p;
	assign o8 = (finalOutBus[8] == 0) ? 0 : squareOut8 | triOut8 | sawOut8 | squareOut8p | triOut8p |sawOut8p;

	//assign qbus3pt = ~KEY[3] ? qbus3 : 0;
	//wire [31:0] sawOut0pt = SW[9] ? sawOut0 : (SW[8] | SW[7]) ? sawOut/ampDiv : 0; //enables blending of waves (make lower amplitude individual waveforms to prevent clipping)
	
	
	
	
	/*
	assign o0 = (finalOutBus[0] == 0) ? 0 : snd0 ? 32'd10000000 : -32'd10000000;
	assign o1 = (finalOutBus[1] == 0) ? 0 : snd1 ? 32'd10000000 : -32'd10000000; //edcbazyx or 012345678
	assign o2 = (finalOutBus[2] == 0) ? 0 : snd2 ? 32'd10000000 : -32'd10000000;
	assign o3 = (finalOutBus[3] == 0) ? 0 : snd3 ? 32'd10000000 : -32'd10000000;
	assign o4 = (finalOutBus[4] == 0) ? 0 : snd4 ? 32'd10000000 : -32'd10000000;
	assign o5 = (finalOutBus[5] == 0) ? 0 : snd5 ? 32'd10000000 : -32'd10000000;
	assign o6 = (finalOutBus[6] == 0) ? 0 : snd6 ? 32'd10000000 : -32'd10000000;
	assign o7 = (finalOutBus[7] == 0) ? 0 : snd7 ? 32'd10000000 : -32'd10000000;
	assign o8 = (finalOutBus[8] == 0) ? 0 : snd8 ? 32'd10000000 : -32'd10000000;*/

	wire sndx, sndy, sndz, snda, sndb, sndc, sndd, snde; //for anyPitchGen


	assign read_audio_in			= audio_in_available & audio_out_allowed;

	assign left_channel_audio_out	= left_channel_audio_in+o0+o1+o2+o3+o4+o5+o6+o7+o8;
	assign right_channel_audio_out	= right_channel_audio_in+o0+o1+o2+o3+o4+o5+o6+o7+o8;
	assign write_audio_out			= audio_in_available & audio_out_allowed;

	/*****************************************************************************
	 *                              Internal Modules                             *
	 *****************************************************************************/

	Audio_Controller Audio_Controller (
		// Inputs
		.CLOCK_50						(CLOCK_50),
		.reset						(0), //was ~KEY[0]

		.clear_audio_in_memory		(),
		.read_audio_in				(read_audio_in),
		
		.clear_audio_out_memory		(),
		.left_channel_audio_out		(left_channel_audio_out),
		.right_channel_audio_out	(right_channel_audio_out),
		.write_audio_out			(write_audio_out),

		.AUD_ADCDAT					(AUD_ADCDAT),

		// Bidirectionals
		.AUD_BCLK					(AUD_BCLK),
		.AUD_ADCLRCK				(AUD_ADCLRCK),
		.AUD_DACLRCK				(AUD_DACLRCK),


		// Outputs
		.audio_in_available			(audio_in_available),
		.left_channel_audio_in		(left_channel_audio_in),
		.right_channel_audio_in		(right_channel_audio_in),

		.audio_out_allowed			(audio_out_allowed),

		.AUD_XCK					(AUD_XCK),
		.AUD_DACDAT					(AUD_DACDAT)

	);

	avconf #(.USE_MIC_INPUT(1)) avc (
		.FPGA_I2C_SCLK					(FPGA_I2C_SCLK),
		.FPGA_I2C_SDAT					(FPGA_I2C_SDAT),
		.CLOCK_50					(CLOCK_50),
		.reset						(0) //was ~KEY[0]
	);

		
		//CHORD REGISTER LOGIC

		//---------------------------------------------------------------------------------------
		//Register Code
		wire [9:0] qbus0;
		wire [9:0] qbus1;
		wire [9:0] qbus2;
		wire [9:0] qbus3;
		wire [9:0] qbus0pt; //passthrough, enabled with switches
		wire [9:0] qbus1pt;
		wire [9:0] qbus2pt;
		wire [9:0] qbus3pt;
		wire [9:0] finalOutBus; //10-bit in case we want to use all switches
		//output reg [9:0] finalOut;
		
		//To show switch outputs when in write mode:
		assign LEDR[numNotes:0] = writeEn ? SW : finalOutBus; //Show note outputs for current chord register on LEDs
		//This LEDR can become a wire bus to send data to a bunch of note-producing modules.
		
		wire writeEn;
		assign writeEn = (SW[numNotes:0] != 0); //If @ least 1 switch selected, in WRITE MODE. If NO switches are selected, in PLAY mode.
		
		//NOTE: KEY IS INVERTED BEFORE BEING SENT IN.
		chordRegister c3(.sw(SW[numNotes:0]), .clk(CLOCK_50), .key(~KEY[3]), .writeEn(writeEn), .q(qbus3[9:0]));
		chordRegister c2(.sw(SW[numNotes:0]), .clk(CLOCK_50), .key(~KEY[2]), .writeEn(writeEn), .q(qbus2[9:0]));
		chordRegister c1(.sw(SW[numNotes:0]), .clk(CLOCK_50), .key(~KEY[1]), .writeEn(writeEn), .q(qbus1[9:0]));
		chordRegister c0(.sw(SW[numNotes:0]), .clk(CLOCK_50), .key(~KEY[0]), .writeEn(writeEn), .q(qbus0[9:0]));

		assign qbus3pt = ~KEY[3] ? qbus3 : 0;
		assign qbus2pt = ~KEY[2] ? qbus2 : 0;
		assign qbus1pt = ~KEY[1] ? qbus1 : 0;
		assign qbus0pt = ~KEY[0] ? qbus0 : 0;

		assign finalOutBus = qbus0pt | qbus1pt | qbus2pt | qbus3pt; //enable simultaneous chord playing. Also to allow hearing chords as you create them in write mode.		

endmodule

	
//CHORD REGISTER MODULE
//Instantiate 4 of these 10-bit note registers to store 4 different chords, which can be selected via a keypress.
//**Want the keypress to activate it's register's outputs (notes) for only as long as the key is pressed.
module chordRegister(sw, clk, key, writeEn, q);

	input [9:0] sw; //Or may have to math numNotes!
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

//SQUAREWAVE GENERATOR
module squareWave(clk, sndOut, delay, enable);
	input enable;
	input clk;
	input [20:0] delay; //21-bit wire because lowest piano pitch is ~27Hz, therefore 50000000/27 < (2^21 = 2 097 152)
	reg signed [20:0] delay_cnt;
	reg snd;
	output reg signed [31:0] sndOut;
	
	always @ (posedge clk) begin
		if(delay_cnt == delay) begin
			delay_cnt <= 0;
			snd <= !snd;
		end else delay_cnt <= delay_cnt + 1;
	end
	
	always @(*) begin
		sndOut <= enable ? (snd ? 32'd10000000 : -32'd10000000) : 0;
	end
endmodule


//SAWWAVE GENERATOR
module sawWave(clk, sndOut, delay, enable);
	input enable;
	parameter maxAmplitude = 32'd10000000;
	output reg signed [32:0] sndOut; //sndOut ranges from 0 to 10000000 (24 bit) - use 32 anyways
	input clk;
	input [20:0] delay; //21-bit wire because lowest piano pitch is ~27Hz, therefore 50000000/27 < (2^21 = 2 097 152)
	reg signed [20:0] delay_cnt; //signed bc want triangle wave to start negative, then positive to take full advantage of DAC dynamic range. - didn't work
	
	always @ (posedge clk) begin
		//Experimental Triangle Wave
		if(delay_cnt == delay) begin //Want amplitude to range from 0 to 10 000 000. This ranges from 0 to (50000000/440 = 113636). Therefore,
		//multiply factor is 10 000 000 / 113 636 = 88. Therefore, multiply output amplitude by 88 to get same range of sound as before, for squarewave.
			delay_cnt <= 0; //-delay; //does delay_cnt have to be signed? - only problem - the initial value of delay_cnt will be 0. (for the 1st cycle - maybe unnoticeable?)
			sndOut <= enable ? (delay_cnt*(maxAmplitude/delay)*2) : 0; //*2 so amplitude it as loud as squarewave
			//volume getting louder as pitch goes up (when delay gets smaller)
		end 
		else begin
			delay_cnt <= delay_cnt + 1; 
			sndOut <= enable ? (delay_cnt*(maxAmplitude/delay)*2) : 0;
		end
	end
endmodule


//Real triangle wave - WORKS!!
module triWave(clk, sndOut, delay, enable);
	input enable;
	parameter maxAmplitude = 32'd10000000;
	output reg signed [32:0] sndOut; //sndOut ranges from 0 to 10000000 (24 bit) - use 32 anyways
	input clk;
	input [20:0] delay; //21-bit wire because lowest piano pitch is ~27Hz, therefore 50000000/27 < (2^21 = 2 097 152)
	//reg signed [20:0] delay_cnt1;
	reg signed [20:0] delay_cnt0; //signed bc want triangle wave to start negative, then positive to take full advantage of DAC dynamic range.
	reg incDec; //0 is decrement, 1 is increment
	
	always @ (posedge clk) begin
		//Experimental Triangle Wave
		if(delay_cnt0 == delay) begin //Want amplitude to range from 0 to 10 000 000. This ranges from 0 to (50000000/440 = 113636). Therefore,
			sndOut <= enable ? (delay_cnt0*(maxAmplitude/delay)*2) : 0;
			//decrement
			incDec <= 1'b0;
			delay_cnt0 <= delay + 1; //to prevent latching in this state
		end
		if (delay_cnt0 == 0) begin //was == -delay
			sndOut <= enable ? (delay_cnt0*(maxAmplitude/delay)*2) : 0;
			//incremement
			incDec <= 1'b1;
			delay_cnt0 <= 1; //to prevent latching
		end
		if (incDec == 1'b0) begin //will initially start decaying.
			delay_cnt0 <= delay_cnt0 - 1;
			sndOut <= enable ? (delay_cnt0*(maxAmplitude/delay)*2) : 0;
		end
		if (incDec == 1'b1) begin
			delay_cnt0 <= delay_cnt0 + 1;
			sndOut <= enable ? (delay_cnt0*(maxAmplitude/delay)*2) : 0;
		end
	end
endmodule
