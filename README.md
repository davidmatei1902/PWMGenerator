# ⚙️ Programmable PWM Signal Generator

## Introduction

This project represents the Register-Transfer Level (RTL) implementation in Verilog of a dedicated peripheral for generating **PWM (Pulse Width Modulation) Signals**. The module is designed to be integrated as an **SPI Slave** device, allowing for complete configuration of signal characteristics (period, duty cycle, prescaling, and alignment mode).

## Module architecture

The design follows a classic modular structure. 

 Each component fulfills a distinct functional role:

1.  **`spi_bridge.v`**: SPI Physical Interface (Serial-to-Parallel Conversion).
2.  **`instr_dcd.v`**: Finite State Machine (FSM) that interprets commands.
3.  **`regs.v`**: Registers Map for configuration storage.
4.  **`counter.v`**: Timing Base (Counter) with prescaling functionality.
5.  **`pwm_gen.v`**: Comparison Logic and Waveform Generation.
6.  **`top.v`**: Top-level interconnect module.

## Registers map

The peripheral exposes the following byte-addressed memory locations for configuration and status reading:

| Name | Address (Hex) | Width (Bits) | Access | Short Description |
| :--- | :--- | :--- | :--- | :--- |
| **PERIOD** | 0x00 / 0x01 | 16 | R/W | Maximum counter value (PWM period). |
| **COUNTER\_EN** | 0x02 | 1 | R/W | Enables/Disables the counter. |
| **COMPARE1** | 0x03 / 0x04 | 16 | R/W | Primary commutation value (Duty Cycle). |
| **COMPARE2** | 0x05 / 0x06 | 16 | R/W | Secondary commutation value (Unaligned Mode only). |
| **COUNTER\_RESET**| 0x07 | 1 | W | Triggers the counter reset (2-clock cycle pulse). |
| **COUNTER\_VAL** | 0x08 / 0x09 | 16 | R | Current counter value (read-only). |
| **PRESCALE** | 0x0A | 8 | R/W | Value $N$ for clock scaling ($2^N$ cycles). |
| **UPNOTDOWN** | 0x0B | 1 | R/W | Counting direction (1=UP, 0=DOWN). |
| **PWM\_EN** | 0x0C | 1 | R/W | Enables/Disables the PWM signal output. |
| **FUNCTIONS** | 0x0D | 2 | R/W | Alignment mode. |

## Implementation details and specific logic

### `regs.v` (register block)

This module handles memory access and the specialized behavior of control registers:

  * **16-bit Addressing:**
      * 16-bit registers (`PERIOD`, `COMPAREx`) are accessed byte by byte: LSB address (e.g., `0x00`) and LSB + 1 address (e.g., `0x01`) for the MSB.
  * **`COUNTER_RESET` Logic (0x07):**
      * Upon writing to address `0x07`, the internal counter **`count_reset_ctr`** is initialized.
      * The output signal **`count_reset`** is kept active (`1`) for **exactly two clock cycles (`clk`)** by decrementing the counter, ensuring a non-persistent reset signal.

### `counter.v` (timing base)

The Counter logic is composed of two synchronous parts:

  * **Prescaler:**
      * Calculates the limit as $2^{\text{prescale}} - 1$.
      * Generates the **`tick_enable`** signal when the internal count reaches the limit.
  * **Main Counter (`internal_count`):**
      * Increments/decrements only when **`en`** is active **AND** a **`tick_enable`** pulse is received.
      * Manages *roll-over* behavior:
          * **UP:** Rolls back to `0` when it reaches `period`.
          * **DOWN:** Rolls back to `period` when it reaches `0`.

### `pwm_gen.v` (output generator)

The module determines the output signal state (`pwm_out`) by comparing `count_val` with the `compare1` and `compare2` thresholds.

  * **Aligned Modes (`functions[1]=0`):**
      * **Left (`2'b00`):** High (`1`) at the start of the period, Low (`0`) after `COMPARE1`.
      * **Right (`2'b01`):** Low (`0`) at the start of the period, High (`1`) after `COMPARE1`.
  * **Unaligned (Window) Mode (`functions[1]=1`):**
      * The signal is High (`1`) **only** within the window defined by `COMPARE1 $\le$ count\_val $< COMPARE2$`.
  * **Final Control:** The final output is forced to `0` when **`pwm_en`** is inactive.

## Testing and verification (unit testing)

Comprehensive verification is essential and relies on Unit Testbenches (TB) that isolate the logic of each module:

1.  **`spi_bridge.v`**: Verification of bit shifting rate and `byte_sync` timing.
2.  **`regs.v`**: Verification of the 2-clock cycle pulse of `COUNTER_RESET` and LSB/MSB access accuracy.
3.  **`counter.v`**: Correct measurement of the frequency division ratio set by `prescale` (e.g., $2^{\text{prescale}}$).
4.  **`pwm_gen.v`**: Measurement of the Duty Cycle on `pwm_out` for all three operational modes.
