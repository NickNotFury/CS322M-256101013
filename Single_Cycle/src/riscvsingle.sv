// riscvsingle.sv
// RISC-V single-cycle processor
// From Section 7.6 of Digital Design & Computer Architecture
// 27 April 2020
// David_Harris@hmc.edu 
// Sarah.Harris@unlv.edu

// run 210
// Expect simulator to print "Simulation succeeded"
// when the value 25 (0x19) is written to address 100 (0x64)

// Single-cycle implementation of RISC-V (RV32I)
// User-level Instruction Set Architecture V2.2 (May 7, 2017)
// Implements a subset of the base integer instructions:
//    lw, sw
//    add, sub, and, or, slt, 
//    addi, andi, ori, slti
//    beq
//    jal
// Exceptions, traps, and interrupts not implemented
// little-endian memory

module testbench();
  logic        clk;
  logic        reset;
  logic [31:0] WriteData, DataAdr;
  logic        MemWrite;

  top dut(clk, reset, WriteData, DataAdr, MemWrite);
  
  initial begin
    reset <= 1; #22; reset <= 0;
  end

  always begin
    clk <= 1; #5; clk <= 0; #5;
  end

  always @(negedge clk)
    if(MemWrite) begin
      if(DataAdr === 100 & WriteData === 25) begin
        $display("Simulation succeeded");
        $stop;
      end else if (DataAdr !== 96) begin
        $display("Simulation failed");
        $stop;
      end
    end
endmodule

module top(input  logic        clk, reset, 
           output logic [31:0] WriteData, DataAdr, 
           output logic        MemWrite);

  logic [31:0] PC, Instr, ReadData;
  
  riscvsingle rvsingle(clk, reset, PC, Instr, MemWrite, DataAdr, 
                       WriteData, ReadData);
  imem imem(PC, Instr);
  dmem dmem(clk, MemWrite, DataAdr, WriteData, ReadData);
endmodule

module riscvsingle(input  logic        clk, reset,
                   output logic [31:0] PC,
                   input  logic [31:0] Instr,
                   output logic        MemWrite,
                   output logic [31:0] ALUResult, WriteData,
                   input  logic [31:0] ReadData);

  logic       ALUSrc, RegWrite, Jump, Zero;
  logic [1:0] ResultSrc, ImmSrc;
  logic [4:0] ALUControl;

  controller c(Instr[6:0], Instr[14:12], Instr[31:25], Instr[30], Zero,
               ResultSrc, MemWrite, PCSrc,
               ALUSrc, RegWrite, Jump,
               ImmSrc, ALUControl);
  datapath dp(clk, reset, ResultSrc, PCSrc,
              ALUSrc, RegWrite,
              ImmSrc, ALUControl,
              Zero, PC, Instr,
              ALUResult, WriteData, ReadData);
endmodule

module controller(input  logic [6:0] op,
                  input  logic [2:0] funct3,
                  input  logic [6:0] funct7,
                  input  logic       funct7b5,
                  input  logic       Zero,
                  output logic [1:0] ResultSrc,
                  output logic       MemWrite,
                  output logic       PCSrc, ALUSrc,
                  output logic       RegWrite, Jump,
                  output logic [1:0] ImmSrc,
                  output logic [4:0] ALUControl);

  logic [1:0] ALUOp;
  logic       Branch;
  logic [4:0] ALUControl_dec;

  maindec md(op, ResultSrc, MemWrite, Branch,
             ALUSrc, RegWrite, Jump, ImmSrc, ALUOp);
  aludec  ad(op[5], funct3, funct7[5], ALUOp, ALUControl_dec);

  // RVX10 CUSTOM-0 decode using combinational logic
  always_comb begin
    if (op == 7'b0001011) begin
      case ({funct7, funct3})
        10'b0000000_000: ALUControl = 5'b1_0000; // ANDN
        10'b0000000_001: ALUControl = 5'b1_0001; // ORN
        10'b0000000_010: ALUControl = 5'b1_0010; // XNOR
        10'b0000001_000: ALUControl = 5'b1_0011; // MIN
        10'b0000001_001: ALUControl = 5'b1_0100; // MAX
        10'b0000001_010: ALUControl = 5'b1_0101; // MINU
        10'b0000001_011: ALUControl = 5'b1_0110; // MAXU
        10'b0000010_000: ALUControl = 5'b1_0111; // ROL
        10'b0000010_001: ALUControl = 5'b1_1000; // ROR
        10'b0000011_000: ALUControl = 5'b1_1001; // ABS
        default:         ALUControl = 5'b0_0000; // default to ADD
      endcase
    end else begin
      ALUControl = ALUControl_dec;
    end
  end

  assign PCSrc = Branch & Zero | Jump;
endmodule

module maindec(input  logic [6:0] op,
               output logic [1:0] ResultSrc,
               output logic       MemWrite,
               output logic       Branch, ALUSrc,
               output logic       RegWrite, Jump,
               output logic [1:0] ImmSrc,
               output logic [1:0] ALUOp);

  logic [10:0] controls;

  assign {RegWrite, ImmSrc, ALUSrc, MemWrite,
          ResultSrc, Branch, ALUOp, Jump} = controls;

  always_comb
    case(op)
      7'b0000011: controls = 11'b1_00_1_0_01_0_00_0; // lw
      7'b0100011: controls = 11'b0_01_1_1_00_0_00_0; // sw
      7'b0110011: controls = 11'b1_xx_0_0_00_0_10_0; // R-type 
      7'b1100011: controls = 11'b0_10_0_0_00_1_01_0; // beq
      7'b0010011: controls = 11'b1_00_1_0_00_0_10_0; // I-type ALU
      7'b1101111: controls = 11'b1_11_0_0_10_0_00_1; // jal
      7'b0110111: controls = 11'b1_11_1_0_00_0_00_0; // LUI
      7'b0010111: controls = 11'b1_11_1_0_00_0_00_0; // AUIPC
      7'b1100111: controls = 11'b1_00_1_0_10_0_00_1; // JALR
      7'b0001011: controls = 11'b1_xx_0_0_00_0_10_0; // CUSTOM-0
      default:    controls = 11'bx_xx_x_x_xx_x_xx_x; // non-implemented
    endcase
endmodule

module aludec(input  logic       opb5,
              input  logic [2:0] funct3,
              input  logic       funct7b5, 
              input  logic [1:0] ALUOp,
              output logic [4:0] ALUControl);

  logic  RtypeSub;
  assign RtypeSub = funct7b5 & opb5;

  always_comb
    case(ALUOp)
      2'b00:                ALUControl = 5'b0_0000; // addition
      2'b01:                ALUControl = 5'b0_0001; // subtraction
      default: case(funct3)
        3'b000:  if (RtypeSub) 
                    ALUControl = 5'b0_0001; // sub
                  else          
                    ALUControl = 5'b0_0000; // add, addi
        3'b010:    ALUControl = 5'b0_0101; // slt, slti
        3'b011:    ALUControl = 5'b0_0110; // sltu, sltiu
        3'b100:    ALUControl = 5'b0_0100; // xor, xori
        3'b110:    ALUControl = 5'b0_0011; // or, ori
        3'b111:    ALUControl = 5'b0_0010; // and, andi
        3'b001:    ALUControl = 5'b0_0111; // sll, slli
        3'b101:    if (funct7b5)
                      ALUControl = 5'b1_0000; // sra, srai
                    else
                      ALUControl = 5'b1_0001; // srl, srli
        default:   ALUControl = 5'b0_xxxx; // ???
      endcase
    endcase
endmodule

module datapath(input  logic        clk, reset,
                input  logic [1:0]  ResultSrc, 
                input  logic        PCSrc, ALUSrc,
                input  logic        RegWrite,
                input  logic [1:0]  ImmSrc,
                input  logic [4:0] ALUControl,
                output logic        Zero,
                output logic [31:0] PC,
                input  logic [31:0] Instr,
                output logic [31:0] ALUResult, WriteData,
                input  logic [31:0] ReadData);

  logic [31:0] PCNext, PCPlus4, PCTarget;
  logic [31:0] ImmExt;
  logic [31:0] SrcA, SrcB, rd1, rd2;
  logic [31:0] Result;

  // next PC logic
  flopr #(32) pcreg(clk, reset, PCNext, PC); 
  adder       pcadd4(PC, 32'd4, PCPlus4);
  adder       pcaddbranch(PC, ImmExt, PCTarget);
  mux2 #(32)  pcmux(PCPlus4, PCTarget, PCSrc, PCNext);
 
  // register file logic
  regfile     rf(clk, RegWrite, Instr[19:15], Instr[24:20], 
                 Instr[11:7], Result, rd1, rd2);
  extend      ext(Instr[31:7], ImmSrc, ImmExt);

  // ALU logic
  always_comb begin
    if (Instr[6:0] == 7'b0110111) // LUI
      SrcA = 32'b0;
    else if (Instr[6:0] == 7'b0010111) // AUIPC
      SrcA = PC;
    else
      SrcA = rd1;
  end
  mux2 #(32)  srcbmux(rd2, ImmExt, ALUSrc, SrcB);
  alu         alu(SrcA, SrcB, ALUControl, ALUResult, Zero);
  mux3 #(32)  resultmux(ALUResult, ReadData, PCPlus4, ResultSrc, Result);
  assign WriteData = rd2;
endmodule

module regfile(input  logic        clk, 
               input  logic        we3, 
               input  logic [ 4:0] a1, a2, a3, 
               input  logic [31:0] wd3, 
               output logic [31:0] rd1, rd2);

  logic [31:0] rf[31:0];

  always_ff @(posedge clk)
    if (we3) rf[a3] <= wd3;	

  assign rd1 = (a1 != 0) ? rf[a1] : 0;
  assign rd2 = (a2 != 0) ? rf[a2] : 0;
endmodule

module adder(input  [31:0] a, b,
             output [31:0] y);

  assign y = a + b;
endmodule

module extend(input  logic [31:7] instr,
              input  logic [1:0]  immsrc,
              output logic [31:0] immext);
 
  always_comb
    case(immsrc) 
      2'b00:   immext = {{20{instr[31]}}, instr[31:20]};  // I-type 
      2'b01:   immext = {{20{instr[31]}}, instr[31:25], instr[11:7]}; // S-type
      2'b10:   immext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0}; // B-type
      2'b11:   immext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0}; // J-type
      default: immext = 32'bx; // undefined
    endcase             
endmodule

module flopr #(parameter WIDTH = 8)
              (input  logic             clk, reset,
               input  logic [WIDTH-1:0] d, 
               output logic [WIDTH-1:0] q);

  always_ff @(posedge clk, posedge reset)
    if (reset) q <= 0;
    else       q <= d;
endmodule

module mux2 #(parameter WIDTH = 8)
             (input  logic [WIDTH-1:0] d0, d1, 
              input  logic             s, 
              output logic [WIDTH-1:0] y);

  assign y = s ? d1 : d0; 
endmodule

module mux3 #(parameter WIDTH = 8)
             (input  logic [WIDTH-1:0] d0, d1, d2,
              input  logic [1:0]       s, 
              output logic [WIDTH-1:0] y);

  assign y = s[1] ? d2 : (s[0] ? d1 : d0); 
endmodule

module imem(input  logic [31:0] a,
            output logic [31:0] rd);

  logic [31:0] RAM[63:0];

  initial
      $readmemh("../tests/rvx10.hex", RAM);

  assign rd = RAM[a[31:2]]; // word aligned
endmodule

module dmem(input  logic        clk, we,
            input  logic [31:0] a, wd,
            output logic [31:0] rd);

  logic [31:0] RAM[63:0];

  assign rd = RAM[a[31:2]]; // word aligned

  always_ff @(posedge clk)
    if (we) RAM[a[31:2]] <= wd;
endmodule

module alu(input  logic [31:0] a, b,
           input  logic [4:0]  alucontrol,
           output logic [31:0] result,
           output logic        zero);

  logic [31:0] condinvb, sum;
  logic        v;
  logic        isAddSub;

  assign condinvb = alucontrol[0] ? ~b : b;
  assign sum = a + condinvb + alucontrol[0];
  assign isAddSub = ~alucontrol[2] & ~alucontrol[1] | ~alucontrol[1] & alucontrol[0];

  always_comb
    case (alucontrol)
      5'b0_0000: result = sum;         // add
      5'b0_0001: result = sum;         // subtract
      5'b0_0010: result = a & b;       // and
      5'b0_0011: result = a | b;       // or
      5'b0_0100: result = a ^ b;       // xor
      5'b0_0101: result = sum[31] ^ v; // slt
      5'b0_0110: result = (a < b) ? 1 : 0; // sltu
      5'b0_0111: result = a << b[4:0]; // sll
      5'b1_0000: result = a >> b[4:0]; // sra
      5'b1_0001: result = a >> b[4:0]; // srl
      5'b1_0010: result = a & ~b;      // ANDN
      5'b1_0011: result = a | ~b;      // ORN
      5'b1_0100: result = ~(a ^ b);    // XNOR
      5'b1_0101: begin // MIN signed
        logic signed [31:0] sa = a, sb = b;
        result = (sa < sb) ? a : b;
      end
      5'b1_0110: begin // MAX signed
        logic signed [31:0] sa = a, sb = b;
        result = (sa > sb) ? a : b;
      end
      5'b1_0111: result = (a < b) ? a : b; // MINU
      5'b1_1000: result = (a > b) ? a : b; // MAXU
      5'b1_1001: begin // ROL
        logic [4:0] sh = b[4:0];
        result = (sh == 0) ? a : ((a << sh) | (a >> (32 - sh)));
      end
      5'b1_1010: begin // ROR
        logic [4:0] sh = b[4:0];
        result = (sh == 0) ? a : ((a >> sh) | (a << (32 - sh)));
      end
      5'b1_1011: begin // ABS
        logic signed [31:0] sa = a;
        result = (sa >= 0) ? a : (-sa);
      end
      default:   result = 32'bx;
    endcase

  assign zero = (result == 0);
  assign v = ~(alucontrol[0] ^ a[31] ^ b[31]) & (a[31] ^ sum[31]) & isAddSub;
endmodule