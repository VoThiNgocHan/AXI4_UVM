class axi_seq_item #(
    parameter int data_width = 32,
    parameter int addr_width = 16,
    parameter int strb_width = (data_width / 8),
    parameter int id_width = 8
) extends uvm_sequence_item;

//quy định số chu kỳ mà testbench sẽ giữ WREADY=0.
  rand int unsigned wd_stall_cycles;
  constraint c_wd_stall {
    wd_stall_cycles inside {[0:5]};
}

  typedef axi_seq_item#(data_width, addr_width, strb_width, id_width) axi_seq_item;
  `uvm_object_param_utils(axi_seq_item)

  typedef enum bit {write = 1'b0, read = 1'b1} axi_cmd_e;

  rand axi_cmd_e cmd;

  rand logic [id_width-1:0] awid;
  rand logic [addr_width-1:0] awaddr;
  rand logic [7:0] awlen;
  rand logic [2:0] awsize;
  rand logic [1:0] awburst;
  rand logic awlock;
  rand logic [3:0] awcache;
  rand logic [2:0] awprot;

  rand logic [data_width-1:0] wdata;
  rand logic [strb_width-1:0] wstrb;
  rand logic wlast;

  logic [id_width-1:0] bid;
  logic [1:0] bresp;

  rand logic [id_width-1:0] arid;
  rand logic [addr_width-1:0] araddr;
  rand logic [7:0] arlen;
  rand logic [2:0] arsize;
  rand logic [1:0] arburst;
  rand logic arlock;
  rand logic [3:0] arcache;
  rand logic [2:0] arprot;

  logic [id_width-1:0] rid;
  logic [data_width-1:0] rdata;
  logic [1:0] rresp;
  logic rlast;

  constraint c_len {
    awlen inside {[0:255]};
    arlen inside {[0:255]};
  }

  constraint c_burst {
    awburst inside {2'b00, 2'b01, 2'b10};
    arburst inside {2'b00, 2'b01, 2'b10};
  }

  constraint c_size {
    awsize inside {3'b000, 3'b001, 3'b010, 3'b011, 3'b100, 3'b101};
    arsize inside {3'b000, 3'b001, 3'b010, 3'b011, 3'b100, 3'b101};
  }

  function new(string name = "axi_seq_item");
    super.new(name);
  endfunction

  function void print_packet(string tag = "");
    $display("--%0s AXI ITEM----------", tag);
    $display("cmd: %s", cmd.name());
    $display("awid: %0h", awid);
    $display("awaddr: %0h", awaddr);
    $display("awlen: %0d", awlen);
    $display("wdata: %0h", wdata);
    $display("wstrb: %0h", wstrb);
    $display("wlast: %0b", wlast);
    $display("arid: %0h", arid);
    $display("araddr: %0h", araddr);
    $display("arlen: %0d", arlen);
    $display("rdata: %0h", rdata);
    $display("-------------------------------");
  endfunction

endclass