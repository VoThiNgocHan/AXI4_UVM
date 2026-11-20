
class master_driver extends uvm_driver #(axi_seq_item);
  `uvm_component_utils(master_driver)

  virtual axi_intf intf;
  axi_seq_item item;

  function new(string name = "master_driver", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual axi_intf)::get(this, "", "vif", intf)) begin
      `uvm_fatal("DRIVER", "FAILED to set interface in config db")
    end
  endfunction

  virtual task run_phase(uvm_phase phase);
    reset_intf();

    forever begin
      seq_item_port.get_next_item(item);
      drive(item);
      seq_item_port.item_done();
    end
  endtask

  task drive(axi_seq_item item);
    case (item.cmd)
      axi_seq_item#()::write: drive_write(item);
      axi_seq_item#()::read:  drive_read(item);
      default: `uvm_error("DRIVER", $sformatf("Unsupported AXI command: %0d", item.cmd))
    endcase
  endtask

  task drive_write(axi_seq_item item);
    `uvm_info("DRIVER", $sformatf("Starting AXI Write: addr=%0h data=%0h", item.awaddr, item.wdata), UVM_MEDIUM)

    if (item.wd_stall_cycles > 0) begin
        intf.WREADY_FORCE_LOW <= 1'b1;

        `uvm_info("WD_STABLE",
                  $sformatf("WREADY forced LOW for %0d cycles",
                            item.wd_stall_cycles),
                  UVM_MEDIUM)
    end

    intf.AWID    <= item.awid;
    intf.AWADDR  <= item.awaddr;
    intf.AWLEN   <= item.awlen;
    intf.AWSIZE  <= item.awsize;
    intf.AWBURST <= item.awburst;
    intf.AWLOCK  <= item.awlock;
    intf.AWCACHE <= item.awcache;
    intf.AWPROT  <= item.awprot;
    intf.AWVALID <= 1'b1;

    while (!intf.AWREADY) begin
      @(posedge intf.ACLK);
    end

    intf.AWVALID <= 1'b0;

    // intf.WDATA  <= item.wdata;
    // intf.WSTRB  <= item.wstrb;
    // intf.WLAST  <= item.wlast;
    // intf.WVALID <= 1'b1;

    // while (!intf.WREADY) begin
    //   @(posedge intf.ACLK);
    // end

    // @(posedge intf.ACLK);
    // intf.WVALID <= 1'b0;
    // intf.WLAST  <= 1'b0;

    // ----------------------------------
    // WRITE DATA CHANNEL
    // ----------------------------------

    intf.WDATA  <= item.wdata;
    intf.WSTRB  <= item.wstrb;
    intf.WLAST  <= item.wlast;

    intf.WVALID <= 1'b1;

    // Hold WVALID and payload stable during stall
    if (item.wd_stall_cycles > 0) begin
        repeat (item.wd_stall_cycles)
            @(posedge intf.ACLK);

        intf.WREADY_FORCE_LOW <= 1'b0;

        `uvm_info("WD_STABLE",
                  "WREADY released",
                  UVM_MEDIUM)
    end

    // Wait for W handshake
    while (intf.WREADY !== 1'b1) begin
        @(posedge intf.ACLK);
    end

    intf.WVALID <= 1'b0;
    intf.WLAST  <= 1'b0;

    intf.BREADY <= 1'b1;
    while (!(intf.BVALID && intf.BREADY)) begin
      @(posedge intf.ACLK);
    end
    item.bresp = intf.BRESP;
    intf.BREADY <= 1'b0;

    `uvm_info("DRIVER", $sformatf("AW/W/B handshake complete: resp=%0d", item.bresp), UVM_MEDIUM)
  endtask

  task drive_read(axi_seq_item item);
    `uvm_info("DRIVER", $sformatf("Starting AXI Read: addr=%0h", item.araddr), UVM_MEDIUM)

    intf.ARID    <= item.arid;
    intf.ARADDR  <= item.araddr;
    intf.ARLEN   <= item.arlen;
    intf.ARSIZE  <= item.arsize;
    intf.ARBURST <= item.arburst;
    intf.ARLOCK  <= item.arlock;
    intf.ARCACHE <= item.arcache;
    intf.ARPROT  <= item.arprot;
    intf.ARVALID <= 1'b1;

    while (!intf.ARREADY) begin
      @(posedge intf.ACLK);
    end

    @(posedge intf.ACLK);
    intf.ARVALID <= 1'b0;

    intf.RREADY <= 1'b1;
    while (!(intf.RVALID && intf.RREADY)) begin
      @(posedge intf.ACLK);
    end
    item.rdata = intf.RDATA;
    item.rresp = intf.RRESP;
    item.rlast = intf.RLAST;
    intf.RREADY <= 1'b0;

    `uvm_info("DRIVER", $sformatf("AR/R handshake complete: rdata=%0h rresp=%0d rlast=%0b", item.rdata, item.rresp, item.rlast), UVM_MEDIUM)
  endtask

  virtual task reset_intf();
    intf.ARESETn <= 1'b0;
    intf.AWVALID <= 1'b0;
    intf.WVALID  <= 1'b0;
    intf.BREADY  <= 1'b0;
    intf.ARVALID <= 1'b0;
    intf.RREADY  <= 1'b0;

    repeat (5) @(posedge intf.ACLK);
    @(negedge intf.ACLK);
    intf.ARESETn <= 1'b1;
  endtask
endclass