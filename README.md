# Dual-clock asynchronous FIFO

The [SystemVerilog FIFO](asynch_fifo.sv) transfers words between independent write and read clocks. Its default configuration stores 16 words of 8 bits. Use a power-of-two depth of at least two for the pointer and wraparound logic.

| Domain | Accepted operation | Result |
|---|---|---|
| Write clock | `wr_en && !wr_full` at a rising edge | Store `wr_data` and advance the write pointer. |
| Read clock | `rd_en && !rd_empty` at a rising edge | Register the next word on `rd_data` and advance the read pointer. |

## Clock-domain crossing

Each side addresses memory with a binary pointer and sends a Gray-coded pointer through two synchronizer registers to the other domain. The read side compares its next Gray pointer with the synchronized write pointer to detect empty. The write side inverts the two most significant bits of the synchronized read pointer for its full comparison. Because synchronization takes clock edges, a read or write in one domain takes time to affect the opposite flag.

## Related RTL projects

[RISC-V processor](https://github.com/ismail04832/risc-v) · [Pipelined AES-128](https://github.com/ismail04832/AES128-pipelined-vhdl) · [Bus encoding and assertions](https://github.com/ismail04832/CRT) · [OFDM cyclic-prefix metric](https://github.com/ismail04832/detection-prefixe-_cyclique) · [RTL exercises](https://github.com/ismail04832/Training)
