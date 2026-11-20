// class master_agent extends uvm_agent;
//   `uvm_component_utils(master_agent)
//   master_monitor  monitor;
//   master_driver  driver;
//   master_sequencer sequencer;
  
//   function new (string name = "master_agent", uvm_component parent);
//     super.new(name, parent);
//   endfunction
  
//   virtual function void build_phase(uvm_phase phase);
//     super.build_phase(phase);
//     monitor = master_monitor::type_id::create("monitor", this);
//     driver = master_driver::type_id::create("driver", this);
//     sequencer = master_sequencer::type_id::create("sequencer", this);
//   endfunction
  
//    virtual function void connect_phase(uvm_phase phase);
//     super.connect_phase(phase);
//     driver.seq_item_port.connect(sequencer.seq_item_export);
//     //monitor.ap.connect(sequencer.seq_item_export);
//    endfunction  
// endclass



class master_agent extends uvm_agent;
  `uvm_component_utils(master_agent)
  master_monitor  monitor;
  master_driver  driver;
  master_sequencer sequencer;
  
  function new (string name = "master_agent", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    monitor = master_monitor::type_id::create("monitor", this);
    driver = master_driver::type_id::create("driver", this);
    sequencer = master_sequencer::type_id::create("sequencer", this);
  endfunction
  
   virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    driver.seq_item_port.connect(sequencer.seq_item_export);
    //monitor.ap.connect(sequencer.seq_item_export);
   endfunction  
endclass