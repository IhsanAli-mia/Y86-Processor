module memory (
    input clk,
    input [0:3] M_stat,
    input [3:0] M_icode,
    input M_cnd,
    input signed [63:0] M_valE,
    input signed [63:0] M_valA,
    input [3:0] M_dstE,
    input [3:0] M_dstM,

    output reg [0:3] W_stat,
    output reg [3:0] W_icode,
    output reg signed [63:0] W_valE, W_valM,
    output reg [3:0] W_dstE, W_dstM,
    output reg signed [63:0] m_valM,
    output reg [3:0] m_stat
);



reg [63:0] dmem [0:4095];
reg dmem_err = 0;

always @(*)
begin
    $readmemh("dmem.txt",dmem);

    if(M_valE > 4095 || M_valA > 4095)
    begin
        dmem_err = 1;
        $display("asshole");
    end
    case(M_icode)
    4'b0101: m_valM = dmem[M_valE];   //mrmovq
    4'b1001: m_valM = dmem[M_valA];   //return
    4'b1011: m_valM = dmem[M_valA];   //popq    
    endcase
    $writememh("dmem.txt",dmem);
end

always@(posedge clk)
begin
    $readmemh("dmem.txt",dmem);
    if(M_valE > 4095 || M_valA > 4095)
    begin
        dmem_err = 1;
        $display("asshole");
    end
    case(M_icode)
    4'b0100: dmem[M_valE] = M_valA;   //rmmovq
    4'b1000: dmem[M_valE] = M_valA;   //call
    4'b1010: dmem[M_valE] = M_valA;   //pushq
    endcase
    $writememh("dmem.txt",dmem);
end

always @(*)
begin
    if(dmem_err == 1)
        m_stat = 4'b0010;
    else
        m_stat = M_stat;
end

always @(posedge clk)
begin
    W_dstE <= M_dstE;
    W_valE <= M_valE;
    W_valM <= m_valM;
    W_dstM <= M_dstM;
    W_stat <= m_stat;
    W_icode <= M_icode;
end

endmodule