`include "execute.v"
`include "fetch.v"
`include "decode.v"


module executeTB;

  reg clk;
  reg [63:0] PC;
//   reg [63:0] dmem[0:1024];

  wire [3:0] icode;
  wire [3:0] ifun;
  wire [3:0] rA;
  wire [3:0] rB; 
  wire [63:0] valC;
  wire [63:0] valP;
  wire [63:0] valA;
  wire [63:0] valB;
  wire [63:0] valE;
  wire cnd;

  wire imem_error;
  wire instr_valid;
  wire hlt;

  reg [7:0] instr_mem[0:1023]; //Instruction memory
  wire [8*1024-1:0] imem;

  genvar i;
  for (i=0; i<128; i=i+1)
  begin
    assign imem[64*i+63:64*i] = instr_mem[i];
  end

  reg [63:0] registers[0:7];
  reg [511:0] regi;

//   genvar j;
//   for (j=0; j<8; j=j+1)
//   begin
//     assign regi[64*j+63:64*j] = registers[j];
//   end

	// regi = 512'b0;
	

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
    .PC(PC)
  );
  
  decode decode(
    .valA(valA),
    .valB(valB),
    .clk(clk),
    .icode(icode),
    .rA(rA),
    .rB(rB),
    .regi(regi)
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
    .hlt(hlt),
    .zf(zf),
    .sf(sf),
    .of(of),
	.alu_valC(alu_valC),
	.alu_valA(alu_valA),
	.alu_valB(alu_valB)
  );

initial begin
	$dumpfile("executeGTK.vcd");
	$dumpvars(0,executeTB);
end

  //testing code:
initial begin

  regi = 515'b1;

  registers[0] = 64'd0;
  registers[1] = 64'd1; 
  registers[2] = 64'd2; 
  registers[3] = 64'd3; 
  registers[4] = 64'd4; 
  registers[5] = 64'd5; 
  registers[6] = 64'd6; 
  registers[7] = 64'd7; 
  //halt
  instr_mem[0] = 'h00;

  //nop
  instr_mem[1] = 'h10;

  //cmovle
  instr_mem[2] = 'h20;
  instr_mem[3] = 'h17; //rA rB

  //cmovge
  instr_mem[4] = 'h21;
  instr_mem[5] = 'h02; //rA rB

  //irmov
  instr_mem[6] = 'h30;
  instr_mem[7] = 'hF2; //F rB
  instr_mem[8] = 'hCD; //move value ABCD
  instr_mem[9] = 'hAB; 
  instr_mem[10] = 'h00; 
  instr_mem[11] = 'h00; 
  instr_mem[12] = 'h00;
  instr_mem[13] = 'h00;
  instr_mem[14] = 'h00;
  instr_mem[15] = 'h00;

  // halt
  instr_mem[16] = 'h00;
  
  //rmmov
  instr_mem[17] = 'h40; 
  instr_mem[18] = 'h02; // rA rB
  instr_mem[19] = 'h06; //setting displacement as 6
  instr_mem[20] = 'h00;
  instr_mem[21] = 'h00;
  instr_mem[22] = 'h00;
  instr_mem[23] = 'h00;
  instr_mem[24] = 'h00;
  instr_mem[25] = 'h00;
  instr_mem[26] = 'h00;

  //mrmov
  instr_mem[27] = 'h50; 
  instr_mem[28] = 'h02;
  instr_mem[29] = 'h07; //setting displacement as 7
  instr_mem[30] = 'h00;
  instr_mem[31] = 'h00;
  instr_mem[32] = 'h00;
  instr_mem[33] = 'h00;
  instr_mem[34] = 'h00;
  instr_mem[35] = 'h00;
  instr_mem[36] = 'h00;

  //opsub
  instr_mem[37] = 'h60; 
  instr_mem[38] = 'h43; //rA rB

  //cmovne
  instr_mem[39] = 'h24;
  instr_mem[40] = 'h43;

  //opand
  instr_mem[41] = 'h62; 
  instr_mem[42] = 'h43; //rA rB

  //jl
  instr_mem[43] = 'h72;
  instr_mem[44] = 'h00; //setting displacement as 1024
  instr_mem[45] = 'h04; 
  instr_mem[46] = 'h00;
  instr_mem[47] = 'h00;
  instr_mem[48] = 'h00;
  instr_mem[49] = 'h00;
  instr_mem[50] = 'h00;
  instr_mem[51] = 'h00;

  //jge
  instr_mem[52] = 'h75;
  instr_mem[53] = 'h45; //setting displacement as 69
  instr_mem[54] = 'h00;
  instr_mem[55] = 'h00;
  instr_mem[56] = 'h00;
  instr_mem[57] = 'h00;
  instr_mem[58] = 'h00;
  instr_mem[59] = 'h00;
  instr_mem[60] = 'h00;        


  //call
  instr_mem[61] = 'h80;
  instr_mem[62] = 'hCC; //setting dest as 204
  instr_mem[63] = 'h00;
  instr_mem[64] = 'h00;
  instr_mem[65] = 'h00;
  instr_mem[66] = 'h00;
  instr_mem[67] = 'h00;
  instr_mem[68] = 'h00;
  instr_mem[69] = 'h00;

  //ret
  instr_mem[70] = 'h90;

  //pushq
  instr_mem[71] = 'hA0;
  instr_mem[72] = 'h0F;

  //popq
  instr_mem[71] = 'hB0;
  instr_mem[72] = 'h0F;

  //halt
  instr_mem[73] = 'h00;
  end  

initial begin
    clk=0;
    PC=64'd0;
     

    #10 clk=~clk;
    #10 clk=~clk;
    #10 clk=~clk;PC=valP;
    #10 clk=~clk;
    #10 clk=~clk;PC=valP;
    #10 clk=~clk;
    #10 clk=~clk;PC=valP;
    #10 clk=~clk;
    #10 clk=~clk;PC=valP;
    #10 clk=~clk;
    #10 clk=~clk;PC=valP;
    #10 clk=~clk;
    #10 clk=~clk;PC=valP;
    #10 clk=~clk;
    #10 clk=~clk;PC=valP;
    #10 clk=~clk;
    #10 clk=~clk;PC=valP;
    #10 clk=~clk;
    #10 clk=~clk;PC=valP;
    #10 clk=~clk;
    #10 clk=~clk;PC=valP;
    #10 clk=~clk;
    #10 clk=~clk;PC=valP;
    #10 clk=~clk;
    #10 clk=~clk;PC=valP;
    #10 clk=~clk;
    #10 clk=~clk;
  end 
  
  initial
  if(1)begin
		// $monitor("PC=%d\nclk=%d \nicode=%b \nifun=%b \nrA=%b \nrB=%b \nvalA=%d \nvalB=%d \nvalE=%d \ncnd=%d\n\n",PC,clk,icode,ifun,rA,rB,valA,valB,valE,cnd);
        // $monitor("PC=%d zf=%d of=%d sf=%d cnd=%d",PC,zf,of,sf,cnd);
  end

endmodule