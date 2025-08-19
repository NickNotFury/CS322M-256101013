# Master–Slave Handshake FSM

## Overview
This project implements and tests a **4-phase request/acknowledge handshake** protocol between a Master FSM and a Slave FSM, with an 8-bit data bus.  

### Protocol Flow
1. **Master** drives data and asserts `req`.  
2. **Slave** latches data when `req=1` and asserts `ack` for 2 cycles.  
3. **Master** sees `ack`, drops `req`.  
4. **Slave** sees `req=0`, drops `ack`.  
5. Process repeats for **4 bytes** (`A0`, `A1`, `A2`, `A3`).  
6. After the 4th byte, Master pulses `done=1` for 1 cycle.  

### Reset
- **Synchronous, active-high** reset.  
- Both FSMs start in IDLE.  

---