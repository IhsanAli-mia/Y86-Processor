`include "codes-ALU/alu.v"

module logicCode (
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

always @(*) begin
    case (ifun)
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

    input [3:0] icode,
    input [3:0] ifun,
    input [63:0] valA,
    input [63:0] valB,
    input [63:0] valC,

    output reg[63:0] valE,
    output reg cnd,
    // output reg hlt,

    output reg zf,
    output reg of,
    output reg sf,

    output reg  signed[63:0] alu_valA,
    output reg  signed[63:0] alu_valB,
    output wire signed[63:0] alu_valC
);

reg [1:0] alu_func;

// wire signed [63:0] alu_valC;
// reg signed [63:0] pre_ValE;
wire ovf;

//set condition flag logic code
always @(posedge clk) begin
    if(clk==1)
    begin
        zf = (alu_valC==1'b0); // zero flag
        sf = (alu_valC<1'b0); //unsigned overflow flag
        of = ovf;             // signed overflow flag
    end
end

initial begin   // set all condition flags to false
    zf = 0;
    sf = 0;
    of = 0;
end

initial
  begin
    alu_func=2'b00;
	alu_valA = 64'b0;
	alu_valB = 64'b0;
  end

wire logCode;

logicCode log(
    .sf(sf),
    .of(of),
    .zf(zf),

    .cc(logCode),
    .ifun(ifun)
);

alu A(
    .S0(alu_func),
    .X(alu_valA),
    .Y(alu_valB),
    .Z(alu_valC),
    .ovf(ovf)
);

// execute functioning

always @(*) begin
    cnd = 0;

    case (icode)
        // 4'b0000:hlt=1;

        4'b0010:begin   //cmoxx
            if(logCode)begin
                cnd = 1;
            end
            valE = 64'd0 + valA;
        end 

        4'b0011:begin   //irmov
            valE = 64'd0 + valC;
        end

        4'b0100:begin   //rmmov
            valE = valB + valC;
        end

        4'b0101:begin //mrmov
            valE = valB + valC;
        end

        4'b0110:begin //OPq
            case (ifun)
                4'b0000:begin //addq
                    alu_func = 2'b00;
                end 
                4'b0001:begin   //subq
                    alu_func = 2'b01;

                end
                4'b0010:begin   //xorq
                    alu_func = 2'b10;
                end
                4'b0011:begin   //andq
                    alu_func = 2'b11;
                end
            endcase
            alu_valA = valA;
            alu_valB = valB;
            valE = alu_valC;
        end

        4'b0111:begin   //jxx
            if(logCode)begin
                cnd = 1;
            end
        end

        4'b1000:begin   //call
            valE = -64'd8 + valB;
        end

        4'b1001:begin //ret
            valE = 64'd8 + valB;
        end

        4'b1010:begin //pushq
            valE = -64'd8 + valB;
        end

        4'b1011:begin //popq
            valE = 64'd8 + valB;
        end
    endcase
end    
endmodule