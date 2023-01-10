module dump();
    initial begin
        $dumpfile ("vga.vcd");
        $dumpvars (0, vga);
        #1;
    end
endmodule

