module XOR(input [63:0] X,input [63:0] Y,output [63:0] Z);
genvar x;
generate
    for(x=0;x<64;x=x+1)
        begin:AND
            xor ex(Z[x],X[x],Y[x]);
        end
endgenerate
endmodule