module bitserial_block(
/******** Port declarations ********/
	// General inputs
	clock, aclr,
	// Data inputs
	in_last_bits, bits_in,
	// Control inputs
	bits_in_valid, z_bits_out_ready, x_bits_out_ready,
	// Data outputs
	z_bits_out, x_bits_out,
	// Control outputs
	bits_in_ready, z_bits_out_valid, x_bits_out_valid, tail);
	
/******** Input/Output declarations ********/

	// General inputs
	input clock, aclr;
	// Data inputs
	input in_last_bits, bits_in;
	// Control inputs
	input bits_in_valid, z_bits_out_ready, x_bits_out_ready;
	// Data outputs
	output z_bits_out, x_bits_out;
	// Control outputs
	output bits_in_ready, z_bits_out_valid, x_bits_out_valid, tail;
	
/******** Reg/wire declarations ********/
	
	reg [5:0] counter;
	wire encoder_enable;
	
/******** Wire/Output assignments ********/

	assign encoder_enable = (bits_in_ready && bits_in_valid) || tail;
	assign z_bits_out_valid = encoder_enable;
	assign x_bits_out_valid = z_bits_out_valid;
	assign bits_in_ready = (z_bits_out_ready && x_bits_out_ready && ~tail);
	assign tail = counter && counter <= 5'd8;

/******** Reg assignments ********/	

	always @(posedge clock, posedge aclr) begin
		if(aclr)
			counter <= 5'd0;
		else if(clock) begin
			if(counter)
				counter <= counter - {4'd0, encoder_enable}; //only decrement the counter on cycles where encoding is occurring
			else if(in_last_bits && bits_in_valid)
				counter <= 5'd15;
		end
	end
	
/******** Encoder ********/
	
	encoder_block enc(.clock(clock), .compute_enable(encoder_enable), .aclr(aclr), 
					  .tail(tail), .c(bits_in), .x(x_bits_out), .z(z_bits_out));
endmodule
