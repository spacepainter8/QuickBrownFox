// module top;

//     reg [2:0] dut_oc;
//     reg [3:0] dut_a;
//     reg [3:0] dut_b;
//     wire [3:0] dut_f;

//     reg dut_clk;
//     reg dut_rst_n;
//     reg dut_cl; reg dut_ld;
//     reg [3:0] dut_in;
//     reg dut_inc; reg dut_dec;
//     reg dut_sr; reg dut_ir;
//     reg dut_sl; reg dut_il;
//     wire [3:0] dut_out;
    

//     alu dutAlu(dut_oc,dut_a,dut_b,dut_f);

//     register dutReg(dut_clk, dut_rst_n, dut_cl, dut_ld, dut_in, dut_inc, dut_dec, dut_sr,
//     dut_ir, dut_sl, dut_il, dut_out);

//     integer i;
//     integer done;

//     initial begin
        
//             dut_cl = 1'b0; dut_ld = 1'b0; dut_in = 4'b0;
//         dut_inc = 1'b0; dut_dec = 1'b0; dut_sr = 1'b0; dut_ir = 1'b0;
//         dut_sl = 1'b0; dut_il = 1'b0;

//         for (i = 0; i<2**11; i=i+1) begin
//             {dut_oc, dut_a, dut_b} = i;
//             #5;
//         end
//         $stop;
//         done = 1;
//          #7 dut_rst_n = 1'b1;
//         repeat (1000) begin
//             dut_cl = $urandom_range(1); dut_ld = $urandom_range(1);
//             dut_in = $urandom_range(15);
//             dut_inc = $urandom_range(1); dut_dec = $urandom_range(1);
//             dut_sr = $urandom_range(1); dut_ir = $urandom_range(1);
//             dut_sl = $urandom_range(1); dut_il = $urandom_range(1);
//             #10;
//         end
//         $finish;

     

//     end

//     initial begin
//         $monitor(
//             "time = %4d, oc = %b, a = %b, b = %b, f = %b",
//             $time, dut_oc, dut_a, dut_b, dut_f
//         );
//     end

//     always @(done) begin
//         dut_rst_n = 1'b0;
//         dut_clk = 1'b0;
//         forever begin
//             #5 dut_clk = ~dut_clk;
//         end
//     end


//     always @(dut_out) begin
//         $strobe(
//             "time = %4d, cl = %b, ld = %b, inc = %b, dec = %b, sr = %b, ir = %b, sl = %b, il = %b, in = %b, out = %b",
//             $time, dut_cl, dut_ld, dut_inc, dut_dec, dut_sr, dut_ir, dut_sl, dut_il, dut_in, dut_out
//         );
//     end

    


// endmodule


//  $readmemh(MEM_INIT_FILE, ram);


module top;

    reg dut_clk;
    reg dut_rst_n;
    wire dut_we;
    wire [5:0] dut_addr; // mem addr
    wire [15:0] dut_data; // mem data
    wire [15:0] data_out; // mem out

    reg [15:0] dut_cpu_in;
    wire [15:0] dut_cpu_out;
    wire [5:0] dut_pc;
    wire [5:0] dut_sp;



    memory #(.FILE_NAME("mem_init.hex"),
    .ADDR_WIDTH(6), .DATA_WIDTH(16)) dut(dut_clk, dut_we, dut_addr, dut_data, data_out);

    cpu #(.DATA_WIDTH(16), .ADDR_WIDTH(6)) cpu_dut(dut_clk, dut_rst_n,data_out, dut_cpu_in, 
    dut_we, dut_addr, dut_data, dut_cpu_out, dut_pc, dut_sp);

    initial begin
        dut_rst_n = 1'b0;
        dut_clk = 1'b0;
        forever 
            #5 dut_clk = ~dut_clk;
    end

    integer i = 0;
    integer sw = 0;

    initial begin
        dut_cpu_in = 0;
            // memory signALs

        #7 dut_rst_n = 1'b1;
        repeat (1) begin
            dut_cpu_in = 16'h9;
            #10;
        end

    // mem[6] = 9; 

        $finish;
    end

    always @(*)
        $monitor(
            "time = %4d, we = %b, mem_addr = %h, mem_data = %h, mem_out = %h, in = %h, pc = %h, sp = %h, out = %h",
            $time, dut_we, dut_addr, dut_data, data_out, dut_cpu_in, dut_pc, dut_sp, dut_cpu_out
        );

           



endmodule










