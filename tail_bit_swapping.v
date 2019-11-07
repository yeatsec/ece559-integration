module tail_bit_swapping(
/******** Port declarations ********/
	// General inputs
	aclr, clock,
	// Input streams
	x_in, x_p_in, z_in, z_p_in,
	// Last byte signals
	x_last_byte, x_p_last_byte, z_last_byte, z_p_last_byte,
	// Encoder valid signals
	x_valid, x_p_valid, z_valid, z_p_valid,
	// Output signals
	output_ready, output_valid, out_last_byte,
	// Output bytes
	d0_data, d1_data, d2_data,
	// Ready out signals
	x_ready, z_ready, x_p_ready, z_p_ready
);
/******** Input/Output declarations ********/
	// General inputs
	input aclr, clock;
	// Input streams
	input[7:0] x_in, x_p_in, z_in, z_p_in;
	// Last byte signals
	input x_last_byte, x_p_last_byte, z_last_byte, z_p_last_byte;
	// Encoder valid signals
	input x_valid, x_p_valid, z_valid, z_p_valid;
	// Ready signals
	input output_ready;
	// Output bytes
	output[7:0] d0_data, d1_data, d2_data;
	// Ready out signals
	output x_ready, x_p_ready, z_ready, z_p_ready;
	output output_valid, out_last_byte;
	
/******** Reg/Wire declarations ********/

	reg[7:0] x_reg, x_p_reg, z_reg, z_p_reg;
	reg x_valid_reg, x_p_valid_reg, z_valid_reg, z_p_valid_reg;
	reg x_last_byte_reg, x_p_last_byte_reg, z_last_byte_reg, z_p_last_byte_reg;
	
	wire all_last_byte, write_cycle;
	assign write_cycle = output_valid && output_ready;
	assign all_last_byte = x_last_byte_reg && x_p_last_byte_reg && z_last_byte_reg && z_p_last_byte_reg;
	
/******** Output assignments ********/

	assign out_last_byte = all_last_byte;
	
	assign output_valid = x_valid_reg && z_valid_reg && z_p_valid_reg && x_p_valid_reg;
	
	assign x_ready = write_cycle || !x_valid_reg;
	assign z_ready = write_cycle || !z_valid_reg;
	assign z_p_ready = write_cycle || !z_p_valid_reg;
	assign x_p_ready = write_cycle || !x_p_valid_reg;
	
	assign d0_data = all_last_byte ? {x_reg[7], z_reg[6], x_p_reg[7], z_p_reg[6], 4'd0} : x_reg;
	
	assign d1_data = all_last_byte ? {z_reg[7], x_reg[5], z_p_reg[7], x_p_reg[5], 4'd0} : z_reg;
	assign d2_data = all_last_byte ? {x_reg[6], z_reg[5], x_p_reg[6], z_p_reg[5], 4'd0} : z_p_reg;
	
/******** Reg assignments ********/

	always @(posedge clock, posedge aclr)
	begin
		if(aclr)	// Clear regs
			{x_reg, x_p_reg, z_reg, z_p_reg} <= 32'd0;
		else if(clock)	// Update reg values
			begin
				if(x_ready) begin
					x_reg <= x_in;
					x_valid_reg <= x_valid;
					x_last_byte_reg <= x_last_byte;
				end
				if(x_p_ready) begin
					x_p_reg <= x_p_in;
					x_p_valid_reg <= x_p_valid;
					x_p_last_byte_reg <= x_p_last_byte;
				end
				if(z_ready) begin
					z_reg <= z_in;
					z_valid_reg <= z_valid;
					z_last_byte_reg <= z_last_byte;
				end
				if(z_p_ready) begin
					z_p_reg <= z_p_in;
					z_p_valid_reg <= z_p_valid;
					z_p_last_byte_reg <= z_p_last_byte;
				end
			end
	end
endmodule
