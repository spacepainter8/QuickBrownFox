module topSim #(
    parameter DIVISOR = 50_000_000,
    parameter FILE_NAME = "mem_init.mif",
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 16
) (
    input clk,
    input rst_n,
    input [2:0] btn,
    input [8:0] sw,
    output [9:0] led,
    output [27:0] hex
);


  // clock divisor
  wire clk_d;

  clk_div #(
      .DIVISOR(DIVISOR)
  ) clk_divisor (
      .clk  (clk),
      .rst_n(rst_n),
      .out  (clk_d)
  );

  // memory
  wire mem_we;
  wire [ADDR_WIDTH-1:0] mem_addr;
  wire [DATA_WIDTH-1:0] mem_data, mem_out;

  memory #(
      .FILE_NAME (FILE_NAME),
      .ADDR_WIDTH(ADDR_WIDTH),
      .DATA_WIDTH(DATA_WIDTH)
  ) mem (
      .clk (clk_d),
      .we  (mem_we),
      .addr(mem_addr),
      .data(mem_data),
      .out (mem_out)
  );

  // cpu
  wire [DATA_WIDTH-1:0] cpu_in, cpu_out;
  wire [ADDR_WIDTH-1:0] cpu_sp, cpu_pc;
  assign cpu_in = {{(DATA_WIDTH - 4) {1'b0}}, sw[3:0]};
  // led 9:0
  assign led = {{5{1'b0}}, cpu_out[4:0]};

  cpu #(
      .ADDR_WIDTH(ADDR_WIDTH),
      .DATA_WIDTH(DATA_WIDTH)
  ) cpu_top (
      .clk(clk_d),
      .rst_n(rst_n),
      .mem_in(mem_out),
      .in(cpu_in),
      .mem_we(mem_we),
      .mem_addr(mem_addr),
      .mem_data(mem_data),
      .out(cpu_out),
      .pc(cpu_pc),
      .sp(cpu_sp)
  );

  // bcds

  wire [3:0] sp_ones, sp_tens;
  bcd sp_bcd (
      .in  (cpu_sp),
      .ones(sp_ones),
      .tens(sp_tens)
  );

  wire [3:0] pc_ones, pc_tens;
  bcd pc_bcd (
      .in  (cpu_pc),
      .ones(pc_ones),
      .tens(pc_tens)
  );

  // ssds

  ssd ssd0 (
    .in(sp_tens),
    .out(hex[27:21])
  );
  ssd ssd1 (
    .in(sp_ones),
    .out(hex[20:14])
  );

  ssd ssd2 (
    .in(pc_tens),
    .out(hex[13:7])
  );

  ssd ssd3 (
    .in(pc_ones),
    .out(hex[6:0])
  );


endmodule
