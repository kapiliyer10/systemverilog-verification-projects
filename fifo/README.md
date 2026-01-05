FIFO_RTL_AND_Testbench

Introduction

FIFO is an essential component used to temporarily store and transfer
the data, with synchronous read and write operation driven by a clock.
This project is created for learning about the verification environment
and contains the RTL as well as testbench of a FIFO buffer written in
System Verilog and executed in Xilinx Vivado.

Folder structure

- fifo_rtl folder contains the rtl block of the synchronous fifo.

- fifo_testbench contains the verification environment of fifo to verify
  its behaviour.

RTL

The RTL module consists of FIFO with asynchronous reset and synchronous
R/W operations with respect to the clock. Data count is used to keep
track of the data written into the FIFO that are yet to be read.
Parameters such as DEPTH and WIDTH can be adjusted according to the
application.

Testbench

- The testbench follows Mailbox-based transaction flow:
  (Generator → Driver → Monitor → Scoreboard).

- Contains Functional coverage which keeps track of the different test
  scenarios received at the monitor.

- Contains Assertions (SVA) in the fifo_checker module.

- Contains Directed Tests (Commented) as well as Constraint Random Tests
  in the generator file.

- Contains Clocking block for synchronizing the data flow from
  Driver → Interface→ Monitor


Verification Architecture

<img width="1155" height="657" alt="image" src="https://github.com/user-attachments/assets/5897647c-16cf-4817-a9e5-fad7ed7a45bb" />

