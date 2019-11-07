module constituentencoder_tb(
/******** Port declarations ********/
	// Inputs to testbench
	aclr, test_start_notted, clock, block_size_in,
	// Data stream inputs
	c_mem_in, error, encoder_valid, encoder_last_byte,
	// Data stream outputs
	d0_out_stream, d1_out_stream, d2_out_stream,
	d0_mem_out, d1_mem_out, d2_mem_out,
	block_size_out,
	ti_data_out, ti_valid, c_ti_mem_in, ti_ready, c_ti_active, test_start);
	output[7:0] ti_data_out;
	output[7:0] c_ti_mem_in;

	output ti_valid;
/******** Input/Output declarations ********/
	output test_start;
	
	// Inputs to testbench
	input test_start_notted, clock, block_size_in, aclr;
	not(test_start, test_start_notted);
	// Data stream inputs
	output[7:0] c_mem_in;
	output reg error;
	output encoder_valid, encoder_last_byte;
	// Data stream outputs
	output[7:0] d0_out_stream, d1_out_stream, d2_out_stream,
					d0_mem_out, d1_mem_out, d2_mem_out;
	output[11:0] block_size_out;

/******** localparam/wire/reg declarations ********/
	
	localparam BLOCK_SIZE_1056 = 12'd132; // 1056/8
	localparam BLOCK_SIZE_6144 = 12'd768; // 6144/8
	localparam TURBO_DELAY=0;
	
	// addresses for memory
	reg[9:0] c_addr, c_ti_addr, /*c_p_addr,*/ out_addr;
	
	//block size
	reg[11:0] block_size;
	assign block_size_out = block_size;
	
	// Data stream inputs
	//wire[7:0] ti_data_out;
//	wire[7:0] c_p_mem_in;
//	wire[7:0] c_p_mem_in_1056, c_p_mem_in_6144;
	//wire[7:0] c_ti_mem_in;
	wire[7:0] c_mem_in_1056, c_mem_in_6144, c_ti_mem_in_1056, c_ti_mem_in_6144;
	
	// Data stream outputs
	wire c_ready, c_p_ready;
	output ti_ready;
	wire output_active, c_active; 
	output c_ti_active;
//	wire ti_valid;
	wire[7:0] d0_mem_out_1056, d1_mem_out_1056, d2_mem_out_1056, d0_mem_out_6144, d1_mem_out_6144, d2_mem_out_6144;
	
	// Interleaver - CE wires
	wire interleaver_last_byte;
	
/******** Wire/output assignments ********/
	
	assign output_active = (out_addr <= block_size);
	assign c_active = (c_addr < block_size && test_in_progress);
	assign c_ti_active = (c_ti_addr < block_size && test_in_progress);
	
/******** Module instantiations ********/

	// Instantiate encoder
	convolutional_encoder conv_encoder(
		// General inputs
		.aclr(aclr || test_start), .clock(clock),
		// Control signal inputs
		.crc_valid(c_active), .turbo_valid(ti_valid),
		.crc_last_byte(c_addr == (block_size - 1'd1)), .turbo_last_byte(interleaver_last_byte), .output_ready(output_active),
		// Data stream inputs
		.crc_in_stream(c_mem_in), .turbo_in_stream(ti_data_out),
		// Control signal outputs
		.c_ready(c_ready), .c_p_ready(c_p_ready), .output_valid(encoder_valid), .output_last_byte(encoder_last_byte),
		// Data stream outputs
		.d0_out(d0_out_stream), .d1_out(d1_out_stream), .d2_out(d2_out_stream));
		
/***************Memory Instantiation********************/

		// Instantiate Memory for Turbo Input (1056 bits)
//		tb_mem_turbo mti(
//			c_p_addr,
//			clock,
//			1'b1,
//			c_p_mem_in_1056);
//		tb_mem_turbo_6144 mti_6144(
//			c_addr,
//			clock,
//			1'b1,
//			c_p_mem_in_6144);
//		assign c_p_mem_in = block_size_in ? c_p_mem_in_6144 : c_p_mem_in_1056;
			
		// Instantiate Memory for CRC Input (1056 bits)
		// CRC for CE
		tb_mem mci(
			c_addr_next,
			clock,
			1'b1,
			c_mem_in_1056);
		tb_mem_6144 mci_6144(
			c_addr_next,
			clock,
			1'b1,
			c_mem_in_6144);
		assign c_mem_in = block_size_in ? c_mem_in_6144 : c_mem_in_1056;
		
		// CRC for TI
		tb_mem_ti mci_ti(
			c_ti_addr_next,
			clock,
			1'b1,
			c_ti_mem_in_1056);
		tb_mem_ti_6144 mci_6144_ti(
			c_ti_addr_next,
			clock,
			1'b1,
			c_ti_mem_in_6144);
		assign c_ti_mem_in = block_size_in ? c_ti_mem_in_6144 : c_ti_mem_in_1056;
		
		// Instantiate Memory for CE First Output (6144 bits)
		test_output_d0_6144 md0_6144(
			out_addr_next,
			clock,
			1'b1,
			d0_mem_out_6144);
		test_output_d0 md0(
			out_addr_next,
			clock,
			1'b1,
			d0_mem_out_1056);
	
		assign d0_mem_out = block_size_in ? d0_mem_out_6144 : d0_mem_out_1056;
		// Instantiate Memory for CE CRC Output (1056 bits)
		test_output_d1 md1(
			out_addr_next,
			clock,
			1'b1,
			d1_mem_out_1056);
		// Instantiate Memory for CRC First Output (6144 bits)
		test_output_d1_6144 md1_6144(
			out_addr_next,
			clock,
			1'b1,
			d1_mem_out_6144);
	
		assign d1_mem_out = block_size_in ? d1_mem_out_6144 : d1_mem_out_1056;
			
		// Instantiate Memory for CE Turbo Output (1056 bits)
		test_output_d2 md2(
			out_addr_next,
			clock,
			1'b1,
			d2_mem_out_1056);
		// Instantiate Memory for CE TURBO Output (6144 bits)
		test_output_d2_6144 md2_6144(
			out_addr_next,
			clock,
			1'b1,
			d2_mem_out_6144);
	
		assign d2_mem_out = block_size_in ? d2_mem_out_6144 : d2_mem_out_1056;
		
		interleaver ti(
			.clk(clock),
			.asyn_reset(test_start || aclr),
			.vld_crc(c_ti_active),
			.rdy_out(c_p_ready),
			.cbs(block_size_in),
			.data_in(c_ti_mem_in),
			.rdy_crc(ti_ready),
			.vld_out(ti_valid),
			.last_byte(interleaver_last_byte),
			.data_out(ti_data_out)
		);

wire [9:0] c_addr_next = c_active && c_ready && test_in_progress && !aclr ? c_addr + 10'd1 : c_addr;
//wire [9:0] c_p_addr_next = c_p_active && c_p_ready && !aclr ? c_p_addr + 10'd1 : c_p_addr;
wire [9:0] out_addr_next = output_active && encoder_valid && test_in_progress &&  !aclr ? out_addr + 10'd1 : out_addr;
wire [9:0] c_ti_addr_next = c_ti_active && ti_ready && test_in_progress && !aclr ? c_ti_addr + 10'd1 : c_ti_addr;
wire test_in_progress = test_started && !test_start;
reg test_started;
/******** Reg assignments ********/
initial 
	begin
			block_size = BLOCK_SIZE_6144;
			test_started <= 1'd0;
			{c_addr, c_ti_addr, out_addr} <= 10'd0;
			error <= 0;
	end
always@(posedge clock, posedge aclr)
	begin
		if(aclr) begin
			{c_addr, c_ti_addr, out_addr} <= 10'd0;
			error <= 0;
			block_size <= block_size_in ? BLOCK_SIZE_6144 : BLOCK_SIZE_1056;
			test_started <= 1'd0;
		end
		else if(test_start) begin
			{c_addr, c_ti_addr, out_addr} <= 10'd0;
			error <= 0;
			block_size <= block_size_in ? BLOCK_SIZE_6144 : BLOCK_SIZE_1056;
			test_started <= 1'd1;
		end
		else if(clock && test_in_progress) begin
			{c_addr, out_addr, c_ti_addr} <= {c_addr_next, out_addr_next, c_ti_addr_next};

			if(encoder_valid)
				error <= error || (d0_mem_out != d0_out_stream) || (d1_mem_out != d1_out_stream) || (d2_mem_out != d2_out_stream);
		end
	end
endmodule
