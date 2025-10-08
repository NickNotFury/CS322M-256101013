# RVX10 — Single‑Cycle Extension (CUSTOM‑0)

This submission implements **RVX10 (10 custom single‑cycle instructions)** on top of the provided RV32I single‑cycle core, using the reserved **CUSTOM‑0 (0x0B)** opcode【59†source】.

## Build & Run
Use the included Icarus Verilog flow:
```bash
# Example
iverilog -g2012 -o sim riscvsingle.sv
vvp sim
```

The simulation prints **“Simulation succeeded”** when the program **stores 25 to address 100**【59†source】.

## Files
- `src/riscvsingle.sv` — RTL with RVX10 decode + ALU logic integrated.
- `docs/ENCODINGS.md` — exact bitfields + worked encodings.
- `docs/TESTPLAN.md` — per‑op cases and edge conditions.
- `tests/rvx10.hex` — self‑contained mem image; includes some RVX10 ops and ends with `sw x4, 100(x0)` where `x4=25`.

## Notes
- Single‑cycle semantics; no new CSRs/flags; use existing datapath blocks【59†source】.
- **Rotate‑by‑0** returns `rs1` (no shift‑by‑32)【59†source】.
- **ABS(INT_MIN)** = `0x8000_0000` (wrap)【59†source】.
- Writes to **x0** ignored by regfile, as usual【59†source】.
