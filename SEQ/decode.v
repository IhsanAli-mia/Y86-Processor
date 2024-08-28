module decode (
    output reg[63:0] valA,
    output reg[63:0] valB,

    input clk,
    input [3:0] rA,
    input [3:0] rB,
    input [3:0] icode
);

reg[3:0] ra;
reg[3:0] rb;

reg[3:0] raa;
reg[3:0] rbb;

reg[63:0] regi[0:15];


initial begin
    valA = 4'hF;
    valB = 4'hF;
end

    always @(*)begin

        $readmemh("reg.txt",regi);

        case (icode)
        4'b0010:begin   //cmovxx
            valA = regi[rA];
        end
        4'b0011:begin   //irmovq
            valB = regi[rB];
        end
        4'b0100:begin   //rmmovq
            valA = regi[rA];
            valB = regi[rB];
        end
        4'b0101:begin   //mrmovq
            valA = regi[rA];
            valB = regi[rB];
        end        
        4'b0110:begin   //OPq
            valA = regi[rA];   
            valB = regi[rB];
        end
        4'b0111:begin   //jxx
        end
        4'b1000:begin   //call
            valB = regi[4];
        end
        4'b1001:begin   //ret
            valA = regi[4];
            valB = regi[4];
        end
        4'b1010:begin   //pushq
            valA = regi[rA];
            valB = regi[4];
        end
        4'b1011:begin   //popq
            valA = regi[4];
            valB = regi[4];       
        end

    endcase

    end


endmodule