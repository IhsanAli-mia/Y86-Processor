module nextPC (
    output reg[63:0] nextPC,
    input clk,
    input [63:0]valP,
    input [63:0]valC,
    input [63:0]valM,
    input cnd,
    // output reg hlt,
    input [3:0] icode
);


always @(*) begin
        case (icode)
        4'b0000:begin   //hlt
            // hlt=1;
            nextPC = valP;
        end
        4'b0001:begin   //nop
            nextPC = valP;
        end
        4'b0010:begin   //cmovxx
            nextPC = valP;
        end
        4'b0011:begin   //irmovq
            nextPC = valP;
        end
        4'b0100:begin   //rmmovq
            nextPC = valP;
        end
        4'b0101:begin   //mrmovq
            nextPC = valP;
        end        
        4'b0110:begin   //OPq
            nextPC = valP;
        end
        4'b0111:begin   //jxx
            if(cnd==1)begin
                nextPC = valC;
            end
            else begin
                nextPC = valP;
            end
        end
        4'b1000:begin   //call
            nextPC = valC;
        end
        4'b1001:begin   //ret
            nextPC = valM;
        end
        4'b1010:begin   //pushq
            nextPC = valP;
                 
        end
        4'b1011:begin   //popq
            nextPC = valP;               
        end
    endcase
end
    
endmodule