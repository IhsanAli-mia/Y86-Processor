`include "execute.v"
`include "fetch.v"
`include "decode.v"
`include "memory.v"
`include "writeback.v"
`include "PCupdate.v"


module SEQ;

  reg clk;
  reg [63:0] PC;
  wire [63:0] nextPC;


  wire [3:0] icode;
  wire [3:0] ifun;
  wire [3:0] rA;
  wire [3:0] rB; 
  wire [63:0] valC;
  wire [63:0] valP;
  wire [63:0] valA;
  wire [63:0] valB;
  wire [63:0] valE;
  wire [63:0] valM;

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
  wire [63:0] reg15;


  wire cnd;

  wire imem_error;
  wire instr_valid;
  wire hlt;

  reg [7:0] instr_mem[0:1023]; //Instruction memory
  wire [8*1024-1:0] imem;
  

  genvar i;
  for (i=0; i<1024; i=i+1)
  begin
    assign imem[8*i+7:8*i] = instr_mem[i];
  end

  reg [63:0] registers[0:15];

  initial begin
      registers[0] = 64'd0;
      registers[1] = 64'd0; 
      registers[2] = 64'd0; 
      registers[3] = 64'd0; 
      registers[4] = 64'd27; 
      registers[5] = 64'd0; 
      registers[6] = 64'd0; 
      registers[7] = 64'd0;
      registers[8] = 64'd0;
      registers[9] = 64'd0; 
      registers[10] = 64'd0; 
      registers[11] = 64'd0; 
      registers[12] = 64'd0; 
      registers[13] = 64'd0; 
      registers[14] = 64'd0; 
      registers[15] = 64'd0; 
      
    $writememh("reg.txt",registers);
  end

  reg [511:0] regi;
  wire [511:0] regis;

  fetch fetch(
    .icode(icode),
    .ifun(ifun),
    .rA(rA),
    .rB(rB),
    .valC(valC),
    .imem_error(imem_error),
    .instr_valid(instr_valid),
    .valP(valP),
    .clk(clk),
    .imem(imem),
    .PC(PC),
    .hlt(hlt)
  );
  
  decode decode(
    .valA(valA),
    .valB(valB),
    .clk(clk),
    .icode(icode),
    .rA(rA),
    .rB(rB)
  );

  wire zf;
  wire sf;
  wire of;
  wire signed [63:0] alu_valC;
  wire signed [63:0] alu_valA;
  wire signed [63:0] alu_valB;

  execute execute(
    .clk(clk),
    .icode(icode),
    .ifun(ifun),
    .valA(valA),
    .valB(valB),
    .valC(valC),
    .valE(valE),
    .cnd(cnd),
    // .hlt(hlt),
    .zf(zf),
    .sf(sf),
    .of(of),
	.alu_valC(alu_valC),
	.alu_valA(alu_valA),
	.alu_valB(alu_valB)
  );

    memory memory(
    .clk(clk),
    .valA(valA),
    .valE(valE),
    .valM(valM),
    .valP(valP),

    .icode(icode)
  );

  writeback writeback(
    .clk(clk),
    .cnd(cnd),
    .rA(rA),
    .rB(rB),
    .valM(valM),
    .valE(valE),
    .icode(icode),
    .ifun(ifun),

    .reg0(reg0),  
    .reg1(reg1),
    .reg2(reg2),
    .reg3(reg3),
    .reg4(reg4),
    .reg5(reg5),
    .reg6(reg6),
    .reg7(reg7),
    .reg8(reg8),  
    .reg9(reg9),
    .reg10(reg10),
    .reg11(reg11),
    .reg12(reg12),
    .reg13(reg13),
    .reg14(reg14),
    .reg15(reg15)

  );

nextPC pc(
  .nextPC(nextPC),
  .clk(clk),
  .valP(valP),
  .valC(valC),
  .valM(valM),
  .cnd(cnd),
  .icode(icode)
  // .hlt(hlt)
);


initial begin
	$dumpfile("SEQGTK.vcd");
	$dumpvars(0,SEQ);
end
  //instruction code:
initial begin
  $readmemh("../SampleTestcase/combinationA.txt",instr_mem);
end  

always @(posedge clk) begin
  PC = nextPC;
end

initial begin
    clk=0;
    PC = 64'd0;
  end 

  always@(posedge clk)begin
    if(instr_valid==0||imem_error==1)begin
      $finish;
    end
    if(hlt==1)begin
      $display("halting program execution:Hlt statement detected\n");
      $finish;
    end
  end
  
  always #10 clk = ~clk;

endmodule