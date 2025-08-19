# Vending Machine FSM

## Overview
This testbench verifies the `vending_mealy` FSM, a **coin-operated vending machine** with the following rules:

- **Price:** 20  
- **Accepted coins:** 5 (`coin=01`), 10 (`coin=10`), idle (`coin=00`)  
- **Outputs:**
  - `dispense` → 1-cycle pulse when `total ≥ 20`  
  - `chg5` → 1-cycle pulse when `total = 25` (extra 5 returned)  
- After dispensing, the total resets to 0.  
- Invalid input `coin=11` is ignored.  
- FSM type: **Mealy**, synchronous reset (active-high).

---