`include "codes-ALU/alu.v"

module cond (
    input sf,
    input zf,
    input of,

    output reg cc,

    input [3:0] ifun
);

wire Xout;
reg XinA;
reg XinB;

wire Aout;
reg AinA;
reg AinB;

wire Oout;
reg OinA;
reg OinB;

wire Nout;
reg Nin;

xor x(Xout,XinA,XinB);
and a(Aout,AinA,AinB);
or o(Oout,OinA,OinB);
not n(Nout,Nin);

initial begin
    cc = 0;
end

always @(*) begin
    case (ifun)
        4'b0000:begin
            cc = 1;
        end
        4'b0001:begin
            XinA = sf;
            XinB = of;
            OinA = Xout;
            OinB = zf;
            cc = Oout;
        end 
        4'b0010:begin
            XinA = sf;
            XinB = of;
            cc = Xout;
        end
        4'b0011:begin
            cc = zf;
        end
        4'b0100:begin
            Nin = zf;
            cc = Nout;
        end
        4'b0101:begin
            XinA = sf;
            XinB = of;
            Nin = Xout;
            cc = Nout;
        end
        4'b0110:begin
            XinA = sf;
            XinB = of;
            OinA = Xout;
            OinB = zf;
            Nin = Oout;
            cc = Nout;
        end
    endcase
end
endmodule


module execute (
    input clk,
    input [3:0] E_stat,
    input [3:0] E_icode, E_ifun, E_dstE, E_dstM,
    input signed [63:0] E_valC, E_valA, E_valB,
    // input [3:0] W_stat;
    // input [3:0] m_stat;
    input set_cc,

    //output parameters

    output reg [3:0] M_stat,
    output reg [3:0] M_icode,
    output reg signed [63:0] M_valE, M_valA, e_valE,
    output reg [3:0] M_dstE, M_dstM, e_dstE,
    output reg M_cnd,
    output reg e_cnd
);

reg [2:0] CC;

wire ovf;
wire cnd;

initial
begin
    CC[0] = 0; //ZF
    CC[1] = 0; //SF
    CC[2] = 0; //OF
end

always @(*) begin
    if(set_cc)begin
        CC[0] = (e_valE==1'b0);
        CC[1] = (e_valE < 1'b0);
        CC[2] = ovf;
    end
end

cond ecnd(.zf(CC[0]), .sf(CC[1]), .of(CC[2]), .ifun(E_ifun),
.cc(cnd));

reg [63:0] alu_A, alu_B;
reg [1:0] alu_func;
wire [63:0] alu_E;

alu E1(.X(alu_A), .Y(alu_B), .Z(alu_E), .S0(alu_func), .ovf(ovf));

always @(*) begin
    e_cnd = cnd;
    // $display("cnd = %b",cnd);
    case (E_icode)
        4'b0010:begin //cmovxx
            e_valE = E_valA;
        end 

        4'b0011:begin //irmovq
            e_valE = E_valC;
        end

        4'b0100:begin //rmmovq
            alu_func = 2'b00;
            alu_A = E_valC;
            alu_B = E_valB;
            e_valE = alu_E;
        end

        4'b0101:begin //mrmovq
            alu_func = 2'b00;
            alu_A = E_valC;
            alu_B = E_valB;
            e_valE = alu_E;
        end

        4'b0110:begin //opq
            alu_func = E_ifun[1:0];
            alu_A = E_valA;
            alu_B = E_valB;
            e_valE = alu_E;

            if(set_cc)begin
                CC[0] = (e_valE==1'b0);
                CC[1] = (e_valE < 1'b0);
                CC[2] = ovf;
            end     
        end

        4'b0111:begin //jXX
        end

        4'b1000:begin //call
            alu_func = 2'b00;
            alu_A = -64'd1;
            alu_B = E_valB;
            e_valE = alu_E;
        end

        4'b1001:begin //ret
            alu_func = 2'b00;
            alu_A = 64'd1;
            alu_B = E_valB;
            e_valE = alu_E;
        end

        4'b1010:begin //pushq
            alu_func = 2'b00;
            alu_A = -64'd1;
            alu_B = E_valB;
            e_valE = alu_E;
        end

        4'b1011:begin //popq
            alu_func = 2'b00;
            alu_A = 64'd1;
            alu_B = E_valB;
            e_valE = alu_E;
        end

    endcase
end

always @(*)
begin
    if(E_icode == 4'h2 || E_icode == 4'h7)
    begin
        e_dstE = (e_cnd == 1) ? E_dstE : 4'b1111;    //empty register
    end
    else
    begin
        e_dstE = E_dstE;
    end
end

always @(posedge clk)
begin
    M_stat <= E_stat;
    M_icode<= E_icode;
    M_cnd <= e_cnd;
    M_valE <= e_valE;
    M_valA <= E_valA;
    M_dstE <= e_dstE;
    M_dstM <= E_dstM;
end

    
endmodule