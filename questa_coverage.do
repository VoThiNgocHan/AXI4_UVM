# Run from this directory with: vsim -c -do questa_coverage.do
onerror {quit -f -code 1}

if {![file exists work]} {
    vlib work
}
file mkdir coverage
transcript file coverage/questa_coverage.log

vlog -sv -cover sbceft testbench.sv
vsim -coverage -onfinish stop work.tb
run -all

coverage save coverage/axi_uvm.ucdb
coverage report -codeAll -details -output coverage/axi_uvm_coverage.txt
coverage report -summary -output coverage/axi_uvm_summary.txt
exec vcover report -html -codeAll -details -output coverage/axi_uvm_html coverage/axi_uvm.ucdb

quit -f
