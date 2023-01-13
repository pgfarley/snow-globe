module dump();
    initial begin
        $dumpfile ("simple_480p.vcd");
        $dumpvars (0, simple_480p);
        #1;
    end
endmodule

