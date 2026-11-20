
class test_base extends uvm_test;
  `uvm_component_utils(test_base)

  axi_env env;

  function new(string name = "test_base", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = axi_env::type_id::create("env", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
  endtask
endclass

class axi_single_write_test extends test_base;
  `uvm_component_utils(axi_single_write_test)

  function new(string name = "axi_single_write_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    axi_write_sequence seq;
    phase.raise_objection(this);
    `uvm_info("TEST", "Starting AXI Single Write", UVM_LOW)
    seq = axi_write_sequence::type_id::create("seq", this);
    seq.start(env.agent.sequencer);
    `uvm_info("TEST", "AXI Single Write test PASSED", UVM_LOW)
    phase.drop_objection(this);
  endtask
endclass

class axi_single_read_test extends test_base;
  `uvm_component_utils(axi_single_read_test)

  function new(string name = "axi_single_read_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    axi_read_sequence seq;
    phase.raise_objection(this);
    `uvm_info("TEST", "Starting AXI Single Read", UVM_LOW)
    seq = axi_read_sequence::type_id::create("seq", this);
    seq.start(env.agent.sequencer);
    `uvm_info("TEST", "AXI Single Read test PASSED", UVM_LOW)
    phase.drop_objection(this);
  endtask
endclass

class axi_write_read_b2b_test extends test_base;
  `uvm_component_utils(axi_write_read_b2b_test)

  function new(string name = "axi_write_read_b2b_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    axi_write_read_b2b_sequence seq;
    phase.raise_objection(this);
    `uvm_info("TEST", "Starting AXI Write -> Read Back-to-Back", UVM_LOW)
    seq = axi_write_read_b2b_sequence::type_id::create("seq", this);
    seq.start(env.agent.sequencer);
    `uvm_info("TEST", "AXI Write -> Read Back-to-Back test PASSED", UVM_LOW)
    phase.drop_objection(this);
  endtask

endclass


