module stavka_b; 

    reg dut_control; 
    reg [2:0] dut_m1; 
    reg [2:0] dut_e1; 
    reg [2:0] dut_m2; 
    reg [2:0] dut_e2; 
    wire [5:0] dut_m_out; 
    wire [3:0] dut_e_out; 
    
    stavka_a dut(
		.control(dut_control),
		.m1(dut_m1),
		.e1(dut_e1),
		.m2(dut_m2),
		.e2(dut_e2),
		.m_out(dut_m_out),
		.e_out(dut_e_out)
	);
    
    integer i;
    
    initial begin
        for (i = 0; i < 2**13; i = i + 1) begin
            {dut_control, dut_m1, dut_e1, dut_m2, dut_e2} = i;
            #5;
        end
        $finish;
    end
    
    initial begin
        $monitor(
			"time = %4d, control = %b, m1 = %d, e1 = %d, m2 = %d, e2 = %d, m_out = %d, e_out = %d",
			$time, dut_control, dut_m1, dut_e1, dut_m2, dut_e2, dut_m_out, dut_e_out
        );
    end
    
endmodule
