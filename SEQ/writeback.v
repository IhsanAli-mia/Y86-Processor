module writeback(
    input clk,
    input cnd,
    input [3:0] rA,
    input [3:0] rB,
    input [63:0] valE,
    input [63:0] valM,
    input [3:0] icode,
    input [3:0] ifun,

    output reg[63:0] reg0,
    output reg[63:0] reg1,
    output reg[63:0] reg2,
    output reg[63:0] reg3,
    output reg[63:0] reg4,
    output reg[63:0] reg5,
    output reg[63:0] reg6,
    output reg[63:0] reg7,
    output reg[63:0] reg8,
    output reg[63:0] reg9,
    output reg[63:0] reg10,
    output reg[63:0] reg11,
    output reg[63:0] reg12,
    output reg[63:0] reg13,
    output reg[63:0] reg14,
    output reg[63:0] reg15

);

reg[63:0] regi [0:15];


always @(valE,valM,posedge clk) begin
    $readmemh("reg.txt",regi);
        case (icode)
        4'b0010:begin   //cmovxx
            if (cnd == 1 || ifun==4'b0000) begin
            regi[rB] = valE;
            end
        end
        4'b0011:begin   //irmovq
            regi[rB] = valE;
        end
        4'b0100:begin   //rmmovq
        end
        4'b0101:begin   //mrmovq
            regi[rA] = valM;
        end        
        4'b0110:begin   //OPq
            regi[rB] = valE;
        end
        4'b0111:begin   //jxx
        end
        4'b1000:begin   //call
            regi[4] = valE;
        end
        4'b1001:begin   //ret
            regi[4] = valE;
        end
        4'b1010:begin   //pushq
            regi[4] = valE;
        end
        4'b1011:begin   //popq
            regi[4] = valE;
            regi[rA] = valM;
        end
    endcase

    reg0 = regi[0]; 
    reg1 = regi[1];
    reg2 = regi[2];
    reg3 = regi[3];
    reg4 = regi[4];
    reg5 = regi[5];
    reg6 = regi[6];
    reg7 = regi[7];
    reg8 = regi[8]; 
    reg9 = regi[9];
    reg10 = regi[10];
    reg11 = regi[11];
    reg12 = regi[12];
    reg13 = regi[13];
    reg14 = regi[14];
    reg15 = regi[15];

    $writememh("reg.txt",regi);

    end
endmodule