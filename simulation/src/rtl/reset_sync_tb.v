
`default_nettype none

module reset_sync_tb ();

  /* simulation parameters */
  localparam SIM_CYCLES = 1000;
  localparam CLK_PERIOD = 10;
  localparam RST_PERIOD_LIMIT = 100;

  /* dut ports declaration */
  reg   clk_i;
  reg   arstn_i;
  wire  rstn_o;

  /* initialization */
  initial begin
    clk_i = 0;
    arstn_i = 0;
    `ifdef __VCD__
    $dumpfile("reset_sync_tb.vcd");
    $dumpvars();
    `endif
    $monitor("[%5d] : clk=%b / arstn=%b / rstn=%b", $time, clk_i, arstn_i, rstn_o);
    #SIM_CYCLES $finish;
  end

  /* clock */
  always
    #CLK_PERIOD clk_i = ~clk_i;

  /* asynchronous reset */
  always
    #($urandom_range(CLK_PERIOD,RST_PERIOD_LIMIT)) arstn_i = ~arstn_i;

  /* dut */
  reset_sync
    dut (
      .clk_i    (clk_i),
      .arstn_i  (arstn_i),
      .rstn_o   (rstn_o)
    );

endmodule

`default_nettype wire
