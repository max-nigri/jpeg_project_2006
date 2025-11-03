# JPEG Encoder Hardware Project

Developed by Max Nigri

## Overview
This repository documents a hardware design project developed as part of the **Advanced Logic Design** course I taught at the **Computer Engineering Department, The Hebrew University of Jerusalem**, from 2006 to 2017.  

The course was designed from scratch and aimed to expose students to **real-world chip design concepts** through a challenging final project: implementing a **JPEG encoder in hardware**.

---

## Background
The idea for this project originated from my professional background in the **video compression industry**.  
In the late 1990s, I worked at **VisionTech**, a company that developed the **first real-time MPEG-2 encoder chip for digital cameras**.  

At that time, video encoding required specialized boards filled with digital chips and could not be performed in real time. To put it into perspective:
- Encoding **1 second of video** used to take **10 seconds**.
- VisionTech’s design achieved **real-time encoding for the first time**, a groundbreaking achievement.
- The company was later acquired by **Broadcom**, a major player in the semiconductor industry.

This experience shaped the foundation for the JPEG encoder project in the academic course.

---

## Project Description
The final project tasked students with building a **JPEG encoder in hardware** using digital logic and chip design methodologies.  

By the end of the project, students achieved the following:
1. Accept a **BMP image file** as input.
2. Use a **testbench** to read the BMP file.
3. Encode the image into a **JPEG file**.
4. Produce a valid JPEG output that can be viewed in a browser or any standard image viewer.

As an optional extension, the design could be synthesized and mapped to an **FPGA** or even an **ASIC**, making the project a stepping stone toward real-world hardware implementation.

---

## Learning Goals
- Apply **advanced logic design** principles.
- Gain hands-on experience with **digital image compression**.
- Understand the **mapping of algorithms to hardware**.
- Explore the path from **RTL design** to FPGA/ASIC realization.

---
**Keywords:** JPEG encoder, FPGA, ASIC, hardware design, logic design, digital image compression, Verilog, VHDL, Advanced Logic Design, Hebrew University


## Notes
This project is from an academic setting (2006–2017) and reflects the state of digital design education at that time. While technology has advanced since then, the fundamental principles of **digital logic design**, **hardware description languages**, and **system-level thinking** remain highly relevant today.

---
