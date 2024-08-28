module fas(input a, input b, input c_in,
     output sum, output c_out);
    wire w1,w2,w3;
    xor x1(w1,a,b);
    xor x2(sum,w1,c_in);
    and a1(w3,c_in,w1);
    and a2(w2,a,b);
    or o1(c_out,w2,w3);
endmodule

module SUB(input [63:0] X, input [63:0] Y, output [63:0] Z, output cout);
wire [63:0] c;
wire [63:0] notb;

genvar bloc;
generate
    for(bloc = 0;bloc<64;bloc=bloc+1)
        begin: ADD
        not n1(notb[bloc],Y[bloc]);
        if(bloc==0)
            fas init (X[bloc],notb[bloc],1'b1,Z[bloc],c[bloc]);
        else
            fas subs (X[bloc],notb[bloc],c[bloc-1],Z[bloc],c[bloc]);
        end

    assign cout=c[63];
endgenerate

endmodule