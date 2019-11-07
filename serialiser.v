module serialiser(
/******** Port declarations ********/
	// General inputs
	clock, aclr,
	// Data stream inputs
	byte_in, byte_in_valid, bits_ready,
	// Data stream outputs
	byte_ready, bits_out, bits_out_valid);

/******** Inputs/Outputs declarations ********/
	
	// General inputs
	input clock, aclr;
	// Data stream inputs
	input[7:0] byte_in;
	input byte_in_valid, bits_ready;
	// Data stream outputs
	output byte_ready, bits_out, bits_out_valid;
	
/******** Wire/Reg declarations ********/
	
	reg [8:0] curByte;
	
/******** Output assignments ********/
	
	assign byte_ready = (curByte[7:0] == 8'd0) || (curByte[6:0] == 7'd0 && bits_ready); //second case allows uninterrupted reads
	assign bits_out_valid = (curByte[7:0] != 8'd0);
	assign bits_out = curByte[8];
	
/******** Reg assignments ********/	

	always @(posedge clock, posedge aclr) begin
		if(aclr)
			curByte <= 9'd0;
		else if (clock) begin
			if (byte_ready && byte_in_valid)
				curByte <= {byte_in, 1'b1};
			else if(bits_ready)
				curByte = curByte << 1;
		end
		
	end

endmodule
