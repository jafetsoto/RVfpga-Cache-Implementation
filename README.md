# RVfpga:
RVfpga is a course centered around a RISC-V system implemented on an FPGA. It utilizes the open-source SweRV EH1 RISC-V core, running on a Xilinx Artix 7 FPGA on the Digilent Nexys A7 development board. The SweRV EH1 core isn't just for learning; it's employed in real-world products like Imagination GPUs and Western Digital solid-state drives.

# SweRV EH1 RISC-V:
The [SweRV EH1 RISC-V](https://raw.githubusercontent.com/westerndigitalcorporation/swerv_eh1/d9204cf238aeb98996ad1f95c173eca2c3b91d1f/docs/RISC-V_SweRV_EH1_PRM.pdf). core is a 32-bit CPU core that supports RISC-V's integer (I), compressed instruction (C), multiplication and division (M), and instruction-fetch fence and CSR instructions (Z) extensions, specifically RV32IMCZifencei_Zicsr. This core is characterized by a 9-stage, dual-issue, superscalar, mostly in-order pipeline with some out-of-order execution capability.


# Cache implemenataion for Nexys 4DDR:

A cache has been integrated into the RVfpga system. This repository showcases the complete work, providing insights into the implementation and simulation of the cache in the SweRVolfSoC system.