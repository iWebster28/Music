
module PS2_Demo (
	// Inputs
	clk,
	key,

	// Bidirectionals
	PS2_CLK1,
	PS2_DAT1,
	
	// Outputs
	hex0,
	hex1,
	hex2,
	hex3,
	hex4,
	hex5,
	hex6,
	hex7, 
	ledr,
	keyBusOut
);


// Inputs
input				clk;
input		[3:0]	key;

// Bidirectionals
inout				PS2_CLK1;
inout				PS2_DAT1;

// Outputs
output		[6:0]	hex0;
output		[6:0]	hex1;
output		[6:0]	hex2;
output		[6:0]	hex3;
output		[6:0]	hex4;
output		[6:0]	hex5;
output		[6:0]	hex6;
output		[6:0]	hex7;
output [9:0] ledr;

output [17:0] keyBusOut;

assign keyBusOut = keyBus;

/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/

// Internal Wires
wire		[7:0]	ps2_key_data;
wire				ps2_key_pressed;

// Internal Registers
reg			[7:0]	last_data_received;

// State Machine Registers

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/


/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/
 
reg exit;
reg [17:0] keyReg;
wire [9:0] ledBus = {8'b00000000, keyReg};
wire [17:0] keyBus = keyReg; //these are the new SW[9:0] - or could just trigger their own wave generation modules (for higher pitches).
//assign LEDR[9:0] = ledBus;
 
//LOGIC TO CHECK FOR KEYPRESS AND STORE "1" in KEYBUS[x] AND STORE UNTIL ANY KEY IS RELEASED.
 always @(posedge ps2_key_pressed) //Make sure to run everytime there's an update on a key press (or break code, or letter after break code).
 begin
	case (ps2_key_data) 
	 'h1C: begin //A
		if (exit == 0) begin
			keyReg[17:0] = 0;
			keyReg[0] = 1; //A
		end
		else exit = 0;
	 end
	 'h1D: begin //W
		if (exit == 0) begin
		keyReg[17:0] = 0;
		keyReg[1] = 1; 
		end
		else exit = 0;
	 end
	 'h1B: begin //S
		if (exit == 0) begin
		keyReg[17:0] = 0;
		keyReg[2] = 1; 
		end
		else exit = 0;
	 end
	 'h24: begin //E
		if (exit == 0) begin
		keyReg[17:0] = 0;
		keyReg[3] = 1; 
		end
		else exit = 0;
	 end
	 'h23: begin //D
		if (exit == 0) begin
		keyReg[17:0] = 0;
		keyReg[4] = 1; 
		end
		else exit = 0;
	 end
	 'h2B: begin //F
		if (exit == 0) begin
		keyReg[17:0] = 0;
		keyReg[5] = 1; 
		end
		else exit = 0;
	 end
	 'h2C: begin //T
		if (exit == 0) begin
		keyReg[17:0] = 0;
		keyReg[6] = 1; 
		end
		else exit = 0;
	 end
	 'h34: begin //G
		if (exit == 0) begin
		keyReg[17:0] = 0;
		keyReg[7] = 1; 
		end
		else exit = 0;
	 end
	 'h35: begin //Y
		if (exit == 0) begin
		keyReg[17:0] = 0;
		keyReg[8] = 1; 
		end
		else exit = 0;
	 end
	 'h33: begin //H
		if (exit == 0) begin
		keyReg[17:0] = 0;
		keyReg[9] = 1; 
		end
		else exit = 0;
	 end
	 'h3C: begin //U
		if (exit == 0) begin
		keyReg[17:0] = 0;
		keyReg[10] = 1; 
		end
		else exit = 0;
	 end
	 'h3B: begin //J
		if (exit == 0) begin
		keyReg[17:0] = 0;
		keyReg[11] = 1; 
		end
		else exit = 0;
	 end
	 'h42: begin //K
		if (exit == 0) begin
		keyReg[17:0] = 0;
		keyReg[12] = 1; 
		end
		else exit = 0;
	 end
	 'h44: begin //O
		if (exit == 0) begin
		keyReg[17:0] = 0;
		keyReg[13] = 1; 
		end
		else exit = 0;
	 end
	 'h4B: begin //L
		if (exit == 0) begin
		keyReg[17:0] = 0;
		keyReg[14] = 1; 
		end
		else exit = 0;
	 end
	 'h4D: begin //P
		if (exit == 0) begin
		keyReg[17:0] = 0;
		keyReg[15] = 1; 
		end
		else exit = 0;
	 end
	 'h4C: begin //;
		if (exit == 0) begin
		keyReg[17:0] = 0;
		keyReg[16] = 1; 
		end
		else exit = 0;
	 end
	 'h52: begin //'
		if (exit == 0) begin
		keyReg[17:0] = 0;
		keyReg[17] = 1; 
		end
		else exit = 0;
	 end
	 'hf0: begin
		keyReg[17:0] = 0;
		//keyReg[9] = 1; //Break code
		exit = 1;
	 end
	  default: begin
	  keyReg[17:0] = 0;
	  //keyReg[9] = 1;
	  end
	endcase
 end

/*
always @(posedge clk)
begin
	if (key[0] == 1'b0)
		last_data_received <= 8'h00;
	else if (ps2_key_pressed == 1'b1)
		last_data_received <= ps2_key_data;
end*/



/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/

assign hex2 = 7'h7F;
assign hex3 = 7'h7F;
assign hex4 = 7'h7F;
assign hex5 = 7'h7F;
assign hex6 = 7'h7F;
assign hex7 = 7'h7F;

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

PS2_Controller PS2 (
	// Inputs
	.CLOCK_50				(clk),
	.reset				(0), //disconnected

	// Bidirectionals
	.PS2_CLK			(PS2_CLK1),
 	.PS2_DAT			(PS2_DAT1),

	// Outputs
	.received_data		(ps2_key_data),
	.received_data_en	(ps2_key_pressed)
);

Hexadecimal_To_Seven_Segment Segment0 (
	// Inputs
	.hex_number			(last_data_received[3:0]),

	// Bidirectional

	// Outputs
	.seven_seg_display	(hex0)
);

Hexadecimal_To_Seven_Segment Segment1 (
	// Inputs
	.hex_number			(last_data_received[7:4]),

	// Bidirectional

	// Outputs
	.seven_seg_display	(hex1)
);


endmodule
