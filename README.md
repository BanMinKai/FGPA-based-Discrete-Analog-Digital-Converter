# FGPA-based-Discrete-Analog-Digital-Converter
Discrete Analog-to-Digital Converter (ADC) Design | ENEL453 Design Project

Project Overview: I designed and implemented four discrete Analog-to-Digital Converter (ADC) architectures on a Basys 3 FPGA. 
The system converts analog input voltages (0-3.3V) into digital values using both Ramp and Successive Approximation Register (SAR) architectures, 
utilizing PWM and R2R ladder techniques for voltage comparison. 

<img width="958" height="755" alt="image" src="https://github.com/user-attachments/assets/aee5c670-1c7f-46c9-ab21-6e22249e7100" />

<img width="1186" height="597" alt="image" src="https://github.com/user-attachments/assets/469cfc37-1827-4027-be98-d144924d812d" />





<img width="779" height="584" alt="image" src="https://github.com/user-attachments/assets/fad24cb4-4498-4bb9-ba61-ff3783dd906b" />
<img width="564" height="303" alt="image" src="https://github.com/user-attachments/assets/7a15b48a-1d4b-4051-bac8-624199c79f2d" />
<img width="619" height="562" alt="image" src="https://github.com/user-attachments/assets/6465e947-f3ef-4de3-8984-950a588f5c31" />

<img width="753" height="655" alt="image" src="https://github.com/user-attachments/assets/e26fef89-240a-4b2f-97ce-e96d3100e216" />

<img width="904" height="146" alt="image" src="https://github.com/user-attachments/assets/6a6cdaa4-16cc-4f49-bb7e-a44e6c318a57" />



Engineering Methodology: Incremental Integration The final system was highly complex, 
but I made it manageable by applying a strict incremental integration strategy:

Modular Development: I began by building and verifying individual baseline components, 
such as the PWM and sawtooth generators, before attempting to build full ADC architectures. 

Successive Complexity: I implemented the Ramp ADCs first due to their simpler logic, 
using them as a foundation to build the more advanced SAR search algorithms. 

Iterative Verification: I conducted testing at every stage to ensure each new feature was functional
and did not cause regression in previously verified modules. 

Mixed-Signal Architecture: I integrated FPGA-based digital logic with external analog components, 
including LM311 comparators and discrete resistor networks. 

Metastability Resolution: During the PWM Ramp design, I identified a data-drifting issue caused by asynchronous signals. 
I resolved this by designing and implementing two-stage flip-flop synchronizers to stabilize the comparator inputs. 

Hardware Optimization: I navigated hardware-specific limitations, such as the response time of the external comparator, 
by implementing a strobe-based clock management system to slow down state transitions for reliable conversion. 

System Integration: I designed a top-level Menu MUX and Selection FSM 
that allowed users to toggle between different ADC outputs and display formats (Raw, Averaged, or Scaled) in real-time on a seven-segment display. 

Hardware: Basys 3 FPGA (Artix-7), R2R Resistor Ladders, LM311 Comparator. 
Tools: Vivado Design Suite, SystemVerilog. 


Key Skills: Digital Logic Design, FSM Implementation, Hardware-Software Co-design, Datasheet Analysis.
