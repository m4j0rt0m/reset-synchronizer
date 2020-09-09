// See LICENSE for license details.

`default_nettype none

module reset_sync (/*AUTOARG*/
   // Outputs
   rstn_o,
   // Inputs
   clk_i, arstn_i
   );

  /* ports */
  input   wire  clk_i;
  input   wire  arstn_i;
  output  wire  rstn_o;

  /* regs and wires */
  reg rst_syn_n;
  reg rst_chain_n;

  /* synchronizer logic */
  always @ (posedge clk_i, negedge arstn_i) begin
    if(~arstn_i)
      {rst_syn_n, rst_chain_n} <= 2'b00;
    else
      {rst_syn_n, rst_chain_n} <= {rst_chain_n, 1'b1};
  end

  /* output assignment */
  assign rstn_o = rst_syn_n;

endmodule // reset_sync

`default_nettype wire
