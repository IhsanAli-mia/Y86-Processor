`include "codes-ALU/ADD.v"
`include "codes-ALU/SUB.v"
`include "codes-ALU/XOR.v"
`include "codes-ALU/AND.v"
`include "codes-ALU/MUX.v"

module alu(
    input [1:0] S0,
    input [63:0] X,
    input [63:0] Y,
    output signed [63:0] Z,
    output reg signed ovf
);

wire[63:0] I1,I2,I3,I4;
wire C1,C2;

ADD a(X,Y,I1,C1);
SUB s(X,Y,I2,C2);
AND d(X,Y,I3);
XOR x(X,Y,I4);

MUX m(I1,I2,I3,I4,S0,Z);

always@(Z)
begin
assign ovf=0;
if(S0==2'b00||S0==2'b01)begin
    if (((X<0) == (Y<0)) && ((Z<0) != (X<0)))begin
    assign ovf=1;
        end
    end
end

endmodule
