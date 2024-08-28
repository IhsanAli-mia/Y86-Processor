
module addTB;

reg signed [63:0] X, Y;
wire [63:0] out;
wire crry;

ADD a1 (X,Y,out,crry);

initial 
    begin
        X = 2;
        Y = 2;  

    end

initial 
begin
        $dumpfile("addTB.vcd");
        $dumpvars(0,addTB);
    #5
    X = 10;
    Y = 5;
end

initial
begin
    #5
    X=-1;
    Y=1;

    #5
    X=300000;
    Y=543210;

    #5;
    X=64'b0111111111111111111111111111111111111111111111111111111111111111;
    Y=64'b0111111111111111111111111111111111111111111111111111111111111111;

    #5;
end


endmodule