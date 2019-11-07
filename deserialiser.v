module deserialiser(
/******** Port declarations ********/
	// General inputs
	clock, aclr,
	// Input stream/flow inputs
	bits_in, bits_in_valid, byte_out_ready,
	// Output stream/flow outputs
	byte_out, byte_out_valid, bits_in_ready);
	
/******** Inputs/Outputs declarations ********/
	
	// General inputs
	input clock, aclr;
	// Input stream/flow inputs
	input bits_in, bits_in_valid, byte_out_ready;
	// Output stream/flow outputs
	output[7:0] byte_out;
	output byte_out_valid, bits_in_ready;
	
/******** Reg/Wire declarations ********/	
	
	reg [8:0] curByte;
	
	wire write_cycle;
	
/******** Wire/output assignments ********/
	
	assign write_cycle = byte_out_valid && byte_out_ready;
	assign byte_out_valid = curByte[8];
	assign bits_in_ready = ~byte_out_valid || write_cycle; // ready for a new bit if there is no byte or if current byte is about to be read out
	assign byte_out = curByte[7:0];
	
/******** Reg assignments ********/
	
	always @(posedge clock, posedge aclr) begin
		if(aclr)
			curByte <= 9'd0;
		else if (clock) begin
			if (write_cycle && ~bits_in_valid)
				curByte <= 9'd0;
			else if(bits_in_ready && bits_in_valid) // if it is asserting ready on a valid input, it must take the input
				curByte = curByte && !byte_out_valid ? {curByte[7:0], bits_in} : {7'd0, 1'b1, bits_in}; //create a new byte if there isn't one or the previous one is about to be read out
		end
		
	end

endmodule
