# Per-op Inputs and Expected Results

Using the worked examples from the assignment and extending for all operations.  
Each operation is tested with specific inputs, and the expected output is computed.

---

### **ANDN**
- **Inputs:**  
  `rs1 = 0xF0F0A5A5`, `rs2 = 0x0F0FFFFF`  
- **Operation:**  
  `rs1 & ~rs2`  
- **Expected:**  
  `0xF0F00000`

---

### **ORN**
- **Inputs:**  
  `rs1 = 0xF0F0A5A5`, `rs2 = 0x0F0FFFFF`  
- **Operation:**  
  `rs1 | ~rs2`  
- **Expected:**  
  `0xF0F0A5A5 | 0xF0F00000 = 0xF0F0A5A5`

---

### **XNOR**
- **Inputs:**  
  `rs1 = 0xF0F0A5A5`, `rs2 = 0x0F0FFFFF`  
- **Operation:**  
  `~(rs1 ^ rs2)`  
- **Expected:**  
  `0x0F0F5A5A`

---

### **MINU (Unsigned Minimum)**
- **Inputs:**  
  `rs1 = 0xFFFFFFFE`, `rs2 = 0x00000001`  
- **Expected:**  
  `0x00000001`

---

### **MIN (Signed Minimum)**
- **Inputs:**  
  `rs1 = 0xFFFFFFFE (-2)`, `rs2 = 0x00000001 (1)`  
- **Expected:**  
  `0xFFFFFFFE`

---

### **MAX (Signed Maximum)**
- **Inputs:**  
  `rs1 = 0xFFFFFFFE (-2)`, `rs2 = 0x00000001 (1)`  
- **Expected:**  
  `0x00000001`

---

### **MAXU (Unsigned Maximum)**
- **Inputs:**  
  `rs1 = 0xFFFFFFFE`, `rs2 = 0x00000001`  
- **Expected:**  
  `0xFFFFFFFE`

---

### **ROL (Rotate Left)**
- **Inputs:**  
  `rs1 = 0x80000001`, `rs2 = 3`  
- **Expected:**  
  `0x0000000B`

---

### **ROR (Rotate Right)**
- **Inputs:**  
  `rs1 = 0x80000001`, `rs2 = 3`  
- **Expected:**  
  `0x30000000`

---

### **ABS (Absolute Value)**
- **Inputs:**  
  `rs1 = 0xFFFFFF80 (-128)`  
- **Expected:**  
  `0x00000080`

---

### **Additional Test — ABS(INT_MIN)**
- **Inputs:**  
  `rs1 = 0x80000000`  
- **Expected:**  
  `0x80000000`

---

### **Rotate by 0**
- **Inputs:**  
  `ROL rs1 = 0x12345678`, `rs2 = 0`  
- **Expected:**  
  `0x12345678`

---

### **Writes to x0 Ignored**
- **Instruction:**  
  `ANDN x0, x1, x2`  
- **Expected:**  
  `x0 remains 0`



