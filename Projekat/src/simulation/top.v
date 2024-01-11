module top;

    reg [2:0] dut_oc;
    reg [3:0] dut_a;
    reg [3:0] dut_b;
    wire [3:0] dut_f;

    alu dutAlu(
        .oc(dut_oc),
        .a(dut_a),
        .b(dut_b),
        .f(dut_f)
    );

    integer i;

    initial begin
        for (i = 0; i<2**11; i=i+1) begin
            {dut_oc, dut_a, dut_b} = i;
            #5;
        end
        $stop;
    end

    initial begin
        $monitor(
            "time = %4d, oc = %b, a = %b, b = %b, f = %b",
            $time, dut_oc, dut_a, dut_b, dut_f
        );
    end


endmodule