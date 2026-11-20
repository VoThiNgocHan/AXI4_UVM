
// class axi_sequence extends uvm_sequence #(axi_seq_item);
//   `uvm_object_utils(axi_sequence)

//   virtual axi_intf intf;

//   axi_seq_item write_trans;
//   axi_seq_item read_trans;

//   bit [15:0] pre_addr;

//   function new(string name = "axi_sequence");
//     super.new(name);
//   endfunction

//   virtual task body();

//     // WRITE TRANSACTION

//     write_trans = axi_seq_item#()::type_id::create("write_trans");

//     start_item(write_trans);

//     assert(write_trans.randomize() with {
//       cmd    == axi_seq_item#()::write;
//       awid   == 8'h00;
//       awaddr == 16'h1238;
//       awlen  == 8'h00;
//       awsize == 3'b010;
//       awburst == 2'b01;

//       wdata == 32'hA5A55A5A;
//       wstrb == 4'hF;
//       wlast == 1'b1;
//     }) else begin
//       `uvm_fatal("SEQ", "Write transaction randomization failed")
//     end

//     pre_addr = write_trans.awaddr;

//     finish_item(write_trans);

//     // -------------------------
//     // READ TRANSACTION
//     // -------------------------
//     read_trans = axi_seq_item#()::type_id::create("read_trans");

//     start_item(read_trans);

//     assert(read_trans.randomize() with {
//       cmd    == axi_seq_item#()::read;
//       arid   == 8'h00;
//       araddr == pre_addr;
//       arlen  == 8'h00;
//       arsize == 3'b010;
//       arburst == 2'b01;
//     }) else begin
//       `uvm_fatal("SEQ", "Read transaction randomization failed")
//     end

//     finish_item(read_trans);

//     `uvm_info("SEQ", "AXI Write -> Read Back-to-Back sequence completed", UVM_LOW)

//   endtask

//   task test_wa_reset ();
//     if (!uvm_config_db#(virtual axi_intf)::get(m_sequencer, "", "vif", intf)) begin
//       `uvm_fatal("SEQ", "Failed to get interface from config DB")
//     end

//     @(negedge intf.ACLK)
//     intf.ARESETn <= 0;

//     repeat (3) @(posedge intf.ACLK);
//     assert (intf.ARESETn == 0) else $error("ARESETn should be low during reset");

//     @(negedge intf.ACLK)
//     intf.ARESETn <= 1;

//     @(posedge intf.ACLK)
//     assert (intf.AWVALID == 0) else $error("AWVALID should be low after reset"); 
//   endtask

// endclass

// class axi_wd_stable_sequence extends uvm_sequence #(axi_seq_item);

//     `uvm_object_utils(axi_wd_stable_sequence)

//     axi_seq_item write_trans;

//     function new(string name = "axi_wd_stable_sequence");
//         super.new(name);
//     endfunction

//     virtual task body();

//         write_trans = axi_seq_item#()::type_id::create("write_trans");

//         start_item(write_trans);

//         assert(write_trans.randomize() with {

//             cmd     == axi_seq_item#()::write;

//             awid    == 8'h00;
//             awaddr  == 16'h1238;
//             awlen   == 8'h00;
//             awsize  == 3'b010;
//             awburst == 2'b01;

//             wdata   == 32'hA5A55A5A;
//             wstrb   == 4'hF;
//             wlast   == 1'b1;

//             wd_stall_cycles == 3;

//         }) else begin
//             `uvm_fatal("WD_STABLE",
//                        "Write transaction randomization failed")
//         end

//         finish_item(write_trans);

//         `uvm_info("WD_STABLE",
//                   "AXI WD STABLE test completed",
//                   UVM_LOW)

//     endtask

// endclass


class axi_write_sequence extends uvm_sequence #(axi_seq_item);
    `uvm_object_utils(axi_write_sequence)
    axi_seq_item write_trans;
    
    function new(string name = "axi_write_sequence");
        super.new(name);
    endfunction

    bit[15:0] addr = 16'h1238;
    bit[31:0] data = 32'hA5A55A5A;

    task body();
        write_trans = axi_seq_item#()::type_id::create("write_trans");
        start_item(write_trans);
        if(!write_trans.randomize() with {
            cmd     == write;
            awid    == 8'h00;
            awaddr  == addr;
            awlen   == 8'h00;
            awsize  == 3'b010;
            awburst == 2'b01;

            wdata   == data;
            wstrb   == 4'hF;
            wlast   == 1'b1;
        }) begin
            `uvm_fatal("axi_write_sequence", "Failed to randomize write transaction")
        end
        finish_item(write_trans);
        `uvm_info("WRITE_SEQ", "AXI Write transaction completed", UVM_LOW)
    endtask

endclass


class axi_read_sequence extends uvm_sequence #(axi_seq_item);
    `uvm_object_utils(axi_read_sequence)
    axi_seq_item read_trans;

    function new(string name = "axi_read_sequence");
        super.new(name);
    endfunction

    bit[15:0] addr = 16'h1238;

    task body  ();
        read_trans = axi_seq_item#()::type_id::create("read_trans");
        start_item(read_trans);
        if(!read_trans.randomize() with {
            cmd     == read;
            arid    == 8'h00;
            araddr  == addr;
            arlen   == 8'h00;
            arsize  == 3'b010;
            arburst == 2'b01; 
        }) begin
            `uvm_fatal("axi_read_sequence", "Failed to randomize read transaction")
        end
        finish_item(read_trans);
        `uvm_info("READ_SEQ", "AXI Read transaction completed", UVM_LOW)
    endtask
endclass

class axi_write_read_b2b_sequence extends uvm_sequence #(axi_seq_item);
  `uvm_object_utils(axi_write_read_b2b_sequence)

  axi_write_sequence write_seq;
  axi_read_sequence read_seq;

  bit [15:0] addr = 16'h1238;
  bit [31:0] data = 32'hA5A55A5A;

  function new(string name = "axi_sequence_b2b");
    super.new(name);
  endfunction

  virtual task body();
    //write 
    write_seq = axi_write_sequence::type_id::create("write_seq");
    write_seq.addr = addr;
    write_seq.data = data;
    write_seq.start(m_sequencer);

    //read
    read_seq = axi_read_sequence::type_id::create("read_seq");
    read_seq.addr = addr;
    read_seq.start(m_sequencer);
    `uvm_info("SEQ_B2B", "AXI Write -> Read Back-to-Back sequence completed", UVM_LOW)
  endtask

endclass

