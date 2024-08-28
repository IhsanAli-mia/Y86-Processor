module fetch (
    output reg[3:0] icode,
    output reg[3:0] ifun,
    output reg[3:0] rA,
    output reg[3:0] rB,     
    output reg[63:0] valC,  // 64 bit (8 byte) memory

    output reg imem_error,
    output reg instr_valid,
    output reg[63:0] valP,
    output reg hlt,

    input clk,
    input [8*1024-1:0] imem,
    input [63:0] PC  // the memory pointed by this address
);


reg[0:79] instr; // 10 bit instruction
reg[0:71] instr9; // 9 bit instruction

wire[7:0] instr_mem[0:1023]; // memory

genvar i;
for (i=0;i<1024;i=i+1)
begin
    assign instr_mem[i] = imem[8*i+7:8*i];
end


always @(*) begin

    imem_error = 0;
    if(PC>1023)
    begin
        imem_error = 1;
    end

    //could not implement as a loop at all

    instr={
      instr_mem[PC],
      instr_mem[PC+1],
      instr_mem[PC+9],
      instr_mem[PC+8],
      instr_mem[PC+7],
      instr_mem[PC+6],
      instr_mem[PC+5],
      instr_mem[PC+4],
      instr_mem[PC+3],
      instr_mem[PC+2]
    };

    instr9={
        instr_mem[PC],
        instr_mem[PC+8],
        instr_mem[PC+7],
        instr_mem[PC+6],
        instr_mem[PC+5],
        instr_mem[PC+4],
        instr_mem[PC+3],
        instr_mem[PC+2],
        instr_mem[PC+1]
    };

    //split 
    icode = instr[0:3];
    ifun = instr[4:7];

    instr_valid = 1'b1;

    hlt=0;

    case (icode)
        4'b0000:begin   //hlt
            hlt=1;
            valP = PC + 64'd1;
        end
        4'b0001:begin   //nop
            valP = PC + 64'd1;
        end
        4'b0010:begin   //cmovxx
            rA = instr[8:11];
            rB = instr[12:15];
            valP = PC + 64'd2;
        end
        4'b0011:begin   //irmovq
            rA=instr[8:11];
            rB=instr[12:15];
            valC=instr[16:79];
            valP=PC+64'd10;
        end
        4'b0100:begin   //rmmovq
            rA=instr[8:11];
            rB=instr[12:15];
            valC=instr[16:79];
            valP=PC+64'd10;
        end
        4'b0101:begin   //mrmovq
            rA=instr[8:11];
            rB=instr[12:15];
            valC=instr[16:79];
            valP=PC+64'd10;
        end        
        4'b0110:begin   //OPq
            rA=instr[8:11];
            rB=instr[12:15];
            valP=PC+64'd2;
        end
        4'b0111:begin   //jxx
            valC=instr9[8:71];
            valP=PC+64'd9;
        end
        4'b1000:begin   //call
            valC=instr9[8:71];
            valP=PC+64'd9;
        end
        4'b1001:begin   //ret
            valP = PC+64'd1;
        end
        4'b1010:begin   //pushq
            rA=instr[8:11];
            rB=instr[12:15];
            valP=PC+64'd2;     
        end
        4'b1011:begin   //popq
            rA=instr[8:11];
            rB=instr[12:15];
            valP=PC+64'd2;            
        end
        default: instr_valid = 1'b0; 
    endcase


end




    
endmodule