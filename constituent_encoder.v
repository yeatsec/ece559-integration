module constituent_encoder(
/******** Port declarations ********/
	// General inputs
	clock, aclr,
	// Last byte input
	in_last_byte,
	// Data stream inputs
	data_in, data_in_valid,
	// Encoder control inputs
	z_data_out_ready, x_data_out_ready,
	// Data stream outputs
	z_data_out, z_data_out_valid, x_data_out, x_data_out_valid,
	// Encoder control outputs
	data_in_ready,
	// Last byte output
	out_last_byte);
	
/******** Input/Output declarations ********/
	
	// General inputs
	input clock, aclr;
	// Last byte input
	input in_last_byte;
	// Data stream inputs
	input[7:0] data_in;
	input data_in_valid;
	// Encoder control inputs
	input z_data_out_ready, x_data_out_ready;
	// Data stream outputs
	output[7:0] z_data_out, x_data_out;
	output z_data_out_valid, x_data_out_valid;
	// Encoder control outputs
	output data_in_ready;
	// Last byte output
	output reg out_last_byte;
	
/******** reg/wire declarations ********/
	
	reg in_last_byte_reg;
	
	wire bits_in, bits_in_valid, bits_in_ready, last_bits;
	wire z_bits_out, z_bits_out_ready, z_bits_out_valid, x_bits_out, x_bits_out_ready, x_bits_out_valid;
	
/******** Reg assignments ********/
	
	always @(posedge clock, posedge aclr) begin
		if(aclr) begin
			in_last_byte_reg <= 0;
			out_last_byte <= 0;
		end
		else if(clock) begin
			if(data_in_valid && data_in_ready)
				in_last_byte_reg <= in_last_byte;
			if(z_bits_out_ready)
				out_last_byte <= last_bits;
		end
	end
	
/******** De/Serializing Submodules ********/
	
	serialiser ser(.clock(clock), .aclr(aclr), .byte_in(data_in), .byte_in_valid(data_in_valid),
						.byte_ready(data_in_ready), .bits_out(bits_in), .bits_out_valid(bits_in_valid),
						.bits_ready(bits_in_ready));
		
	bitserial_block enc(.clock(clock), .aclr(aclr), .bits_in(bits_in), .bits_in_valid(bits_in_valid), 
	                    .bits_in_ready(bits_in_ready), .z_bits_out(z_bits_out), .z_bits_out_valid(z_bits_out_valid),
							  .z_bits_out_ready(z_bits_out_ready), .x_bits_out(x_bits_out), .x_bits_out_valid(x_bits_out_valid),
							  .x_bits_out_ready(x_bits_out_ready), .tail(last_bits), .in_last_bits(in_last_byte_reg));
	
	deserialiser z_deser(.clock(clock), .aclr(aclr), .bits_in(z_bits_out), .bits_in_valid(z_bits_out_valid),
								.bits_in_ready(z_bits_out_ready), .byte_out(z_data_out), .byte_out_valid(z_data_out_valid), 
								.byte_out_ready(z_data_out_ready));
							 
	deserialiser x_deser(.clock(clock), .aclr(aclr), .bits_in(x_bits_out), .bits_in_valid(x_bits_out_valid),
								.bits_in_ready(x_bits_out_ready), .byte_out(x_data_out), .byte_out_valid(x_data_out_valid), 
								.byte_out_ready(x_data_out_ready));
endmodule
