module selectPC(
    output reg[63:0] f_pc,

    input [63:0] F_predPC,
    
    input M_Cnd,
    input [3:0] M_icode,
    input [63:0] M_valA,
    input [3:0] W_icode,
    input [63:0] W_valM
);

always @(*) begin

    f_pc = F_predPC;

    if(M_Cnd == 0 && M_icode == 4'b0111) begin
        f_pc <= M_valA;
    end
    else if(W_icode == 4'b1001) begin
        f_pc <= W_valM;
    end

end

endmodule