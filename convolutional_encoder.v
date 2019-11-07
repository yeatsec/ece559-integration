module convolutional_encoder(
/******** Port declarations ********/
	// General inputs
	aclr, clock,
	// Control signal inputs
	crc_valid, turbo_valid, crc_last_byte, turbo_last_byte, output_ready,
	// Data stream inputs
	crc_in_stream, turbo_in_stream,
	// Control signal outputs
	c_ready, c_p_ready, output_valid, output_last_byte,
	// Data stream outputs
	d0_out, d1_out, d2_out);

/******** Input/Output declarations ********/

	// General inputs
	input aclr, clock;
	// Control signal inputs
	input crc_valid, turbo_valid, crc_last_byte, turbo_last_byte, output_ready;
	// Data stream inputs
	input[7:0] crc_in_stream, turbo_in_stream;
	// Control signal outputs
	output c_ready, c_p_ready, output_valid, output_last_byte;
	// Data stream outputs
	output[7:0] d0_out, d1_out, d2_out;

/******** Wire declarations ********/

	wire fifo_empty, fifo_full, tbs_valid;
	wire [7:0] d0_stream, d1_stream, d2_stream;
	wire [7:0] x_stream, x_p_stream, z_stream, z_p_stream;
	wire x_stream_valid, x_p_stream_valid, z_stream_valid, z_p_stream_valid;
	wire x_stream_ready, x_p_stream_ready, z_stream_ready, z_p_stream_ready;
	wire u_last_byte, l_last_byte, tbs_last_byte;
	
	assign output_valid = ~fifo_empty;
	
/******** Constituent encoder declarations ********/

	constituent_encoder upper_ce(.clock(clock), .aclr(aclr),
			.in_last_byte(turbo_last_byte), .data_in(crc_in_stream),
			.data_in_valid(crc_valid), .data_in_ready(c_ready),
			.x_data_out_ready(x_stream_ready), .x_data_out(x_stream), .x_data_out_valid(x_stream_valid),
			.z_data_out_ready(z_stream_ready), .z_data_out(z_stream), .z_data_out_valid(z_stream_valid),
			.out_last_byte(u_last_byte));

	constituent_encoder lower_ce(.clock(clock), .aclr(aclr),
			.in_last_byte(turbo_last_byte), .data_in(turbo_in_stream),
			.data_in_valid(turbo_valid), .data_in_ready(c_p_ready),
			.x_data_out_ready(x_p_stream_ready), .x_data_out(x_p_stream), .x_data_out_valid(x_p_stream_valid),
			.z_data_out_ready(z_p_stream_ready), .z_data_out(z_p_stream), .z_data_out_valid(z_p_stream_valid),
			.out_last_byte(l_last_byte));

/******** Tail bit swapper ********/

	tail_bit_swapping tbs(
		.aclr(aclr), .clock(clock), .x_in(x_stream), .x_p_in(x_p_stream),
		.z_in(z_stream), .z_p_in(z_p_stream), .x_last_byte(u_last_byte),
		.x_p_last_byte(l_last_byte), .z_last_byte(u_last_byte), .z_p_last_byte(l_last_byte),
		.x_valid(x_stream_valid), .x_p_valid(x_p_stream_valid), .z_valid(z_stream_valid), .z_p_valid(z_p_stream_valid),
		.output_ready(~fifo_full),
		.d0_data(d0_stream), .d1_data(d1_stream), .d2_data(d2_stream),
		.output_valid(tbs_valid), .out_last_byte(tbs_last_byte),
		.x_ready(x_stream_ready), .z_ready(z_stream_ready), .x_p_ready(x_p_stream_ready), .z_p_ready(z_p_stream_ready)
	);

/******** FIFO declarations ********/

	fifo myfifo(.aclr(aclr), .clock(clock), .data({d0_stream, d1_stream, d2_stream, tbs_last_byte}),
			.rdreq(output_valid && output_ready), .wrreq(tbs_valid),
			.empty(fifo_empty), .full(fifo_full),
			.q({d0_out, d1_out, d2_out, output_last_byte}));
endmodule
