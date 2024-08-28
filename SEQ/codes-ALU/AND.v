module AND(input [63:0] X,input [63:0] Y,output [63:0] Z);
genvar a;
generate
    for(a=0;a<64;a=a+1)
        begin:AND
            and A(Z[a],X[a],Y[a]);
        end
endgenerate
endmodule