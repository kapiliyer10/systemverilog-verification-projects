

---



\## Processor Overview



\### **1. Non-Pipelined Version (`RISCVwop.v`)**

Implements a basic single-cycle RISC-V datapath:

\- Fetch  

\- Decode  

\- Execute  

\- Memory  

\- Write-back  



All operations occur in one cycle, making the design simple but slower for complex programs.



---



\### **2. Pipelined Version (`RISCV\_wp.v`)**

Implements a 5-stage RISC-V pipeline:



1\. **IF** – Instruction Fetch  

2\. **ID** – Instruction Decode \& Register Fetch  

3\. **EX** – Execute / ALU  

4\. **MEM** – Load / Store  

5\. **WB** – Write back to register file  



Includes:

\- Pipeline registers  

\- Hazard control logic (if implemented)  

\- ALU control and forwarding paths depending on your design



---



\## 🔧 Modules Description



\### **ALU.v**

Implements arithmetic and logical operations including:

\- ADD, SUB  

\- AND, OR, XOR  

\- SLT, etc.



\### **ALU\_Control.v**

Decodes funct3/funct7 and ALUOp to generate ALU control signals.



\### **Regmem.v**

Contains:

\- 32×32-bit register file  

\- Data memory used for LW, SW operations



\### **PC.v**

Program counter logic handling sequential PC updates and branch targets.



---



\## 📦 Instruction Test Files



Located in `Instructions/`:



| File | Description |

|------|-------------|

| `R\_type\_test.hex` | Binary test program for R-type instructions |

| `R\_type\_test\_instructions.txt` | Human-readable version |

| `B\_type\_test.hex` | Branch instruction tests |

| `B\_type\_test\_instructions.txt` | Human-readable version |



You can load these into instruction memory to verify functionality.



---



\## How to Simulate



You can simulate using Vivado, ModelSim, or Verilator.



\### Example (Vivado Simulation)

1\. Create a simulation project  

2\. Add:

&nbsp;  - `RISCVwop.v` or `RISCV\_wp.v`  

&nbsp;  - All dependent modules (`ALU.v`, `Regmem.v`, etc.)  

3\. Load an instruction memory file (e.g., `R\_type\_test.hex`)  

4\. Run behavioral simulation  

5\. Observe register/memory updates



---



\## Future Improvements (Optional)



\- Stalling logic

\- Support for more RISC-V instructions

\- Integration with an assembler toolchain



---



\## ✨ Author

Kapil Iyer  

RISC-V RTL Design (Academic/Project Work)

