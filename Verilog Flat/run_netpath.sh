if iverilog -y -o fetch_tb.v fetch.v; then
    ./a.out;
fi

if iverilog -y -o read_tb.v read.v; then
    ./a.out;
fi

if iverilog -y -o execute_tb.v execute.v; then
    ./a.out;
fi

if iverilog -y -o memory_tb.v memory.v; then
    ./a.out;
fi

if  iverilog -y -o netpath_tb.v netpath.v fetch.v read.v execute.v memory.v write.v; then
    ./a.out
else
    echo "Stopped Execution"
fi