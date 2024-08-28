module decode (

    input clk,
    input E_bubble,

    input [3:0]D_stat,
    input [3:0] D_icode,
    input [3:0] D_ifun,

    input [3:0] D_rA,
    input [3:0] D_rB,

    input [63:0] D_valC,
    input [63:0] D_valP,

    output reg [3:0] E_stat,

    output reg [3:0] E_icode,
    output reg [3:0] E_ifun,

    output reg [63:0] E_valA,
    output reg [63:0] E_valB,
    output reg [63:0] E_valC,


    output reg [3:0] E_dstE,
    output reg [3:0] E_dstM,

    output reg [3:0] E_srcB,
    output reg [3:0] E_srcA,

    output reg[3:0] d_srcA, d_srcB,


    // regfile file logic inputs
    input [3:0] e_dstE,
    input [63:0] e_valE,

    input [3:0] M_dstE,
    input [63:0] M_valE,
    input [3:0] M_dstM,
    input [63:0] m_valM,

    input [3:0] W_dstM,
    input [3:0] W_icode,
    input [63:0] W_valM,
    input [3:0] W_dstE,
    input [63:0] W_valE,

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
    output reg[63:0] reg14

);

reg [63:0] regfile[0:14]; // local regfile variable

reg [3:0] d_dstE, d_dstM;


reg [63:0] d_rvalA, d_rvalB;

reg [63:0] d_valA, d_valB;               


always @(*) begin
    $readmemh("regfile.txt",regfile);
end

initial begin
        regfile[0] = 0;
        regfile[1] = 0;
        regfile[2] = 0;
        regfile[3] = 0;
        regfile[4] = 28;
        regfile[5] = 0;
        regfile[6] = 0;
        regfile[7] = 0;
        regfile[8] = 0;
        regfile[9] = 0;
        regfile[10] = 0;
        regfile[11] = 0;
        regfile[12] = 0;
        regfile[13] = 0;
        regfile[14] = 0;

        $writememh("regfile.txt",regfile);
end

// forwarding logic 

always @(*) begin

    //for  d_valA
    case(D_icode)
        4'h7,4'h8: d_valA = D_valP; // Use incremented PC
        default: begin
            case(d_srcA)
                e_dstE: d_valA <= (e_valE!=4'hF) ? e_valE : d_rvalA; // Forward valE from execute
                M_dstM: d_valA <= (m_valM!=4'hF) ? m_valM : d_rvalA; // Forward valM from memory
                M_dstE: d_valA <= (M_valE!=4'hF) ? M_valE : d_rvalA; // Forward valE from memory
                W_dstM: d_valA <= (W_valM!=4'hF) ? W_valM : d_rvalA; // Forward valM from write back
                W_dstE: d_valA <= (W_valE!=4'hF) ? W_valE : d_rvalA; // Forward valE from write back
                default: d_valA <= d_rvalA; // Use value read from regfile 
            endcase
        end
    endcase

    // for d_valB
    case(d_srcB)
        e_dstE: d_valB <= (e_valE!=4'hF) ? e_valE : d_rvalB; // Forward valE from execute
        M_dstM: d_valB <= (m_valM!=4'hF) ? m_valM : d_rvalB; // Forward valM from memory
        M_dstE: d_valB <= (M_valE!=4'hF) ? M_valE : d_rvalB; // Forward valE from memory
        W_dstM: d_valB <= (W_valM!=4'hF) ? W_valM : d_rvalB; // Forward valM from write back
        W_dstE: d_valB <= (W_valE!=4'hF) ? W_valE : d_rvalB; // Forward valE from write back
        default: d_valB <= d_rvalB; // Use value read from regfile 
    endcase

end

// Assigning srcA and srcB, dstE and dstM

always @(*) begin 
    d_srcA = 4'hF;
    d_srcB = 4'hF;
    d_dstE = 4'hF;
    d_dstM = 4'hF;
    
    case (D_icode)
        4'h0:begin
            // halt 
        end
        4'h1:begin
            // nop
        end 
        4'h2:begin
            d_srcA = D_rA; //cmovxx rA rB
            d_dstE = D_rB;
        end
        4'h3:begin
            d_dstE = D_rB; //irmovq $ rB
        end
        4'h4:begin
            d_srcA = D_rA; //rmmovq rA D(rB)
            d_srcB = D_rB;
        end
        4'h5:begin
            d_srcB = D_rB; //mrmovq D(rB) rA
            d_dstM = D_rA;
        end
        4'h6:begin
            d_srcA = D_rA; //opxx rA rB
            d_srcB = D_rB;
            d_dstE = D_rB;
        end
        4'h7:begin
            // no decode or writeback for jXX
        end
        4'h8:begin
            d_srcB = 4; // call dest
            d_dstE = 4;
        end
        4'h9:begin
            d_srcA = 4; //ret
            d_srcB = 4;
            d_dstE = 4;
        end
        4'hA:begin
            d_srcA = D_rA; // pushq rA
            d_srcB = 4;
            d_dstE = 4;
        end
        4'hB:begin
            d_srcA = 4; // popq rA rB
            d_srcB = 4;
            d_dstE = 4;
            d_dstM = D_rA;
        end
        default:begin
            d_srcA = 4'hF;
            d_srcB = 4'hF;
            d_dstE = 4'hF;
            d_dstM = 4'hF;
        end
    endcase
end

//evaluating d_rvalA and d_rvalB

always @(*) 
begin
    case (D_icode)
    4'h0: 
    begin
        // no decode stage here
    end
    4'h1: 
    begin
        // no decode stage here
    end
    4'h2: 
    begin
        d_rvalA = regfile[D_rA];
        d_rvalB = 64'b0;
    end
    4'h3: 
    begin
        d_rvalB = 64'b0;
    end
    4'h4: 
    begin
        d_rvalA = regfile[D_rA];
        d_rvalB = regfile[D_rB];
    end
    4'h5: 
    begin
        d_rvalB = regfile[D_rB];
    end
    4'h6: 
    begin
        d_rvalA = regfile[D_rA];
        d_rvalB = regfile[D_rB];
    end
    4'h7:
    begin
        // no decode stage here
    end
    4'h8:
    begin
        d_rvalB = regfile[4];
    end
    4'h9:
    begin
        d_rvalA = regfile[4];
        d_rvalB = regfile[4];
    end
    4'hA:
    begin
        d_rvalA = regfile[D_rA];
        d_rvalB = regfile[4];
    end
    4'hB:
    begin
        d_rvalA = regfile[4];
        d_rvalB = regfile[4];
    end
endcase
end

// at posedge clk assign values to E regfile

always @(posedge clk ) begin
    if(E_bubble == 1'b1)begin
        E_icode <= 4'h1;
        E_ifun <= 4'h0;
        E_valC <= 4'h0;
        E_valA <= 4'h0;
        E_valB <= 4'h0;
        E_dstE <= 4'hF;
        E_dstM <= 4'hF;
        E_srcA <= 4'hF;
        E_srcB <= 4'hF;
        E_stat <= 4'h8;
    end
    else begin
        E_icode <= D_icode;
        E_ifun <= D_ifun;
        E_srcA <= d_srcA;
        E_srcB <= d_srcB;
        E_dstE <= d_dstE;
        E_dstM <= d_dstM;
        E_valA <= d_valA;
        E_valB <= d_valB;
        E_valC <= D_valC;
        E_stat <= D_stat;
    end
end

// writeback to regfile file based on W_icode

always @(posedge clk)
begin
    case (W_icode)
        4'h0: 
        begin
            // no writeback stage here
        end
        4'h1: 
        begin
            // no writeback stage here
        end
        4'h2: 
        begin
            regfile[W_dstE] = W_valE;
        end
        4'h3: 
        begin
            regfile[W_dstE] = W_valE;
        end
        4'h4: 
        begin
            // no writeback stage here
        end
        4'h5: 
        begin
            regfile[W_dstM] = W_valM;
        end
        4'h6: 
        begin
            regfile[W_dstE] = W_valE;
        end
        4'h7:
        begin
            // no writeback stage here
        end
        4'h8:
        begin
            regfile[W_dstE] = W_valE;
        end
        4'h9:
        begin
            regfile[W_dstE] = W_valE;
        end
        4'hA:
        begin
            regfile[W_dstE] = W_valE;
        end
        4'hB:
        begin
            regfile[W_dstE] = W_valE;
            regfile[W_dstM] = W_valM;
        end
    endcase     

    reg0 = regfile[0]; 
    reg1 = regfile[1];
    reg2 = regfile[2];
    reg3 = regfile[3];
    reg4 = regfile[4];
    reg5 = regfile[5];
    reg6 = regfile[6];
    reg7 = regfile[7];
    reg8 = regfile[8]; 
    reg9 = regfile[9];
    reg10 = regfile[10];
    reg11 = regfile[11];
    reg12 = regfile[12];
    reg13 = regfile[13];
    reg14 = regfile[14];

    $writememh("regfile.txt",regfile);
end

endmodule