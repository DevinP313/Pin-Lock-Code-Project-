# Pin-Lock-Code-Project-

# 🔐 HCS12 PIN-Code Lock System

A microcontroller-based PIN-code lock system implemented on the HCS12 Dragon Board. This project uses a 4x4 keypad, an LCD screen, RGB LEDs, and a piezo speaker to create a simple digital security system with visual and audio feedback.

> 🛠 Built for ECE 3731: Microprocessors and Embedded Systems — Fall 2023  
> 👨‍💻 Team: Devin Pen, Shuban Srikantha, Anthony D’Alfonso, Henry Chen  
> 🎓 University of Michigan–Dearborn

---

## 📌 Project Overview

This embedded system allows a user to:

1. Set a 4-digit PIN using the keypad
2. Re-enter the PIN to authenticate
3. Receive visual and auditory feedback based on input

### ✅ Correct PIN:
- LCD displays “LOGGED IN!”
- Green LED lights up

### ❌ Incorrect PIN (after 3 tries):
- LCD displays “SYSTEM LOCKED!”
- Red LED lights up
- Piezo speaker sounds an alarm

---

## 🧱 Hardware Used

- HCS12 Dragon Board (MC9S12 MCU)
- 4x4 Keypad
- LCD display (2x16)
- RGB LEDs
- Piezo buzzer
- Laptop 

---

## 🧠 Software Features

- Programmed in **Assembly** using **CodeWarrior IDE**
- LCD interface for display output
- Manual keypad scanning via 4x4 matrix logic
- Use of branching and jump conditions to validate input
- Interrupt-driven audio output using the piezo speaker

---

## 📷 Poster
![image](https://github.com/user-attachments/assets/08b8751f-4dfb-41be-b104-08161fe5dacb)

---

## 🧪 Testing

Testing focused on:
- Verifying LCD messages
- Capturing keypad input reliably
- Matching entered PINs to the stored value
- Proper color output from LEDs
- Generating alarm frequency on buzzer

---

## 🎯 Outcome

This project gave our team hands-on experience with embedded design, low-level programming, user interface elements, microcontrollers, firmware, and real-time input handling. We successfully demonstrated the system functioning as expected under all input scenarios.

---

## 🔗 References

- [Dragon12-Plus USB HCS12 Manual](https://www.evbplus.com/download_hcs12/dragon12_plus_usb_9s12_manual.pdf)
- [Charlieplexing (Wikipedia)](https://en.wikipedia.org/wiki/Charlieplexing)
- [Diagrams.net](https://app.diagrams.net/)
