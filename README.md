# Single_Master_Single_Slave_SPI_Design
<br>

## SPI (Serial Peripheral Interface) Communication
Devices communicating using SPI Protocol are usually in master-slave relationship. The simplest configuration of the SPI Protocol is the single master single slave configuration. In general, devices with SPI protocol are known to have a single master IP and more than one slave IPs. The SPI bus protocol consists of four signaling pins: MOSI (Master Out Slave In), MISO (Master In Slave Out), SCLK or SCK (serial clock) or MK, and SS (slave select) or CS (chip select).
<br>

## Steps of SPI Data Transmission
- Slave selection : The CS or SS line is usually active low, i.e., drawing the line low, selects the corresponding slave device. In case of a single slave device, to initiate communication, the CS line or the SS line has to be pulled low.
- Clock configuration : SPI communication relies on a clock signal. The master generates a clock signal, and both the master and slave devices need to agree on the clock polarity and phase. These settings define when data is sampled and shifted, and they're commonly referred to as the clock mode (CPOL and CPHA). CPOL (Clock Polarity) defines the idle state of the clock signal. It can be either high (1) or low (0). CPHA (Clock Phase) determines when data is sampled. It can be on the leading or trailing edge of the clock signal.
- Data Transmission : Data is transmitted one byte (or word) at a time. The master device sends data on the MOSI (Master Out Slave In) line, and the slave receives it on the same line. Simultaneously, the slave sends data on the MISO (Master In Slave Out) line, which the master receives.
- Data Reception : As data is transmitted, the receiving device (slave or master, depending on the direction) samples the data on the appropriate clock edge according to the configured clock polarity and phase.
- Repeat or End : The master can send multiple bytes of data or terminate the communication after sending the required data. If there are additional bytes to transmit, the process is repeated.
- Deselection of the slave : After completing the communication, the master device deactivates the CS/SS line by drawing it high, deselecting the slave. This step is essential for enabling other slave devices on the bus to communicate.
<br>

## Simulation 

- Use the following commands on the Ubuntu Linux terminal to install the iverilog simulator and gtkwave waveforms generator.
  ```bash

  sudo apt update
  sudo apt install iverilog
  sudo apt install gtkwave
  ```
- Use the cd command to move to the required folder directory, where the modules are saved.
  ```bash

  iverilog -o verify.out spi_master.v spi_slave.v spi_tb.v

  ```
- Simulate the verify.out file using the following command in the terminal
  ```bash

  vvp verify.out

  ```
  
