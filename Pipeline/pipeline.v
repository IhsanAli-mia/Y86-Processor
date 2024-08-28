`include "control.v"
`include "fetch.v"
`include "decode.v"
`include "execute.v"
`include "memory.v"
`include "selectPC.v"

module pipeline;

reg clk;

reg [0:3] stat = 4'b1000;
//-------------------FETCH--------------------
wire [63:0] f_predPC;
wire [63:0] f_pc;
reg [63:0] F_predPC;


//-------------------DECODE--------------------
wire [3:0] D_icode, D_ifun, D_rA, D_rB;
wire signed [63:0] D_valC, D_valP;
wire [0:3] D_stat;
wire [3:0] d_srcA, d_srcB;


//-------------------EXECUTE--------------------
wire [3:0] E_icode, E_ifun;
wire signed [63:0] E_valA, E_valB, E_valC;
wire [3:0] E_srcA, E_srcB, E_dstE, E_dstM;
wire [0:3] E_stat;
wire [3:0] e_dstE;
wire signed [63:0] e_valE;
wire e_cnd;

//-------------------MEMORY--------------------
wire [3:0] M_icode, M_dstE, M_dstM;
wire signed [63:0] M_valA, M_valE;
wire [0:3] M_stat;
wire M_cnd;
wire signed [63:0] m_valM;
wire [0:3] m_stat;

//-------------------WRITEBACK-----------------
wire [0:3] W_stat; 
wire [3:0] W_icode, W_dstE, W_dstM;
wire signed [63:0] W_valE, W_valM;

//-----------STALLS AND BUBBLES----------------
wire F_stall, D_stall, D_bubble, E_bubble, W_stall, set_cc;

//-----------DISPLAYING REGISTER FILE----------------
wire [63:0] reg0;
wire [63:0] reg1;
wire [63:0] reg2;
wire [63:0] reg3;
wire [63:0] reg4;
wire [63:0] reg5;
wire [63:0] reg6;
wire [63:0] reg7;
wire [63:0] reg8;
wire [63:0] reg9;
wire [63:0] reg10;
wire [63:0] reg11;
wire [63:0] reg12;
wire [63:0] reg13;
wire [63:0] reg14;


//-----------CLOCK UPDATE----------------
always #10 clk = ~clk;

control control(
    .F_stall(F_stall),.D_stall(D_stall),.D_bubble(D_bubble),.E_bubble(E_bubble),.W_stall(W_stall),.set_cc(set_cc),
    .D_icode(D_icode),.d_srcA(d_srcA),.d_srcB(d_srcB),.E_icode(E_icode),.E_dstM(E_dstM),.e_cnd(e_cnd),.M_icode(M_icode),.m_stat(m_stat),.W_stat(W_stat)
);

fetch fetch(
    .D_stat(D_stat),.D_icode(D_icode),.D_ifun(D_ifun),.D_rA(D_rA),
    .D_rB(D_rB),.D_valC(D_valC),.D_valP(D_valP),
    .clk(clk),
    .F_stall(F_stall),.D_stall(D_stall),.D_bubble(D_bubble),
    .f_predPC(f_predPC), .f_pc(f_pc)
);

selectPC selPC(
    .f_pc(f_pc), .F_predPC(F_predPC), .M_Cnd(M_cnd), .M_valA(M_valA),
    .M_icode(M_icode), .W_icode(W_icode), .W_valM(W_valM)
);

decode decode(
    .E_bubble(E_bubble),
    .clk(clk),
    .D_stat(D_stat),.D_icode(D_icode),.D_ifun(D_ifun),.D_rA(D_rA),
    .D_rB(D_rB),.D_valC(D_valC),.D_valP(D_valP),
    .e_dstE(e_dstE),.M_dstE(M_dstE),.M_dstM(M_dstM),.W_dstE(W_dstE),.W_dstM(W_dstM),
    .e_valE(e_valE),.M_valE(M_valE),.m_valM(m_valM),.W_valE(W_valE),.W_valM(W_valM),.W_icode(W_icode),
    .E_stat(E_stat),.E_icode(E_icode),.E_ifun(E_ifun),.E_valC(E_valC),.E_valA(E_valA),.E_valB(E_valB),
    .E_dstE(E_dstE),.E_dstM(E_dstM),.E_srcA(E_srcA),.E_srcB(E_srcB),
    .d_srcA(d_srcA),.d_srcB(d_srcB),    .reg0(reg0),  
    .reg1(reg1), .reg2(reg2), .reg3(reg3), .reg4(reg4), .reg5(reg5), .reg6(reg6), .reg7(reg7),
    .reg8(reg8),.reg9(reg9), .reg10(reg10), .reg11(reg11), .reg12(reg12), .reg13(reg13), .reg14(reg14)
);

execute execute(
    .M_stat(M_stat),.M_icode(M_icode),.M_cnd(M_cnd),.M_valE(M_valE),.M_valA(M_valA),.M_dstE(M_dstE),.M_dstM(M_dstM),
    .e_valE(e_valE),.e_dstE(e_dstE),
    .E_stat(E_stat),.E_icode(E_icode),.E_ifun(E_ifun),.E_valC(E_valC),.E_valA(E_valA),.E_valB(E_valB),.E_dstE(E_dstE),.E_dstM(E_dstM),
    .e_cnd(e_cnd),
    .clk(clk),
    .set_cc(set_cc)
);

memory memory(
    .W_stat(W_stat),.W_icode(W_icode),.W_valE(W_valE),.W_valM(W_valM),.W_dstE(W_dstE),.W_dstM(W_dstM),
    .m_valM(m_valM),.m_stat(m_stat),
    .M_stat(M_stat),.M_icode(M_icode),.M_cnd(M_cnd),.M_valE(M_valE),.M_valA(M_valA),.M_dstE(M_dstE),.M_dstM(M_dstM),
    .clk(clk)
);


always @(W_stat)
begin
    stat = W_stat;
end

always @(stat)
begin
    case (stat)
        4'b0001:
        begin
            $display("Invalid Instruction Encounterd, Stopping!");
            $finish;
        end
        4'b0010:
        begin
            $display("Memory Leak Encounterd, Stopping!");
            $finish;
        end
        4'b0100:
        begin
            $display("Halt Encounterd, Halting!");
            $finish;
        end
        4'b1000:
        begin
            // All OK (No action required)
        end
    endcase    
end

always @(posedge clk) begin
    F_predPC = f_predPC;
    if(F_stall)begin
        F_predPC = f_pc;
    end
end

initial begin
    $dumpfile("pipelineOP.vcd");
    $dumpvars(0,pipeline);
    F_predPC = 64'd0;
    clk = 0;
end


endmodule