`timescale 1us/1us
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "interface.sv"
`include "design.sv"
`include "sva_checker.sv"
`include "axi_seq_item.sv"
`include "axi_sequence.sv"
`include "master_sequencer.sv"
`include "master_driver.sv"
`include "master_monitor.sv"
`include "master_agent.sv"
`include "scoreboard.sv"
`include "axi_env.sv"
`include "test.sv"

module tb;
  import uvm_pkg::*;

  timeunit 1ns;
  timeprecision 1ps;

  logic ACLK;
  axi_intf intf(.ACLK(ACLK));

  axi_ram dut(
    .clk(intf.ACLK),
    .rst(!intf.ARESETn),
    .s_axi_awid(intf.AWID),
    .s_axi_awaddr(intf.AWADDR),
    .s_axi_awlen(intf.AWLEN),
    .s_axi_awsize(intf.AWSIZE),
    .s_axi_awburst(intf.AWBURST),
    .s_axi_awlock(intf.AWLOCK),
    .s_axi_awcache(intf.AWCACHE),
    .s_axi_awprot(intf.AWPROT),
    .s_axi_awvalid(intf.AWVALID),
    .s_axi_awready(intf.AWREADY),
    .s_axi_wdata(intf.WDATA),
    .s_axi_wstrb(intf.WSTRB),
    .s_axi_wlast(intf.WLAST),
    .s_axi_wvalid(intf.WVALID),
    .s_axi_wready(intf.dut_WREADY),
    .s_axi_bid(intf.BID),
    .s_axi_bresp(intf.BRESP),
    .s_axi_bvalid(intf.BVALID),
    .s_axi_bready(intf.BREADY),
    .s_axi_arid(intf.ARID),
    .s_axi_araddr(intf.ARADDR),
    .s_axi_arlen(intf.ARLEN),
    .s_axi_arsize(intf.ARSIZE),
    .s_axi_arburst(intf.ARBURST),
    .s_axi_arlock(intf.ARLOCK),
    .s_axi_arcache(intf.ARCACHE),
    .s_axi_arprot(intf.ARPROT),
    .s_axi_arvalid(intf.ARVALID),
    .s_axi_arready(intf.ARREADY),
    .s_axi_rid(intf.RID),
    .s_axi_rdata(intf.RDATA),
    .s_axi_rresp(intf.RRESP),
    .s_axi_rlast(intf.RLAST),
    .s_axi_rvalid(intf.RVALID),
    .s_axi_rready(intf.RREADY)
  );

  always @(intf.WREADY_FORCE_LOW) begin
    if (intf.WREADY_FORCE_LOW) begin
      force dut.s_axi_wready = 1'b0;
    end else begin
      release dut.s_axi_wready;
    end
  end

  sva_checker sva(intf);
 //bind tb.dut sva_checker checker_inst (.axi(intf));
  initial begin
    uvm_config_db#(virtual axi_intf)::set(null, "*", "vif", intf);
    uvm_component_registry #(axi_write_read_b2b_test, "axi_write_read_b2b_test")::get();
    run_test("axi_write_read_b2b_test");
  end

  initial begin
    ACLK = 0;
  end

  always #10 ACLK = ~ACLK;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
    #2000;
    $stop;
  end
endmodule