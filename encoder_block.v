module encoder_block(
/******** Port declarations ********/
	// General inputs
	clock, compute_enable, aclr,
	// Tail bit control signal
	tail, 
	// Data in
	c,
	// Data out
	x, z);
	
/******** Input/Output declarations ********/

	// General inputs
	input clock, compute_enable, aclr;
	// Tail bit control signal
	input tail;
	// Data in
	input c;
	// Data out
	output x, z;

/******** Reg/Wire declarations ********/

	wire instream;
	reg [2:0] d;

/******** Wire/Output assignments ********/
	
	assign instream = tail ? d[0] ^ d[1] : c;
	assign x = instream;
	assign z = instream ^ d[0] ^ d[1] ^ d[2] ^ d[0];
	
/******** Reg assignments ********/
	
	always @(posedge clock, posedge aclr) begin
	
		if(aclr)
			d <= 3'b000;
		else if(clock && compute_enable) begin
			d[0] <= d[1];
			d[1] <= d[2];
			d[2] <= instream ^ d[0] ^ d[1];
		end
	end

endmodule
