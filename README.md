# G_code_controller

This application reads G-code files and controls a CNC machine via serial communication.  It provides real-time progress updates, error reporting, and displays both the G-code and console output.  It also allows for control over parameters like feed rate and spindle speed.

## Overview

The `G_code_controller` application simplifies the process of sending G-code instructions to your CNC machine.  It offers a user-friendly way to monitor the execution and troubleshoot any issues that may arise.

## Setup

1. **Install Dependencies:**
   Ensure you have `pyserial` installed.  You can install it using pip:
   ```bash
   pip install pyserial
   ```
   Alternatively, you can use the provided `requirements.txt` file:
   ```bash
   pip install -r requirements.txt
   ```

2. **Usage:**
   Create a new Python file (e.g., `g_code_controller.py`) and add your implementation using the `pyserial` library to interact with the CNC machine's serial port.  See the "Implementation Notes" section below for guidance.

## Features

* **G-code Reading and Execution:** Reads G-code files and transmits commands to the CNC machine over the serial port.
* **Progress Display:** Shows the progress of G-code execution in real-time.
* **Error Handling:** Displays any errors encountered during execution, facilitating troubleshooting.
* **G-code Display:**  Presents the contents of the G-code file for review.
* **Console Output:** Displays console output for detailed information.
* **CNC Control:**  Allows control of CNC parameters such as feed rate, spindle speed, etc. (Implementation details needed in source code).

## Implementation Notes (Placeholder - To be filled in your `g_code_controller.py`)

This section should be replaced with the actual code and further explanations on how to use the application.  Key implementation details to include:

* **Serial Port Configuration:** How to specify the correct serial port, baud rate, etc. for your CNC machine.  Example using `pyserial`:
    ```python
    import serial
    ser = serial.Serial('COM3', 115200) # Replace 'COM3' with your CNC's port
    ```
* **G-code Parsing:** How the application reads and parses the G-code file.
* **Command Sending:** How commands are sent to the CNC machine over the serial port.
* **Progress Tracking:** How the progress of G-code execution is tracked and displayed.
* **Error Handling:** How errors are caught and displayed.
* **CNC Control Implementation:** Detailed implementation of how feed rate, spindle speed, and other parameters are controlled.

## Example Usage (Placeholder -  To be added to `g_code_controller.py`)

```python
# Import necessary libraries
import serial

# ... (Your implementation here) ...

# Example of sending a G-code command
ser.write(b'G01 X10 Y20 F100\n')  # Example: Move to X10, Y20 at feed rate 100

# ... (Rest of your implementation) ...
```


This README provides a basic structure.  Remember to fill in the "Implementation Notes" and "Example Usage" sections with your actual code and detailed explanations for users to understand and use your `G_code_controller` application effectively.
