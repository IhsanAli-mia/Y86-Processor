module fetchtb;
  reg clk;
  reg [63:0] PC;
  
  wire [3:0] icode;
  wire [3:0] ifun;
  wire [3:0] rA;
  wire [3:0] rB; 
  wire [63:0] valC;
  wire [63:0] valP;

  reg [7:0] instr_mem[0:1023]; // memory
  wire [8*1024-1:0] imem;

  genvar i;
  for (i=0; i<128; i=i+1)
  begin
    assign imem[64*i+63:64*i] = instr_mem[i];
  end


  //testing code:
initial begin
  //halt
  instr_mem[0] = 'h00;

  //nop
  instr_mem[1] = 'h10;

  //cmovle
  instr_mem[2] = 'h21;
  instr_mem[3] = 'h02; //rA rB

  //cmovge
  instr_mem[4] = 'h25;
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
  instr_mem[19] = 'h0F; //setting displacement as 15
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
  instr_mem[29] = 'h0F; //setting displacement as 15
  instr_mem[30] = 'h00;
  instr_mem[31] = 'h00;
  instr_mem[32] = 'h00;
  instr_mem[33] = 'h00;
  instr_mem[34] = 'h00;
  instr_mem[35] = 'h00;
  instr_mem[36] = 'h00;

  //opadd
  instr_mem[37] = 'h60; 
  instr_mem[38] = 'h02; //rA rB

  //opand
  instr_mem[39] = 'h62; 
  instr_mem[40] = 'h02; //rA rB

  //jle
  instr_mem[41] = 'h71;
  instr_mem[42] = 'h00; //setting displacement as 1024
  instr_mem[43] = 'h04; 
  instr_mem[44] = 'h00;
  instr_mem[45] = 'h00;
  instr_mem[46] = 'h00;
  instr_mem[47] = 'h00;
  instr_mem[48] = 'h00;
  instr_mem[49] = 'h00;

  //jge
  instr_mem[50] = 'h75;
  instr_mem[51] = 'h45; //setting displacement as 69
  instr_mem[52] = 'h00;
  instr_mem[53] = 'h00;
  instr_mem[54] = 'h00;
  instr_mem[55] = 'h00;
  instr_mem[56] = 'h00;
  instr_mem[57] = 'h00;
  instr_mem[58] = 'h00;

  //call
  instr_mem[59] = 'h80;
  instr_mem[60] = 'hCC; //setting dest as 204
  instr_mem[61] = 'h00;
  instr_mem[62] = 'h00;
  instr_mem[63] = 'h00;
  instr_mem[64] = 'h00;
  instr_mem[65] = 'h00;
  instr_mem[66] = 'h00;
  instr_mem[67] = 'h00;

  //ret
  instr_mem[68] = 'h90;

  //pushq
  instr_mem[69] = 'hA0;
  instr_mem[70] = 'h0F;

  //popq
  instr_mem[71] = 'hB0;
  instr_mem[72] = 'h0F;

  //halt
  instr_mem[73] = 'h00;
  end  

  fetch fetch(
    .clk(clk),
    .PC(PC),
    .icode(icode),
    .ifun(ifun),
    .rA(rA),
    .rB(rB),
    .valC(valC),
    .valP(valP),
    .imem(imem)
  );
  
  initial begin 
    clk=0;
    PC=64'd0;

    #10 clk=~clk;PC=64'd0;
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
  end 
  
  initial 
		$monitor("clk=%d PC=%d icode=%b ifun=%b rA=%b rB=%b,valC=%d,valP=%d\n",clk,PC,icode,ifun,rA,rB,valC,valP);
endmodule