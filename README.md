# UART_RTL_Design_and_Verification
This project is to design and simulate a UART communication interface using Verilog HDL.

1. Introduction 
Universal Asynchronous Receiver Transmitter (UART) is one of the most widely used serial communication protocols in embedded systems and digital electronics. UART enables asynchronous communication between two devices using only two communication lines namely Transmit (TX) and Receive (RX).
Unlike synchronous communication protocols, UART does not require a separate clock signal between communicating devices. Instead, both transmitter and receiver operate using a predefined baud rate.
UART communication is extensively used in:
Microcontrollers
Embedded systems
FPGA communication
GPS modules
Bluetooth modules
Serial debugging interfaces
In this project, a UART interface is designed and verified using Verilog HDL based on the Texas Instruments UART architecture reference.

2. Objective
The main objective of this project is to design and simulate a UART communication interface using Verilog HDL.
The objectives include:
Understanding UART communication protocol
Designing UART Transmitter and Receiver modules
Generating baud rate timing
Implementing serial data transmission and reception
Verifying UART functionality using ModelSim simulation
Studying UART architecture from TI datasheet
3. Datasheet Study
The project is based on the Texas Instruments UART User Guide.
The datasheet explains:
UART architecture
Asynchronous communication
Baud rate generation
FIFO buffering
Receiver and transmitter operation
Error handling mechanisms
The UART frame generally contains:
1 Start Bit
8 Data Bits
Optional Parity Bit
1 Stop Bit
The UART operates asynchronously, meaning transmitter and receiver communicate without sharing a common clock signal.
4. UART Architecture & Block Diagram 
The UART interface designed in this project contains the following modules:
Baud Rate Generator
UART Transmitter
UART Receiver
FIFO Buffer
Control Logic
The UART interface implemented in this project utilizes a modular, highly synchronized loopback RTL architecture. It comprises three primary functional hardware blocks integrated within a top-level wrapper:
Baud Rate Generator (baud_gen): A down-scaling digital frequency divider that generates timing strobes (baud_tick) to establish synchronous sampling windows across asynchronous domains.
UART Transmitter (uart_tx): A 4-state Finite State Machine (FSM) that captures an 8-bit parallel data bus and sequences it into a single-bit serial stream.
UART Receiver (uart_rx): An optimized 3-state FSM that continuously monitors the serial fabric line, synchronizes on incoming falling edges, samples the sequential stream, and reconstructs the parallel data word.

5. UART Frame Format
The UART data frame used in this project consists of:
1 Start Bit
8 Data Bits
1 Stop Bit
Frame Structure:
| Start | D0 | D1 | D2 | D3 | D4 | D5 | D6 | D7 | Stop |
The Start Bit is logic 0 and the Stop Bit is logic 1.

6. Design & Simulation Pacing Calculations 
To make the serial activity highly visible and efficient during ModelSim behavioral simulation, a simulation scaling parameter divisor of 10 was utilized.
For actual hardware mapping onto a physical platform operating on a 50 MHz system clock (20 ns cycle duration), the calculation for an industrial 9600 Baud Rate is derived.
To prevent bit-truncation or overflow bugs during synthesis, the internal tracking register inside baud_gen.v is declared as a 13-bit wide variable (reg [12:0] counter), as $2^{13} = 8192$, safely encompassing the hardware limit value of 5208. 

7. RTL Design & Finite State Machine Specifications 

7.1 Baud Rate Generator
The baud rate generator produces timing pulses required for UART transmission and reception.
The generator divides the system clock frequency according to the required baud rate.

7.2 UART Transmitter FSM States 
The transmitter operations are governed by a 4-state sequential state machine: 
IDLE (2'b00): The serial output line tx is held at a steady logic high state (1). The block monitors the control line tx_start. Upon assertion, the parallel input data bus tx_data is latched into an internal storage register data_reg.
START (2'b01): On the next active baud_tick, the serial line tx is pulled low to logic 0 to initiate the framing packet start command.
DATA (2'b10): The system cycles through bit indices 0 to 7. At each successive baud clock pulse, individual data bits are routed to the tx pin, shifting out the payload Least Significant Bit (LSB) first.
STOP (2'b11): The line returns high to logic 1 for one full bit period to close the packet framing window before returning the machine to the IDLE state loop.

7.3 UART Receiver FSM States 
To optimize layout pathing, the receiver is implemented via a high-efficiency 3-state control loop:
IDLE (2'b00): The receiver continuously polls the incoming line. Once rx == 0 and a valid baud_tick strobe occurs concurrently, the block confirms a true Start Bit condition and moves to the DATA state.
DATA (2'b01): The receiver samples the physical rx trace at each following baud_tick transition pulse, reassembling the incoming serial profile directly into an internal register matrix (data_reg[bit_index]).
STOP (2'b10): Upon capturing all 8 bits, the block confirms the presence of the high Stop Bit framework, copies the completed byte onto the system parallel port rx_data, and drives the output strobe rx_done high for a single cycle to notify the system.

7.4 FIFO Buffer
FIFO (First In First Out) buffer is used for temporary storage of transmitted and received data.
The FIFO improves communication reliability by handling multiple data bytes efficiently.
FIFO features:
Data buffering
Sequential data access
Full and Empty indication

8. Simulation and Verification Results 
Simulation of the UART interface was performed using ModelSim software.
The following signals were verified:
clk
reset
tx_data
tx
rx
rx_data
tx_busy
rx_done
The simulation verified correct serial transmission and reception of UART data.
Functional verification was executed using ModelSim Intel FPGA Edition. The test bench environment stimulated the design with a payload input byte of 8'h41 (ASCII code for character 'A').
Waveform Timing Event Logs:
0 ns – 100 ns: System initialization window. Master active-high reset is held high, driving all register configurations and state variables into safe default baseline positions.
100 ns: The reset vector drops to low logic 0, arming the functional blocks.
200 ns: The master validation lines apply tx_data = 8'h41 and pulse the trigger control line tx_start high for one complete clock cycle phase.
200 ns – 2800 ns: The serialization trace tx drops low to form the start bit, followed by sequential transitions tracking the structural binary value components of 8'h41 sent LSB first (1, 0, 0, 0, 0, 0, 1, 0).
2810 ns: The simulation automatically logs a success verification flag and encounters a testbench-driven $stop interrupt:
Example:
Transmitted Data = 8'b10101010
Received Data = 8'b10101010

9. Analysis
During the implementation and testing of the UART loopback interface, several foundational digital design concepts were deeply explored and validated:
Asynchronous Communication: Understanding how two independent systems communicate reliably over a single wire without sharing a common clock signal.
Finite State Machine (FSM) Design: Implementing structured, sequential state machines to control transmission state transitions and deterministic receiver sampling windows.
Serial-to-Parallel & Parallel-to-Serial Conversion: Utilizing shift registers to capture parallel data buses and serialize them for the single-wire fabric, as well as reconstructing the raw bitstream back into a stable byte payload.
Baud Rate Synchronization: Utilizing a digital clock divider to generate precise localized sampling pulses (baud_tick) to eliminate signal drift during data transmission.
The clean functional simulation waveforms extracted from ModelSim confirm that the individual transmitter and receiver modules communicate in complete alignment with standard UART protocol timing rules.

10. Future Enhancements
While the current design successfully proves structural loopback functionality, the architecture can be expanded with the following industry-standard features:
Parity Bit Generation and Checking: Implementing parity bit logic calculations (Odd/Even) to enable single-bit error detection across noisy physical hardware connections.
Configurable Baud Rate Control Registers: Adding dynamic control registers so external processors can alter the target baud rate division settings at runtime.
Hardware Interrupt Support (IRQ): Integrating an interrupt flag pin to automatically notify a host processor the exact instant rx_done goes high, eliminating the need for CPU-heavy polling.
Hardware FIFO Buffering: Integrating dedicated Transmit and Receive FIFO hardware arrays to allow continuous multi-byte packet data streaming without overwriting data bytes.
Physical FPGA Board Deployment: Mapping the Verilog pin assignments onto a physical FPGA development board (such as an Intel Cyclone IV or DE10-Lite) to interface with actual PC hardware via a USB-to-UART bridge converter chip.

11. Applications
The modular UART communication core designed in this project is highly versatile and extensively utilized in systems such as:
Embedded System Peripherals: Low-speed chip-to-chip data transfers in modern internet-of-things (IoT) nodes.
FPGA System Diagnostics: Creating custom serial console ports to stream internal register debugging statements to a computer screen during testing.
Microcontroller and Module Integration: Establishing primary data communication lines between central microcontrollers and peripherals like GPS receivers, Bluetooth modules, or Wi-Fi modems.
Industrial Automation Nodes: Providing a baseline physical serial backplane for low-level automation equipment tracking.

12. Conclusion
The UART interface was successfully modeled, implemented, and verified using structural Verilog HDL. By structuring the design around a modular layout, both the uart_tx and uart_rx blocks were simulated inside ModelSim to confirm 100% functional data integrity during active loopback routing.
This project provided hands-on experience with:
Practical applications of the asynchronous UART communication protocol standard.
RTL design workflows, structural code organization, and multi-module file integration.
FSM-based control systems and optimization of clock gating parameters.
Writing self-checking hardware testbenches and analyzing digital timing waveforms inside an industry-standard simulation tool.

13. References
Texas Instruments UART User Guide Reference Manual: https://www.ti.com/lit/ug/sprugp1/sprugp1.pdf
UART Serial Communication Protocol Standards: https://en.wikipedia.org/wiki/Universal_asynchronous_receiver-transmitter
IEEE Standard Verilog Hardware Description Language Documentation (IEEE Std 1364)
ModelSim Tool Suite Simulation and Functional Waveform Verification Manuals
