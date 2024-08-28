module fetch (
    output reg[3:0] D_icode,
    output reg[3:0] D_ifun,
    output reg[3:0] D_rA,
    output reg[3:0] D_rB,     
    output reg[63:0] D_valC,  // 64 bit (8 byte) memory

    output reg imem_error,
    output reg instr_valid,
    output reg[63:0] D_valP,
    output reg hlt,
    output reg [3:0] D_stat,

    output reg [63:0] f_predPC,

    input clk,
    input [63:0] f_pc,  // the memory pointed by this address

    input F_stall, D_stall, D_bubble    
);




reg[0:79] instr; // 10 bit instruction
reg[0:71] instr9; // 9 bit instruction
reg [63:0] regi[0:1];


reg [3:0] icode, ifun, rA, rB;                      
reg [63:0] valC, valP;
reg [0:3] stat;   // status code for fetch stage: AllOK, Halt, Adr_error, Instruction_error

reg [7:0] instr_mem[0:1023];
reg [0:79] instruction;
reg instr_invalid = 1'b0;

initial begin
  $readmemb("../SampleTestcase/11.txt",instr_mem);
//   $readmemb("../SampleTestcase/1.txt",instr_mem);
end  


always @(*) begin

    imem_error = 0;
    if(f_pc>1023)
    begin
        imem_error = 1;
    end

    //could not implement as a loop at all

    instr={
      instr_mem[f_pc],
      instr_mem[f_pc+1],
      instr_mem[f_pc+9],
      instr_mem[f_pc+8],
      instr_mem[f_pc+7],
      instr_mem[f_pc+6],
      instr_mem[f_pc+5],
      instr_mem[f_pc+4],
      instr_mem[f_pc+3],
      instr_mem[f_pc+2]
    };

    instr9={
        instr_mem[f_pc],
        instr_mem[f_pc+8],
        instr_mem[f_pc+7],
        instr_mem[f_pc+6],
        instr_mem[f_pc+5],
        instr_mem[f_pc+4],
        instr_mem[f_pc+3],
        instr_mem[f_pc+2],
        instr_mem[f_pc+1]
    };


     //split 
    icode = instr[0:3];
    ifun = instr[4:7];

    instr_valid = 1'b1;

    hlt=0;

    case (icode)
        4'b0000:begin   //hlt
            hlt=1;
            valP = f_pc + 64'd1;
        end
        4'b0001:begin   //nop
            valP = f_pc + 64'd1;
        end
        4'b0010:begin   //cmovxx
            rA = instr[8:11];
            rB = instr[12:15];
            valP = f_pc + 64'd2;
        end
        4'b0011:begin   //irmovq
            rA=instr[8:11];
            rB=instr[12:15];
            valC=instr[16:79];
            valP=f_pc+64'd10;
        end
        4'b0100:begin   //rmmovq
            rA=instr[8:11];
            rB=instr[12:15];
            valC=instr[16:79];
            valP=f_pc+64'd10;
        end
        4'b0101:begin   //mrmovq
            rA=instr[8:11];
            rB=instr[12:15];
            valC=instr[16:79];
            valP=f_pc+64'd10;
        end        
        4'b0110:begin   //OPq
            rA=instr[8:11];
            rB=instr[12:15];
            valP=f_pc+64'd2;
        end
        4'b0111:begin   //jxx
            valC=instr9[8:71];
            valP=f_pc+64'd9;
        end
        4'b1000:begin   //call
            valC=instr9[8:71];
            valP=f_pc+64'd9;
        end
        4'b1001:begin   //ret
            valP = f_pc+64'd1;
        end
        4'b1010:begin   //pushq
            rA=instr[8:11];
            rB=instr[12:15];
            valP=f_pc+64'd2;     
        end
        4'b1011:begin   //popq
            rA=instr[8:11];
            rB=instr[12:15];
            valP=f_pc+64'd2;            
        end
        default: instr_valid = 1'b0; 
    endcase

end

always @(*)
begin
    if (instr_invalid)
    stat = 4'h1;
    else if (imem_error)
    stat = 4'h2;
    else if (icode==4'h0)
    stat = 4'h4;
    else 
    stat = 4'h8;
end

always @(posedge clk ) 
begin

    if (D_stall==1'b0 && D_bubble==1'b1)
    begin
        D_icode <= 4'h1;
        D_ifun <= 4'h0;
        D_rA <= 4'hF;
        D_rB <= 4'hF;
        D_valC <= 64'b0;
        D_valP <= 64'b0;
        D_stat <= 4'h8;
    end
    else if(D_stall == 1)begin
        D_icode <= D_icode;
        D_ifun <= D_ifun;
        D_rA <= D_rA;
        D_rB <= D_rB;
        D_valC <= D_valC;
        D_valP <= D_valP;
        D_stat <= D_stat;
    end
    else
    begin
        D_icode <= icode;
        D_ifun <= ifun;
        D_rA <= rA;
        D_rB <= rB;
        D_valC <= valC;
        D_valP <= valP;
        D_stat <= stat;
    end

end



always@(*)begin
    if(icode == 4'b1000 || icode == 4'b0111) begin
        f_predPC = valC;
    end else begin
        f_predPC = valP;
    end
end

endmodule
