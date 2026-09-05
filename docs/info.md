<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

`flashrom` (PC application) control an SPI flash chip through a programmer such as a MCU. `flashrom` sends commands over USB/serial using the Serprog protocol, and the programmer converts them into SPI signals to read, erase, or write the chip.

## How to test

Run `flashrom -p serprog:dev=/dev/ttyACM0:115200 -r flash_backup.bin`

## External hardware

An 8-pin SPI Flash.
