module memory(
    output reg[63:0] valM,

    input clk,
    input [63:0] valA,
    input [63:0] valE,
    input [63:0] valP,
    input [3:0] icode
);


reg [64:0] dmem [0:1023];

always @(*) begin
    $readmemh("dmem.txt",dmem);
        case (icode)
        4'b0010:begin   //cmovxx
        end
        4'b0011:begin   //irmovq
        end
        4'b0100:begin   //rmmovq
            dmem[valE] = valA;
        end
        4'b0101:begin   //mrmovq
            valM  = dmem[valE];
        end        
        4'b0110:begin   //OPq
        end
        4'b0111:begin   //jxx
        end
        4'b1000:begin   //call
            dmem[valE] = valP;
        end
        4'b1001:begin   //ret
            valM  = dmem[valA];
        end
        4'b1010:begin   //pushq
            dmem[valE] = valA;
        end
        4'b1011:begin   //popq
            valM = dmem[valA];      
        end

    endcase

    $writememh("dmem.txt",dmem);

    end

endmodule