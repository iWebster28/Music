
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
	LEDR,
	HEX0,
	HEX1,
	HEX2,
	HEX3,
	HEX4,
	HEX5,
	HEX6,
	HEX7,
	PS2_CLK,
	PS2_DAT
);
	//Keyboard Instantiation
	PS2_Demo PIANO(	// Inputs
	.clk(CLOCK_50),
	.key(~KEY[3:0]),

	// Bidirectionals
	.PS2_CLK1(PS2_CLK),
	.PS2_DAT1(PS2_DAT),
	
	// Outputs
	.hex0(HEX0),
	.hex1(HEX1),
	.hex2(HEX2),
	.hex3(HEX3),
	.hex4(HEX4),
	.hex5(HEX5),
	.hex6(HEX6),
	.hex7(HEX7), 
	.ledr(),
	.keyBusOut(keyBus)
	);

	inout PS2_CLK;
	inout PS2_DAT;
	
	wire [17:0] keyBus; //For triggering sound modules - from keys 
	//on keyboard

	/*****************************************************************************
	 *                           Parameter Declarations                          *
	 *****************************************************************************/
	//parameter ampDiv = 4; could use this if want to implement volume control
	parameter numNotes = 3; //really num notes - 1

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
	output		[6:0]	HEX0;
	output		[6:0]	HEX1;
	output		[6:0]	HEX2;
	output		[6:0]	HEX3;
	output		[6:0]	HEX4;
	output		[6:0]	HEX5;
	output		[6:0]	HEX6;
	output		[6:0]	HEX7;

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
	parameter clock = 50000000;
	//Note: these parameters are not in Hz. In delay units
	parameter C3 = clock/131; //130.8128
	parameter Eb3 = clock/156; //155.5635	
	parameter F3 = clock/175; //174.6141	
	parameter G3 = clock/196; //195.9977	
	
	parameter C4 = clock/262; //261.6256Hz
	parameter Eb4 = clock/311; //311.1270Hz
	
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
	parameter C6 = clock/1047; //1046.502Hz
	parameter Eb6 = clock/1244; //1244.508Hz
	parameter F6 = clock/1397; //1396.913Hz

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
	wire loopEn = SW[5];

	parameter phaseDiff = 2; //180 degree phase shift

	//WAVE GENERATION MODULE INSTANTIATION
	//squareWave(CLOCK_50, snd, delay);
	squareWave s0(CLOCK_50, squareOut0, C3, squareEn); //changed first 4 notes to match blues scale
	squareWave s1(CLOCK_50, squareOut1, Eb3, squareEn);
	squareWave s2(CLOCK_50, squareOut2, F3, squareEn);
	squareWave s3(CLOCK_50, squareOut3, G3, squareEn);
	squareWave s4(CLOCK_50, squareOut4, E5, squareEn);
	squareWave s5(CLOCK_50, squareOut5, F5, squareEn);
	squareWave s6(CLOCK_50, squareOut6, G5, squareEn);
	squareWave s7(CLOCK_50, squareOut7, A5, squareEn);
	squareWave s8(CLOCK_50, squareOut8, B5, squareEn);

	squareWave s0p(CLOCK_50, squareOut0p, C3 + C3/phaseDiff, squareEn & phaseEn);
	squareWave s1p(CLOCK_50, squareOut1p, Eb3 + Eb3/phaseDiff, squareEn & phaseEn);
	squareWave s2p(CLOCK_50, squareOut2p, F3 + F3/phaseDiff, squareEn & phaseEn);
	squareWave s3p(CLOCK_50, squareOut3p, G3 + G3/phaseDiff, squareEn & phaseEn);
	squareWave s4p(CLOCK_50, squareOut4p, E5 + E5/phaseDiff, squareEn & phaseEn);
	squareWave s5p(CLOCK_50, squareOut5p, F5 + F5/phaseDiff, squareEn & phaseEn);
	squareWave s6p(CLOCK_50, squareOut6p, G5 + G5/phaseDiff, squareEn & phaseEn);
	squareWave s7p(CLOCK_50, squareOut7p, A5 + A5/phaseDiff, squareEn & phaseEn);
	squareWave s8p(CLOCK_50, squareOut8p, B5 + B5/phaseDiff, squareEn & phaseEn);
	
	
	sawWave st0(CLOCK_50, sawOut0, C3, sawEn);
	sawWave st1(CLOCK_50, sawOut1, Eb3, sawEn); //to put out of phase, just do B4 + 0.5*B4 right? for delay. Then 180 degrees out of phase?. Need two modules of same pitch playing at same time!
	sawWave st2(CLOCK_50, sawOut2, F3, sawEn);
	sawWave st3(CLOCK_50, sawOut3, G3, sawEn);
	sawWave st4(CLOCK_50, sawOut4, E5, sawEn);
	sawWave st5(CLOCK_50, sawOut5, F5, sawEn);
	sawWave st6(CLOCK_50, sawOut6, G5, sawEn);
	sawWave st7(CLOCK_50, sawOut7, A5, sawEn);
	sawWave st8(CLOCK_50, sawOut8, B5, sawEn);
	
	//Out-of Phase sawWave Generators (p is for phase)
	sawWave st0p(CLOCK_50, sawOut0p, C3 + C3/phaseDiff, sawEn & phaseEn);
	sawWave st1p(CLOCK_50, sawOut1p, Eb3 + Eb3/phaseDiff, sawEn & phaseEn); //to put out of phase, just do B4 + 0.5*B4 right? for delay. Then 180 degrees out of phase?. Need two modules of same pitch playing at same time!
	sawWave st2p(CLOCK_50, sawOut2p, F3 + F3/phaseDiff, sawEn & phaseEn);
	sawWave st3p(CLOCK_50, sawOut3p, G3 + G3/phaseDiff, sawEn & phaseEn);
	sawWave st4p(CLOCK_50, sawOut4p, E5 + E5/phaseDiff, sawEn & phaseEn);
	sawWave st5p(CLOCK_50, sawOut5p, F5 + F5/phaseDiff, sawEn & phaseEn);
	sawWave st6p(CLOCK_50, sawOut6p, G5 + G5/phaseDiff, sawEn & phaseEn);
	sawWave st7p(CLOCK_50, sawOut7p, A5 + A5/phaseDiff, sawEn & phaseEn);
	sawWave st8p(CLOCK_50, sawOut8p, B5 + B5/phaseDiff, sawEn & phaseEn);
	
	triWave t0(CLOCK_50, triOut0, C3, triEn);
	triWave t1(CLOCK_50, triOut1, Eb3, triEn); //to put out of phase, just do B4 + 0.5*B4 right? for delay. Then 180 degrees out of phase?. Need two modules of same pitch playing at same time!
	triWave t2(CLOCK_50, triOut2, F3, triEn);
	triWave t3(CLOCK_50, triOut3, G3, triEn);
	triWave t4(CLOCK_50, triOut4, E5, triEn);
	triWave t5(CLOCK_50, triOut5, F5, triEn);
	triWave t6(CLOCK_50, triOut6, G5, triEn);
	triWave t7(CLOCK_50, triOut7, A5, triEn);
	triWave t8(CLOCK_50, triOut8, B5, triEn);

	triWave t0p(CLOCK_50, triOut0p, C3 + C3/phaseDiff, triEn & phaseEn);
	triWave t1p(CLOCK_50, triOut1p, Eb3 + Eb3/phaseDiff, triEn & phaseEn); //to put out of phase, just do B4 + 0.5*B4 right? for delay. Then 180 degrees out of phase?. Need two modules of same pitch playing at same time!
	triWave t2p(CLOCK_50, triOut2p, F3 + F3/phaseDiff, triEn & phaseEn);
	triWave t3p(CLOCK_50, triOut3p, G3 + G3/phaseDiff, triEn & phaseEn);
	triWave t4p(CLOCK_50, triOut4p, E5 + E5/phaseDiff, triEn & phaseEn);
	triWave t5p(CLOCK_50, triOut5p, F5 + F5/phaseDiff, triEn & phaseEn);
	triWave t6p(CLOCK_50, triOut6p, G5 + G5/phaseDiff, triEn & phaseEn);
	triWave t7p(CLOCK_50, triOut7p, A5 + A5/phaseDiff, triEn & phaseEn);
	triWave t8p(CLOCK_50, triOut8p, B5 + B5/phaseDiff, triEn & phaseEn);

	//----------------------------------------------------------------------------------------
	//For keyboard - defining blues scale
	squareWave s0k(CLOCK_50, squareOut0k, C5, squareEn);
	squareWave s1k(CLOCK_50, squareOut1k, Eb5, squareEn);
	squareWave s2k(CLOCK_50, squareOut2k, F5, squareEn);
	squareWave s3k(CLOCK_50, squareOut3k, Gb5, squareEn);
	squareWave s4k(CLOCK_50, squareOut4k, G5, squareEn);
	squareWave s5k(CLOCK_50, squareOut5k, Bb5, squareEn);
	squareWave s6k(CLOCK_50, squareOut6k, C6, squareEn);
	squareWave s7k(CLOCK_50, squareOut7k, Eb6, squareEn); //not using these last 2 modules
	squareWave s8k(CLOCK_50, squareOut8k, F6, squareEn);

	squareWave s0pk(CLOCK_50, squareOut0pk, C5 + C5/phaseDiff, squareEn & phaseEn);
	squareWave s1pk(CLOCK_50, squareOut1pk, Eb5 + Eb5/phaseDiff, squareEn & phaseEn);
	squareWave s2pk(CLOCK_50, squareOut2pk, F5 + F5/phaseDiff, squareEn & phaseEn);
	squareWave s3pk(CLOCK_50, squareOut3pk, Gb5 + Gb5/phaseDiff, squareEn & phaseEn);
	squareWave s4pk(CLOCK_50, squareOut4pk, G5 + G5/phaseDiff, squareEn & phaseEn);
	squareWave s5pk(CLOCK_50, squareOut5pk, Bb5 + Bb5/phaseDiff, squareEn & phaseEn);
	squareWave s6pk(CLOCK_50, squareOut6pk, C6 + C6/phaseDiff, squareEn & phaseEn);
	squareWave s7pk(CLOCK_50, squareOut7pk, Eb6 + Eb6/phaseDiff, squareEn & phaseEn);
	squareWave s8pk(CLOCK_50, squareOut8pk, F6 + F6/phaseDiff, squareEn & phaseEn);
	
	sawWave st0k(CLOCK_50, sawOut0k, C5, sawEn);
	sawWave st1k(CLOCK_50, sawOut1k, Eb5, sawEn); //to put out of phase, just do B4 + 0.5*B4 right? for delay. Then 180 degrees out of phase?. Need two modules of same pitch playing at same time!
	sawWave st2k(CLOCK_50, sawOut2k, F5, sawEn);
	sawWave st3k(CLOCK_50, sawOut3k, Gb5, sawEn);
	sawWave st4k(CLOCK_50, sawOut4k, G5, sawEn);
	sawWave st5k(CLOCK_50, sawOut5k, Bb5, sawEn);
	sawWave st6k(CLOCK_50, sawOut6k, C6, sawEn);
	sawWave st7k(CLOCK_50, sawOut7k, Eb6, sawEn); //ignore bottom 2
	sawWave st8k(CLOCK_50, sawOut8k, F6, sawEn);
	
	//Out-of Phase sawWave Generators (p is for phase)
	sawWave st0pk(CLOCK_50, sawOut0pk, C5 + C5/phaseDiff, sawEn & phaseEn);
	sawWave st1pk(CLOCK_50, sawOut1pk, Eb5 + Eb5/phaseDiff, sawEn & phaseEn); //to put out of phase, just do B4 + 0.5*B4 right? for delay. Then 180 degrees out of phase?. Need two modules of same pitch playing at same time!
	sawWave st2pk(CLOCK_50, sawOut2pk, F5 + F5/phaseDiff, sawEn & phaseEn);
	sawWave st3pk(CLOCK_50, sawOut3pk, Gb5 + Gb5/phaseDiff, sawEn & phaseEn);
	sawWave st4pk(CLOCK_50, sawOut4pk, G5 + G5/phaseDiff, sawEn & phaseEn);
	sawWave st5pk(CLOCK_50, sawOut5pk, Bb5 + Bb5/phaseDiff, sawEn & phaseEn);
	sawWave st6pk(CLOCK_50, sawOut6pk, C6 + C6/phaseDiff, sawEn & phaseEn);
	sawWave st7pk(CLOCK_50, sawOut7pk, Eb6 + Eb6/phaseDiff, sawEn & phaseEn);
	sawWave st8pk(CLOCK_50, sawOut8pk, F6 + F6/phaseDiff, sawEn & phaseEn);
	
	triWave t0k(CLOCK_50, triOut0k, C5, triEn);
	triWave t1k(CLOCK_50, triOut1k, Eb5, triEn); //to put out of phase, just do B4 + 0.5*B4 right? for delay. Then 180 degrees out of phase?. Need two modules of same pitch playing at same time!
	triWave t2k(CLOCK_50, triOut2k, F5, triEn);
	triWave t3k(CLOCK_50, triOut3k, Gb5, triEn);
	triWave t4k(CLOCK_50, triOut4k, G5, triEn);
	triWave t5k(CLOCK_50, triOut5k, Bb5, triEn);
	triWave t6k(CLOCK_50, triOut6k, C6, triEn);
	triWave t7k(CLOCK_50, triOut7k, Eb6, triEn); 
	triWave t8k(CLOCK_50, triOut8k, F6, triEn); 

	triWave t0pk(CLOCK_50, triOut0pk, C5 + C5/phaseDiff, triEn & phaseEn);
	triWave t1pk(CLOCK_50, triOut1pk, Eb5 + Eb5/phaseDiff, triEn & phaseEn); //to put out of phase, just do B4 + 0.5*B4 right? for delay. Then 180 degrees out of phase?. Need two modules of same pitch playing at same time!
	triWave t2pk(CLOCK_50, triOut2pk, F5 + F5/phaseDiff, triEn & phaseEn);
	triWave t3pk(CLOCK_50, triOut3pk, Gb5 + Gb5/phaseDiff, triEn & phaseEn);
	triWave t4pk(CLOCK_50, triOut4pk, G5 + G5/phaseDiff, triEn & phaseEn);
	triWave t5pk(CLOCK_50, triOut5pk, Bb5 + Bb5/phaseDiff, triEn & phaseEn);
	triWave t6pk(CLOCK_50, triOut6pk, C6 + C6/phaseDiff, triEn & phaseEn);
	triWave t7pk(CLOCK_50, triOut7pk, Eb6 + Eb6/phaseDiff, triEn & phaseEn);
	triWave t8pk(CLOCK_50, triOut8pk, F6 + F6/phaseDiff, triEn & phaseEn);

	//Chose square or triangle wave
	//wire waveType = SW[9]; //0 is square, 1 is triangle
	//assign LEDR[9] = waveType;

	//wire [31:0] sound = (SW == 0) ? 0 : snd ? 32'd10000000 : -32'd10000000;
	wire [31:0] o0, o1, o2, o3, o4, o5, o6, o7, o8;
	wire [31:0] o0k, o1k, o2k, o3k, o4k, o5k, o6k, o7k, o8k;
	
	wire [31:0] squareOut0, squareOut1, squareOut2, squareOut3, squareOut4, squareOut5, squareOut6, squareOut7, squareOut8;
	wire [31:0] squareOut0p, squareOut1p, squareOut2p, squareOut3p, squareOut4p, squareOut5p, squareOut6p, squareOut7p, squareOut8p;
	wire [31:0] triOut0, triOut1, triOut2, triOut3, triOut4, triOut5, triOut6, triOut7, triOut8;
	wire [31:0] triOut0p, triOut1p, triOut2p, triOut3p, triOut4p, triOut5p, triOut6p, triOut7p, triOut8p;
	wire [31:0] sawOut0, sawOut1, sawOut2, sawOut3, sawOut4, sawOut5, sawOut6, sawOut7, sawOut8;
	wire [31:0] sawOut0p, sawOut1p, sawOut2p, sawOut3p, sawOut4p, sawOut5p, sawOut6p, sawOut7p, sawOut8p;

	//Wires for the keyboard
	wire [31:0] squareOut0k, squareOut1k, squareOut2k, squareOut3k, squareOut4k, squareOut5k, squareOut6k, squareOut7k, squareOut8k;
	wire [31:0] squareOut0pk, squareOut1pk, squareOut2pk, squareOut3pk, squareOut4pk, squareOut5pk, squareOut6pk, squareOut7pk, squareOut8pk;
	wire [31:0] triOut0k, triOut1k, triOut2k, triOut3k, triOut4k, triOut5k, triOut6k, triOut7k, triOut8k;
	wire [31:0] triOut0pk, triOut1pk, triOut2pk, triOut3pk, triOut4pk, triOut5pk, triOut6pk, triOut7pk, triOut8pk;
	wire [31:0] sawOut0k, sawOut1k, sawOut2k, sawOut3k, sawOut4k, sawOut5k, sawOut6k, sawOut7k, sawOut8k;
	wire [31:0] sawOut0pk, sawOut1pk, sawOut2pk, sawOut3pk, sawOut4pk, sawOut5pk, sawOut6pk, sawOut7pk, sawOut8pk;
	//Assign outputs from wave generators to the finaloutput bus to the audio output.
	
	
	assign o0 = (finalOutBus[0] == 0) ? 0 : squareOut0 | triOut0 | sawOut0 | squareOut0p | triOut0p |sawOut0p; //squareOut0 + sawOut0; //delay_cnt0*88; //88 is maxAmplitude/A4 //sawOut0 | sawOut0p;
	assign o1 = (finalOutBus[1] == 0) ? 0 : squareOut1 | triOut1 | sawOut1 | squareOut1p | triOut1p |sawOut1p;
	assign o2 = (finalOutBus[2] == 0) ? 0 : squareOut2 | triOut2 | sawOut2 | squareOut2p | triOut2p |sawOut2p;
	assign o3 = (finalOutBus[3] == 0) ? 0 : squareOut3 | triOut3 | sawOut3 | squareOut3p | triOut3p |sawOut3p;
	assign o4 = (finalOutBus[4] == 0) ? 0 : squareOut4 | triOut4 | sawOut4 | squareOut4p | triOut4p |sawOut4p;
	assign o5 = (finalOutBus[5] == 0) ? 0 : squareOut5 | triOut5 | sawOut5 | squareOut5p | triOut5p |sawOut5p;
	assign o6 = (finalOutBus[6] == 0) ? 0 : squareOut6 | triOut6 | sawOut6 | squareOut6p | triOut6p |sawOut6p;
	assign o7 = (finalOutBus[7] == 0) ? 0 : squareOut7 | triOut7 | sawOut7 | squareOut7p | triOut7p |sawOut7p;
	assign o8 = (finalOutBus[8] == 0) ? 0 : squareOut8 | triOut8 | sawOut8 | squareOut8p | triOut8p |sawOut8p;


	//Outputs for the keyboard -add k to eveything

	//assign o9 = keyBus[0] ? squareOut : 0; /////FIX THIS
	//0, 3, 5, 6, 7, 10, 12, 15, 17 are degrees of the blues scale!
	assign o0k = (keyBus[0] == 0) ? 0 : squareOut0k | triOut0k | sawOut0k | squareOut0pk | triOut0pk |sawOut0pk; //squareOut0 + sawOut0; //delay_cnt0*88; //88 is maxAmplitude/A4 //sawOut0 | sawOut0p;
	assign o1k = (keyBus[3] == 0) ? 0 : squareOut1k | triOut1k | sawOut1k | squareOut1pk | triOut1pk |sawOut1pk;
	assign o2k = (keyBus[5] == 0) ? 0 : squareOut2k | triOut2k | sawOut2k | squareOut2pk | triOut2pk |sawOut2pk;
	assign o3k = (keyBus[6] == 0) ? 0 : squareOut3k | triOut3k | sawOut3k | squareOut3pk | triOut3pk |sawOut3pk;
	assign o4k = (keyBus[7] == 0) ? 0 : squareOut4k | triOut4k | sawOut4k | squareOut4pk | triOut4pk |sawOut4pk;
	assign o5k = (keyBus[10] == 0) ? 0 : squareOut5k | triOut5k | sawOut5k | squareOut5pk | triOut5pk |sawOut5pk;
	assign o6k = (keyBus[12] == 0) ? 0 : squareOut6k | triOut6k | sawOut6k | squareOut6pk | triOut6pk |sawOut6pk;
	assign o7k = (keyBus[15] == 0) ? 0 : squareOut7k | triOut7k | sawOut7k | squareOut7pk | triOut7pk |sawOut7pk;
	assign o8k = (keyBus[17] == 0) ? 0 : squareOut8k | triOut8k | sawOut8k | squareOut8pk | triOut8pk |sawOut8pk;


	assign read_audio_in			= audio_in_available & audio_out_allowed;

	assign left_channel_audio_out	= left_channel_audio_in+o0+o1+o2+o3+o4+o5+o6+o7+o8+o0k+o1k+o2k+o3k+o4k+o5k+o6k+o7k+o8k;
	assign right_channel_audio_out	= right_channel_audio_in+o0+o1+o2+o3+o4+o5+o6+o7+o8+o0k+o1k+o2k+o3k+o4k+o5k+o6k+o7k+o8k;
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
		
		
		//assign LEDR[numNotes:0] = writeEn ? SW : finalOutBus; //Show note outputs for current chord register on LEDs !!!!!!!!!!!!!!!!!!!!!!!!!!!!
		
		//This LEDR can become a wire bus to send data to a bunch of note-producing modules.
		
		wire writeEn;
		assign writeEn = (SW[numNotes:0] != 0) & !loopEn; //If @ least 1 switch from keyset selected, in WRITE MODE. If NO switches are selected, in PLAY mode.
		//Also have to make sure the looper mode isn't on^
		
		//ASSIGNING INPUT STAGE
		wire [numNotes:0] noteKeys = SW[numNotes:0]; //assigning a certain number of switches to be used as notes to play pitches.
		
		//NOTE: KEY IS INVERTED BEFORE BEING SENT IN.
		chordRegister c3(.sw(noteKeys), .clk(CLOCK_50), .key(~KEY[3]), .writeEn(writeEn), .q(qbus3[9:0]));
		chordRegister c2(.sw(noteKeys), .clk(CLOCK_50), .key(~KEY[2]), .writeEn(writeEn), .q(qbus2[9:0]));
		chordRegister c1(.sw(noteKeys), .clk(CLOCK_50), .key(~KEY[1]), .writeEn(writeEn), .q(qbus1[9:0]));
		chordRegister c0(.sw(noteKeys), .clk(CLOCK_50), .key(~KEY[0]), .writeEn(writeEn), .q(qbus0[9:0]));
		
		
		
		//loopbus[3] is the 1st beat of the shift registers. To be read @ rate of 120BPM
		
		//had these at 3
		assign qbus3pt = (~KEY[3] | loopbus3[2]) ? qbus3 : 0; //Blend audio from the looper. Can also play chords (in play mode) over the loop
		assign qbus2pt = (~KEY[2] | loopbus2[1]) ? qbus2 : 0; //Have to change to 1 for some reason? Loading into register 2 and 0 are off for some reason?
		assign qbus1pt = (~KEY[1] | loopbus1[2]) ? qbus1 : 0;
		assign qbus0pt = (~KEY[0] | loopbus0[1]) ? qbus0 : 0;

		assign finalOutBus = qbus0pt | qbus1pt | qbus2pt | qbus3pt; //enable simultaneous chord playing. Also to allow hearing chords as you create them in write mode.		

		
		
		//PROBLEM: Probably to do with chords being set to where q is at a point in time?????idk
		
		//Issues:
		//Need to load Q on the negedge of the key??? how to do in always block..
		//When you load a loop register, sometimes the notes are off by 1 clock cycle...
		
		
		
		
		//ONly problem: led 0 and 2 are reversed in the looper?
		
		
		
		
		
		
		
		
		//LOOPER LOGIC-----------------------------------------------------------------------------------------------------------------------------------
		//Activate looper with SW[5]
		//4 x 4-bit shift registers

		wire [numNotes:0] loopbus0, loopbus1, loopbus2, loopbus3; //each loopbus contains the time-chord activation data for a certain chord register
		wire [numNotes:0] staticloopbus0, staticloopbus1, staticloopbus2, staticloopbus3; 
		//static loopbusses contain the original notes you enter into the sequencer; i.e. not shifting
		wire [26:0] rateOut;
		wire [numNotes:0] LEDPos;
		wire BPMShiftEn;
		
		//Instantiating 1 shift register per chord. (EX: 4 chords, therefore need 4 registers)
		//loopEn is SW[5]. shiftEn is the enable from the clock (rate divider)
		shiftReg4bit chord3(.D(noteKeys), .clk(CLOCK_50), .loopEn(loopEn), .BPMShiftEn(BPMShiftEn), .Q(loopbus3), .key(~KEY[3]), .Qstatic(staticloopbus3), .firstBeatLoad(start), .Dstatic(Dstatic3)); //loopEn is SW[5]
		shiftReg4bit chord2(.D(noteKeys), .clk(CLOCK_50), .loopEn(loopEn), .BPMShiftEn(BPMShiftEn), .Q(loopbus2), .key(~KEY[2]), .Qstatic(staticloopbus2), .firstBeatLoad(start), .Dstatic(Dstatic2));
		shiftReg4bit chord1(.D(noteKeys), .clk(CLOCK_50), .loopEn(loopEn), .BPMShiftEn(BPMShiftEn), .Q(loopbus1), .key(~KEY[1]), .Qstatic(staticloopbus1), .firstBeatLoad(start), .Dstatic(Dstatic1));
		shiftReg4bit chord0(.D(noteKeys), .clk(CLOCK_50), .loopEn(loopEn), .BPMShiftEn(BPMShiftEn), .Q(loopbus0), .key(~KEY[0]), .Qstatic(staticloopbus0), .firstBeatLoad(start), .Dstatic(Dstatic0));
		
		//Used to sync all registers to load on the 1st beat only (therefore, these registers store the value on switches temporarily, until the 
		//1st beat of the bar is reached, which is when a signal is sent on startOfBar to cause the shiftReg4bits modules to load the values of the switches (the values that were last set!).
		//these don't actually act as chord registers. They act as switch (TIME) registers. i.e. store values on switches when key pressed
		wire [3:0] Dstatic3, Dstatic2, Dstatic1, Dstatic0, DstaticLED;
		chordRegister SHIFT3(.sw(noteKeys), .clk(CLOCK_50), .key(~KEY[3]), .writeEn(loopEn), .q(Dstatic3));
		chordRegister SHIFT2(.sw(noteKeys), .clk(CLOCK_50), .key(~KEY[2]), .writeEn(loopEn), .q(Dstatic2));
		chordRegister SHIFT1(.sw(noteKeys), .clk(CLOCK_50), .key(~KEY[1]), .writeEn(loopEn), .q(Dstatic1));
		chordRegister SHIFT0(.sw(noteKeys), .clk(CLOCK_50), .key(~KEY[0]), .writeEn(loopEn), .q(Dstatic0));

		//This shifts an LED to show BPM (shows position - regardless of which register is being written to)
		chordRegister TRACKLED(.sw(9'b000001000), .clk(CLOCK_50), .key(1'b1), .writeEn(loopEn), .q(DstaticLED));
		shiftReg4bit trackLED(.D(4'b1000), .clk(CLOCK_50), .loopEn(loopEn), .BPMShiftEn(BPMShiftEn), .Q(LEDPos), .key(1'b0), .Qstatic(), .firstBeatLoad(start), .Dstatic(DstaticLED)); //THIS IS NOT WORKING!!!!!!!!!!!!!!!!!!!!!


		//TIMING MODULES
		wire [2:0] startOfBar;
		//OUTPUT every 4 bars!
		//4 = startOfBar[2] = 1 (bc 100 = 4)
		//wire start = startOfBar[2]; //sends the signal - to start loading at 1st beat of bar	
		wire start = ~|startOfBar[2:0];		
		RateDivider r1(.q(rateOut), .d(counterMax), .clk(CLOCK_50), .enable(loopEn), .startOfBar(startOfBar)); //Creates the BPM
		
		parameter bpm = 120;
		parameter counterMax = (clock/(bpm/60)) - 1; //Shift out at a rate of 120BPM (120 cycles/min*(1m/60s) = 2Hz) Therefore, count down from 50M/2 = 24 999 999
		assign BPMShiftEn = ~|rateOut[26:0]; //Send pulse everytime count hits 0
		//could just assign BPMshiftEn to an LED, and it would show BPM.
		assign LEDR[5] = loopEn ? start : |keyBus;
		assign LEDR[4] = loopEn ? BPMShiftEn : 0;
		
		//Want to show what you select per chord register on LEDs, based on which key you hit. EX: select 1 and 3. hit key 0. 1 and 3 show up, and counter led moves.
		reg [3:0] ledShiftSel; //toggles which chord LED timer counter is being shown. Can toggle - MIGHT BE PROBLEM IF YOU SET >= 2 chords consecutively - fixed
		always @(posedge CLOCK_50) begin
			if (loopEn) begin
				//ledShiftSelect = {~KEY[3], ~KEY[2], ~KEY[1], ~KEY[0]};
				if (~KEY[0]) begin 
					ledShiftSel <= 0;
					ledShiftSel[0] <= 1'b1; //!ledShiftSel[0] //Toggle on/off - really just need to set = 1 here.
				end
				if (~KEY[1]) begin
					ledShiftSel <= 0; //Clear the others
					ledShiftSel[1] <= 1'b1;
				end
				if (~KEY[2]) begin
					ledShiftSel <= 0;
					ledShiftSel[2] <= 1'b1;
				end
				if (~KEY[3]) begin
					ledShiftSel <= 0;
					ledShiftSel[3] <= 1'b1;
				end
				if (!loopEn) begin
					ledShiftSel[3:0] <= 0;
				end
			end
		end
		
		
		//FEATURE ADD:
		//Note: to be able to sequence 4 steps at a time, have to put 2*note count, then only play every other step! (Like 8-step, 8/8 sequencer, but only play 8th notes - have to do double BPM!
		
		//Issue: the shift registers store the chords at the correct locations, but they are read at 1-rate-div delay (120bpm) based on
		//when you hit the key to store D.
		
		
		//This is showing the shifted values from loopbuses. ONLY WANT TO SHOW THE SELECTED VALUES. (ie. KEY0 and KEY1 were switches.
		assign LEDR[numNotes:0] = loopEn ? (LEDPos[numNotes:0] | (ledShiftSel[3] ? staticloopbus3 : 0) | (ledShiftSel[2] ? staticloopbus2 : 0) | (ledShiftSel[1] ? staticloopbus1 : 0) | (ledShiftSel[0] ? staticloopbus0 : 0)) : (writeEn ? SW[numNotes:0] : finalOutBus[numNotes:0]); //loopbuses will only be written to when a key is hit (look above)
		
		//Diagnostic
		//assign LEDR[9:6] = loopbus0;
		//assign LEDR[3:0] = loopbus1;
		
		//assign LEDR[numNotes:0] = loopEn ? (LEDPos[numNotes:0] | (ledShiftSel[3] ? loopbus3 : 0) | (ledShiftSel[2] ? loopbus2 : 0) | (ledShiftSel[1] ? loopbus1 : 0) | (ledShiftSel[0] ? loopbus0 : 0)) : (writeEn ? SW[numNotes:0] : finalOutBus[numNotes:0]);
			
		//assign LEDR[numNotes:0] = loopEn ? LEDPos[numNotes:0] : (writeEn ? SW[numNotes:0] : finalOutBus[numNotes:0]);
		//If in looper mode, show the LED cycle, and the LEDs that represent chords activated, for the CURRENT selected chord shift register.
		//Otherwise, if in read mode (writeEn == 0), then show LEDs for active switches. Otherwise, (writeEn == 1), show what LEDs light up for finalOutBus.
		
endmodule

//Counts down, outputs on Q to enable only when all digits are 0 (reaches 0).
module RateDivider(q, d, clk, enable, startOfBar); //Not using clear b or enable. - removed parLoad

	output reg [26:0] q;
	output reg [2:0] startOfBar; //3-bit to store 4 beats per bar
	input [26:0] d;
	input clk;
	input enable;
	
	always @(posedge clk)
	begin
		if (startOfBar == 4) begin //Allows all registers to load at the start of a bar only!
			startOfBar <= 0;
		end
		if (q == 0) begin //d is the rate from the mux. The number is loaded when parallel load is high. //HAD ParLoad == 1'b1
			q <= d;
			//This will sync all the shift registers. Will only load D on the 1st beat of every bar (4 beats/bar)
			startOfBar <= startOfBar + 1;
		end
		else if (enable == 1'b1)
			q <= q - 1; //DECREASE counter by 1 only when enable is high
	end

endmodule

//4-Bit Shift Register (to be instantiated 4 times for 4 different chords.)
module shiftReg4bit(D, clk, loopEn, BPMShiftEn, Q, key, Qstatic, firstBeatLoad, Dstatic);
	//Qstatic is the initial load pattern of Q. Does not shift. Used to show on LEDs where you placed a note rhythmically.
	parameter numNotes = 3; //really 4

	input key;
	input [numNotes:0] D; //Only for inst. "loading" into LEDs
	input clk;
	input loopEn;
	input BPMShiftEn;
	output reg [numNotes:0] Q; //shifting output register	
	output reg [numNotes:0] Qstatic; //Qstatic is really Dstatic. - stores the switch values on key press.
	
	
	//For managing 1st beat loading only.
	input firstBeatLoad;
	input [numNotes:0] Dstatic; //Static input from the initial load
	
	
	always @ (posedge clk) begin	
		if (firstBeatLoad) begin
			Q <= Dstatic; //load the shift register ALWAYS ON THE FIRST BEAT! - could actually load Qstatic here
			//Q <= Qstatic;
		end
		
		//This block is to show loaded switches on LEDs only. (no computation)
		if (loopEn & key) begin //SW[5] must be on, and the key must be pressed to set the chord into position for this chord loop. - HAVING key HERE WILL PREVENT FROM PLAYING DURING LOOP!!!!!!!!!
			//Q <= 4'b000;
			Qstatic <= D; //for showing on LEDs what times were selected.
		end
		
		else if (loopEn & BPMShiftEn) //Load right bit to shift bits left.
		begin 
			Q[3] <= Q[0]; //registers and LEDs: | 3 | 2 | 1 | 0 |
			Q[2] <= Q[3];
			Q[1] <= Q[2];
			Q[0] <= Q[1];	
		end
		
		if (!loopEn) begin
			Q <= 4'b000; //reset when looper mode turned off.
		end
	end

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
	//parameter maxAmplitude;
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
		sndOut <= enable ? (snd ? 32'd20000000 : -32'd20000000) : 0;
	end
endmodule


//SAWWAVE GENERATOR
module sawWave(clk, sndOut, delay, enable);
	input enable;
	parameter maxAmplitude = 32'd20000000;
	output reg signed [31:0] sndOut; //sndOut ranges from 0 to 20000000 
	input clk;
	input [20:0] delay; //21-bit wire because lowest piano pitch is ~27Hz, therefore 50000000/27 < (2^21 = 2 097 152)
	reg signed [20:0] delay_cnt; //signed bc want triangle wave to start negative, then positive to take full advantage of DAC dynamic range. - didn't work
	
	always @ (posedge clk) begin
		//Experimental Triangle Wave
		if(delay_cnt == delay) begin //Want amplitude to range from 0 to 10 000 000. This ranges from 0 to (50000000/440 = 113636). Therefore,
		//multiply factor is 20 000 000 / 113 636 = 88. Therefore, multiply output amplitude by 88 to get same range of sound as before, for squarewave.
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


//TRIANGLEWAVE GENERATOR
module triWave(clk, sndOut, delay, enable);
	input enable;
	parameter maxAmplitude = 32'd20000000;
	output reg signed [31:0] sndOut; //sndOut ranges from 0 to 20000000
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
			delay_cnt0 <= delay + 1; //to prevent latching in this state - can potentially remove
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
