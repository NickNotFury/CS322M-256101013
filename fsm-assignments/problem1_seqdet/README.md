# Sequence Detector

## Overview
This testbench verifies the `seq_detect_mealy` FSM module, which detects the **bit pattern `1101`** on a serial input `din`.  
When the last bit of the sequence arrives, the FSM asserts output `y` for **one clock cycle**.  
The FSM is designed to handle **overlapping patterns**.

## Test Sequence 11011011101
- Length: 11 bits  
- Input driven **MSB-first** for readability  

## Pattern of Interest

## Expected Detection Pulses
- **3 valid detections** in the given sequence  
- Detection points (bit indices relative to start of stream):  
  - **Index 3** → bits 0–3 form `1101`  
  - **Index 6** → bits 3–6 form `1101` (overlap)  
  - **Index 10** → bits 7–10 form `1101`  

## FSM Behavior
- **init**: no match yet  
- **one**: saw `1`  
- **two**: saw `11`  
- **three**: saw `110`  
- From **three** on `1`: assert `y=1`, fallback to **one** (enables overlap detection).  
- On reset, FSM returns to **S0**.

## Verification Checks
- **Overlap** verified → `1101` inside `1101101` was detected twice.  
- **Fallback edge** from S110 → S1 confirmed continuous operation.  
- Correct reset behavior (FSM idle, no spurious `y`).  
- FSM produced **exactly 3 pulses** as expected.
