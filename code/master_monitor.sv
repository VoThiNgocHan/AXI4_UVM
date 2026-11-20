// class master_monitor extends uvm_monitor;
//   `uvm_component_utils(master_monitor)
  
//   uvm_analysis_port #(axi_seq_item) monitor_port;
//   virtual axi_intf intf;

//   function new (string name = "master_monitor", uvm_component parent);
//     super.new(name, parent);
//     monitor_port = new("monitor_port", this);
//   endfunction
  
//   virtual function void build_phase(uvm_phase phase);
//     super.build_phase(phase);
//    if(!uvm_config_db#(virtual axi_intf)::get(this, "", "vif", intf)) begin
//       `uvm_fatal ("MONITOR", "Interface not found in uvm_config_db")
//    end
//   endfunction
  
//    virtual function void connect_phase(uvm_phase phase);
//     super.connect_phase(phase);
//    endfunction
   
//    virtual task run_phase(uvm_phase phase);
//   // @(posedge intf.ACLK);
//    forever begin
//     axi_seq_item item;
//     @(posedge intf.ACLK);
//     if(intf.ARESETn && intf.AWVALID && intf.AWREADY) begin
//       item = axi_seq_item::type_id::create("item");
//     item.awid = intf.AWID;
//     item.awaddr = intf.AWADDR;
//     item.awlen = intf.AWLEN;
//     item.awsize = intf.AWSIZE;
//     item.awburst = intf.AWBURST;
//     monitor_port.write(item);
//     `uvm_info("MONITOR", $sformatf("AW transaction observed: ID=%0d, ADDR=%0h, LEN=%0d, SIZE=%0d, BURST=%0d", item.awid, item.awaddr, item.awlen, item.awsize, item.awburst), UVM_MEDIUM)
//    end
//    end
//    endtask
// endclass



class master_monitor extends uvm_monitor;
  `uvm_component_utils(master_monitor)

  uvm_analysis_port #(axi_seq_item) monitor_port;
  virtual axi_intf intf;

  axi_seq_item write_item;
  axi_seq_item read_item;

  function new(string name = "master_monitor", uvm_component parent);
    super.new(name, parent);
    monitor_port = new("monitor_port", this);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual axi_intf)::get(this, "", "vif", intf)) begin
      `uvm_fatal("MONITOR", "Interface not found in uvm_config_db")
    end
  endfunction

  virtual task run_phase(uvm_phase phase);
    write_item = null;
    read_item = null;

    forever begin
      @(posedge intf.ACLK);

      if (intf.ARESETn && intf.AWVALID && intf.AWREADY) begin
        write_item = axi_seq_item#()::type_id::create("write_item");
        write_item.cmd = axi_seq_item#()::write;
        write_item.awid = intf.AWID;
        write_item.awaddr = intf.AWADDR;
        write_item.awlen = intf.AWLEN;
        write_item.awsize = intf.AWSIZE;
        write_item.awburst = intf.AWBURST;
        `uvm_info("MONITOR", $sformatf("AW handshake observed: ID=%0d ADDR=%0h LEN=%0d SIZE=%0d BURST=%0d", write_item.awid, write_item.awaddr, write_item.awlen, write_item.awsize, write_item.awburst), UVM_MEDIUM)
      end

      if (intf.ARESETn && intf.WVALID && intf.WREADY && write_item != null) begin
        write_item.wdata = intf.WDATA;
        write_item.wstrb = intf.WSTRB;
        write_item.wlast = intf.WLAST;
        write_item.bresp = 2'b00;
        `uvm_info("MONITOR", $sformatf("W handshake observed: data=%0h strb=%0h last=%0b", write_item.wdata, write_item.wstrb, write_item.wlast), UVM_MEDIUM)
      end

      if (intf.ARESETn && intf.BVALID && intf.BREADY && write_item != null) begin
        write_item.bresp = intf.BRESP;
        monitor_port.write(write_item);
        `uvm_info("MONITOR", $sformatf("B response observed: addr=%0h resp=%0d", write_item.awaddr, write_item.bresp), UVM_MEDIUM)
        write_item = null;
      end

      if (intf.ARESETn && intf.ARVALID && intf.ARREADY) begin
        read_item = axi_seq_item#()::type_id::create("read_item");
        read_item.cmd = axi_seq_item#()::read;
        read_item.arid = intf.ARID;
        read_item.araddr = intf.ARADDR;
        read_item.arlen = intf.ARLEN;
        read_item.arsize = intf.ARSIZE;
        read_item.arburst = intf.ARBURST;
        `uvm_info("MONITOR", $sformatf("AR handshake observed: ID=%0d ADDR=%0h LEN=%0d SIZE=%0d BURST=%0d", read_item.arid, read_item.araddr, read_item.arlen, read_item.arsize, read_item.arburst), UVM_MEDIUM)
      end

      if (intf.ARESETn && intf.RVALID && intf.RREADY && read_item != null) begin
        read_item.rdata = intf.RDATA;
        read_item.rresp = intf.RRESP;
        read_item.rlast = intf.RLAST;
        `uvm_info("MONITOR", $sformatf("R data observed: addr=%0h data=%0h resp=%0d last=%0b", read_item.araddr, read_item.rdata, read_item.rresp, read_item.rlast), UVM_MEDIUM)

        if (read_item.rlast) begin
          monitor_port.write(read_item);
          read_item = null;
        end
      end
    end
  endtask
endclass