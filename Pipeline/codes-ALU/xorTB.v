module xorTB;

reg signed [63:0] X, Y;
wire [63:0] out;

XOR x1 (X,Y,out);

initial 
    begin

        $dumpfile("xorTB.vcd");
        $dumpvars(0,xorTB);
        X = 15;
        Y = 32;  

    end

initial 
begin
    
    #5
    X=64'b1010101010101010101010101010101010101010101010101010101010101011;
    Y=64'b0101010101010101010101010101010101010101010101010101010101010101;


    #5
    X=15;
    Y=31;

    #5
    X=31;
    Y=63;

end
endmodule