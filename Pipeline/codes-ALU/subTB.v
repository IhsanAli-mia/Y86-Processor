module subTB;

reg signed [63:0] X, Y;
wire [63:0] out;
wire cf;

SUB s (X,Y,out,cf);


initial 
begin
    
    X = 63;
    Y = 31;

end
initial 
    begin

        $dumpfile("subTB.vcd");
        $dumpvars(0,subTB);

        #5
        X = 63;
        Y = 31;

        #5
        X=0;
        Y=1;

        #5
        X=-1;
        Y=-3;

        #5;

    end
endmodule