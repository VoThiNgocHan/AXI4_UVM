// interface axi_intf #(
//   parameter int DATA_WIDTH       = 32,
//   parameter int ADDR_WIDTH       = 16,
//   parameter int STRB_WIDTH       = DATA_WIDTH / 8,
//   parameter int ID_WIDTH         = 8,
//   parameter int PIPELINE_OUTPUT  = 0
// )(input logic ACLK);
 
//   logic ARESETn;
//   logic [ID_WIDTH-1:0] AWID;
//   logic [ADDR_WIDTH-1:0] AWADDR;
//   logic [7:0] AWLEN;
//   logic [2:0] AWSIZE;
//   logic [1:0] AWBURST;
//   logic AWLOCK;
//   logic [3:0] AWCACHE;
//   logic [2:0] AWPROT;
//   logic AWVALID;
//   logic AWREADY;
//   logic [DATA_WIDTH-1:0] WDATA;
//   logic [STRB_WIDTH-1:0] WSTRB;
//   logic WLAST;
//   logic WVALID;
//   logic WREADY;
//   logic [ID_WIDTH-1:0] BID;
//   logic [1:0] BRESP;
//   logic BVALID;
//   logic BREADY;
//   logic [ID_WIDTH-1:0] ARID;
//   logic [ADDR_WIDTH-1:0] ARADDR;
//   logic [7:0] ARLEN;
//   logic [2:0] ARSIZE;
//   logic [1:0] ARBURST;
//   logic ARLOCK;
//   logic [3:0] ARCACHE;
//   logic [2:0] ARPROT;
//   logic ARVALID;
//   logic ARREADY;
//   logic [ID_WIDTH-1:0] RID;
//   logic [DATA_WIDTH-1:0] RDATA;
//   logic [1:0] RRESP;
//   logic RLAST;
//   logic RVALID;
//   logic RREADY;
  
  
//   clocking cb @(posedge ACLK);
//     default input #1ps output #1ps;
//   	output ARESETn;
//   endclocking

//   clocking driver_cb @(posedge ACLK);
//     default input #1ps output #1ps;
//     output ARESETn;
//     output AWID;
//     output AWADDR;
//     output AWLEN;
//     output AWSIZE;
//     output AWBURST;
//     output AWLOCK;
//     output AWCACHE;
//     output AWPROT;
//     output AWVALID;
//     input  AWREADY;

//     output WDATA;
//     output WSTRB;
//     output WLAST;
//     output WVALID;
//     input  WREADY;

//     input  BID;
//     input  BRESP;
//     input  BVALID;
//     output BREADY;

//     output ARID;
//     output ARADDR;
//     output ARLEN;
//     output ARSIZE;
//     output ARBURST;
//     output ARLOCK;
//     output ARCACHE;
//     output ARPROT;
//     output ARVALID;
//     input  ARREADY;

//     input  RID;
//     input  RDATA;
//     input  RRESP;
//     input  RLAST;
//     input  RVALID;
//     output RREADY;
//   endclocking

//   modport driver_mp (clocking driver_cb);
  
//   modport tb(clocking cb, output ARESETn);
// endinterface


interface axi_intf #(
  parameter int DATA_WIDTH       = 32,
  parameter int ADDR_WIDTH       = 16,
  parameter int STRB_WIDTH       = DATA_WIDTH / 8,
  parameter int ID_WIDTH         = 8,
  parameter int PIPELINE_OUTPUT  = 0
)(input logic ACLK);
 
  logic ARESETn;
  logic [ID_WIDTH-1:0] AWID;
  logic [ADDR_WIDTH-1:0] AWADDR;
  logic [7:0] AWLEN;
  logic [2:0] AWSIZE;
  logic [1:0] AWBURST;
  logic AWLOCK;
  logic [3:0] AWCACHE;
  logic [2:0] AWPROT;
  logic AWVALID;
  logic AWREADY;
  logic [DATA_WIDTH-1:0] WDATA;
  logic [STRB_WIDTH-1:0] WSTRB;
  logic WLAST;
  logic WVALID;
  logic WREADY;
  logic dut_WREADY;
  assign WREADY = dut_WREADY;
  bit WREADY_FORCE_LOW = 1'b0;
  logic [ID_WIDTH-1:0] BID;
  logic [1:0] BRESP;
  logic BVALID;
  logic BREADY;
  logic [ID_WIDTH-1:0] ARID;
  logic [ADDR_WIDTH-1:0] ARADDR;
  logic [7:0] ARLEN;
  logic [2:0] ARSIZE;
  logic [1:0] ARBURST;
  logic ARLOCK;
  logic [3:0] ARCACHE;
  logic [2:0] ARPROT;
  logic ARVALID;
  logic ARREADY;
  logic [ID_WIDTH-1:0] RID;
  logic [DATA_WIDTH-1:0] RDATA;
  logic [1:0] RRESP;
  logic RLAST;
  logic RVALID;
  logic RREADY;
  
  
  clocking cb @(posedge ACLK);
    default input #1ps output #1ps;
  	output ARESETn;
  endclocking

  clocking driver_cb @(posedge ACLK);
    default input #1ps output #1ps;
    output ARESETn;
    output AWID;
    output AWADDR;
    output AWLEN;
    output AWSIZE;
    output AWBURST;
    output AWLOCK;
    output AWCACHE;
    output AWPROT;
    output AWVALID;
    input  AWREADY;

    output WDATA;
    output WSTRB;
    output WLAST;
    output WVALID;
    input  WREADY;

    input  BID;
    input  BRESP;
    input  BVALID;
    output BREADY;

    output ARID;
    output ARADDR;
    output ARLEN;
    output ARSIZE;
    output ARBURST;
    output ARLOCK;
    output ARCACHE;
    output ARPROT;
    output ARVALID;
    input  ARREADY;

    input  RID;
    input  RDATA;
    input  RRESP;
    input  RLAST;
    input  RVALID;
    output RREADY;
  endclocking

  modport driver_mp (clocking driver_cb);
  
  modport tb(clocking cb, output ARESETn);

endinterface