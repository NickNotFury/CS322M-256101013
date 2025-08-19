# Traffic Light Controller

## Project Goal

This project implements a Moore FSM in Verilog to control a two-road (NS/EW) traffic light system. The timing is dictated by a 1 Hz `tick` signal, with phase durations specified in the number of ticks.

## Verification Strategy: 1 Hz Tick Generation

### The Challenge
A real-world 1 Hz tick is too slow for efficient simulation, as it would require simulating millions of clock cycles for even one traffic light sequence.

### Testbench Solution
To verify the FSM's logic quickly, the testbench does not use a real-time 1 Hz signal. Instead, it generates an accelerated **simulation tick**.

* **System Clock:** The simulation uses a 100 MHz clock (`10 ns` period).
* **Simulation Tick Generation:** A `tick` pulse is generated every **10 clock cycles**.
* **Calculated Simulation Tick Period:** `10 cycles * 10 ns/cycle = 100 ns`.

This allows the FSM's tick-counting logic to be fully tested in a fraction of a second. The durations observed in the simulation waveform are therefore scaled down from seconds to nanoseconds:

* **Green Phase (5 ticks):** Appears as `500 ns` in the waveform.
* **Yellow Phase (2 ticks):** Appears as `200 ns` in the waveform.

This method confirms the design's correctness, which will translate to proper operation when synthesized with a true 1 Hz prescaler.