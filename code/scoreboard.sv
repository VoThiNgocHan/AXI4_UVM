class axi_scoreboard extends uvm_subscriber #(axi_seq_item);
  `uvm_component_utils(axi_scoreboard)

  bit [31:0] expected_mem [bit [15:0]];

  function new(string name = "axi_scoreboard", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void write(axi_seq_item t);
    if (t.cmd == axi_seq_item#()::write) begin
      expected_mem[t.awaddr] = t.wdata;
      `uvm_info("SCOREBOARD", $sformatf("WRITE recorded: addr=%0h data=%0h", t.awaddr, t.wdata), UVM_MEDIUM)
    end else if (t.cmd == axi_seq_item#()::read) begin
      if (expected_mem.exists(t.araddr)) begin
        if (t.rdata == expected_mem[t.araddr]) begin
          `uvm_info("SCOREBOARD", $sformatf("READ DATA MATCH: addr=%0h got=%0h expected=%0h", t.araddr, t.rdata, expected_mem[t.araddr]), UVM_LOW)
        end else begin
          `uvm_error("SCOREBOARD", $sformatf("READ DATA MISMATCH: addr=%0h got=%0h expected=%0h", t.araddr, t.rdata, expected_mem[t.araddr]))
        end
      end else begin
        `uvm_error("SCOREBOARD", $sformatf("No expected write for addr=%0h", t.araddr))
      end
    end
  endfunction
endclass