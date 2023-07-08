if  iverilog -y -o netpath_tb.v netpath.v fetch.v read.v execute.v memory.v write.v; then
    ./a.out;
    gtkwave netpath_results.vcd
else
    echo "Stopped Execution"
fi