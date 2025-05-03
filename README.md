# **AES-128 Encryption Core**
This project is a Verilog implementation of the AES-128 encryption algorithm, designed based on the architecture proposed in the paper "*A High-Speed and Area Efficient Hardware Implementation of AES-128 Encryption Standard*". The design focuses on achieving a good balance between throughput and resource usage, suitable for FPGA-based applications.  
This implementation was developed as part of my self-study in digital hardware design. The project helped me gain hands-on experience in datapath and control logic design, as well as performance-area trade-offs in cryptographic cores. While this design follows the architecture of the paper closely, certain adjustments were made during implementation to suit my specific learning objectives and target FPGA platform.

## **Architecture Diagram**
* The architecture of this AES-128 encryption core is designed based on the structure presented in the paper "*A High-Speed and Area Efficient Hardware Implementation of AES-128 Encryption Standard*".
* It follows a high-speed, resource-efficient approach by optimizing the AES datapath and integrating a simplified key schedule, making it well-suited for FPGA-based applications with limited hardware resources.
![AES-128 Architecture](image/aes128_architecture.png)

