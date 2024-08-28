module MOR(input [63:0] X,input [63:0] Y,output [63:0] Z);
genvar a;
generate
    for(a=0;a<64;a=a+1)
        begin:MOR
            or a0(Z[a],X[a],Y[a]);
        end
endgenerate
endmodule

module MUXAND(input [63:0] X,input S0,input S1,output [63:0] Z);
wire code;
    and a1(code,S0,S1);
genvar a;
generate
    for(a=0;a<64;a=a+1)
        begin:AND
            and an(Z[a],X[a],code);
        end
endgenerate
endmodule

module MUX(
    input [63:0] I0,
    input [63:0] I1,
    input [63:0] I2,
    input [63:0] I3,

    input [1:0] control,

    output [63:0] Z
);

wire nc0,nc1;
    not n1(nc0,control[0]);
    not n2(nc1,control[1]);

wire [63:0] O0,O1,O2,O3,im1,im2;

    MUXAND m1(I3,control[0],control[1],O3);
    MUXAND m2(I2,nc0,control[1],O2);
    MUXAND m3(I1,control[0],nc1,O1);
    MUXAND m4(I0,nc0,nc1,O0);

    MOR o1(O0,O1,im1);
    MOR o2(O2,O3,im2);
    MOR op(im1,im2,Z);
    
endmodule