import u8,u16 from std::int

// ==============================================================
// Simple Virtual Machine State
// ==============================================================

public type SVM is {
   // Program couner identifies next instruction
   // to execute
   u16 pc,
   // Stack pointer identifies first unused space.
   u16 sp,
   // Code memory holds bytecodes to execute.
   u8[] code,
   // Data memory is an arbitrary scratch area.
   u16[] data,   
   // Stack is used for evaluating bytecodes.
   u16[] stack
}
// Limit stack pointer and stack size
where sp <= |stack| && |stack| < 65536 
// Limit program counter and code size
where pc <= |code| && |code| < 65536

public property create(u8[] code, u16 datasize, u16 stacksize) -> (SVM r):
   return {pc:0, sp:0, code: code, data: [0; datasize], stack: [0; stacksize]}

public property isHalted(SVM st) -> (bool r):
    return st.pc >= |st.code|

// ==============================================================
// Simple Virtual Machine Opcodes
// ==============================================================

public final u8 NOP = 0x00
// Load constant onto stack
public final u8 LDC = 0x01
// Pop item off stack
public final u8 POP = 0x02
// Store top of stack to data
public final u8 STORE = 0x03
// Load data to stack
public final u8 LOAD = 0x04
// Add operands on stack
public final u8 ADD = 0x05
// Subtract operands on stack
public final u8 SUB = 0x06
// Multiply operands on stack
public final u8 MUL = 0x07
// Divide operands on stack
public final u8 DIV = 0x08

// ...

// Unconditional (Relative) branch
public final u8 JMP = 0x10
public final u8 JZ = 0x11

// ==============================================================
// Simple Virtual Machine Semantics
// ==============================================================

// Keep executing the current program until the machine halts.
public property execute(SVM st) -> (SVM res):
   if isHalted(st):
       return st
   else:
       return execute(eval(st))      

// Execute a "single step" of the current program.
public property eval(SVM st) -> (SVM res)
requires !isHalted(st):
   u8 opcode = st.code[st.pc]
   // increment pc
   SVM nst = st{pc:=st.pc+1}
   // Decode opcode
   if opcode == NOP:
      return evalNOP(nst)
   else if opcode == LDC && !isHalted(nst):
      u8 k = nst.code[nst.pc]
      return evalLDC(nst{pc:=nst.pc+1},k)
   else if opcode == POP:
      return evalPOP(nst)
   else if opcode == STORE && !isHalted(nst):
      u8 k = nst.code[nst.pc]   
      return evalSTORE(nst{pc:=nst.pc+1},k)
   else if opcode == LOAD && !isHalted(nst):
      u8 k = nst.code[nst.pc]   
      return evalLOAD(nst{pc:=nst.pc+1},k)
   else if opcode == ADD:
      return evalADD(nst)
   else if opcode == SUB:
      return evalSUB(nst)
   else if opcode == MUL:
      return evalMUL(nst)
   else if opcode == DIV:
      return evalDIV(nst)
   else if opcode == JMP && !isHalted(nst):
      u8 k = nst.code[nst.pc]
      return evalJMP(nst{pc:=nst.pc+1},k)
   else:
      // Force machine to halt
      return halt(nst)

// ... l r => (l+r)
public property evalADD(SVM st) -> (SVM nst):
    if st.sp >= 2:
        // Read operands
        u16 r = peek(st,1)
        u16 l = peek(st,2)
        u16 v = (l + r) % 0xFFFF
        // done
        return push(pop(pop(st)),v)
    else:
        return halt(st)

// ... l r => (l-r)
public property evalSUB(SVM st) -> (SVM nst):
    if st.sp >= 2:
        // Read operands
        u16 r = peek(st,1)
        u16 l = peek(st,2)
        u16 v = (l - r) % 0xFFFF
        // done
        return push(pop(pop(st)),v)
    else:
        return halt(st)

// ... l r => (l*r)
public property evalMUL(SVM st) -> (SVM nst):
    if st.sp >= 2:
        // Read operands
        u16 r = peek(st,1)
        u16 l = peek(st,2)
        u16 v = (l * r) % 0xFFFF
        // done
        return push(pop(pop(st)),v)
    else:
        return halt(st)

// ... l r => (l/r) if r != 0
public property evalDIV(SVM st) -> (SVM nst):
    if st.sp >= 2 && peek(st,1) != 0:
        // Read operands
        u16 r = peek(st,1)
        u16 l = peek(st,2)
        u16 v = l / r
        // done
        return push(pop(pop(st)),v)
    else:
        return halt(st)

// pc = 2 + k
public property evalJMP(SVM st, u8 k) -> (SVM nst):
   if (st.pc+k) < |st.code|:    
       return st{pc:=st.pc+k}
   else:
       return halt(st)

public property evalNOP(SVM st) -> (SVM nst):
    return st

public property evalLDC(SVM st, u8 k) -> (SVM nst):
    // Sanity check requirements
    if st.sp < |st.stack|:
        return push(st, (u16) k)
    else:
        return halt(st)

public property evalPOP(SVM st) -> (SVM nst):
    if st.sp >= 1:
        return pop(st)
    else:
        return halt(st)

public property evalSTORE(SVM st, u8 k) -> (SVM nst):
    // sanity check requirements
    if st.sp >= 1 && k < |st.data|:
        // Read top of stack
        u16 v = peek(st,1)
        // Assign to data and pop stack
        return pop(store(st,k,v))
    else:
        return halt(st)

public property evalLOAD(SVM st, u8 k) -> (SVM nst):
    // Sanity check requirements
    if st.sp < |st.stack| && k < |st.data|:
        // Read value from data
        u16 v = read(st,k)
        // Push data to stack
        return push(st,v)
    else:
        return halt(st)

// ==============================================================
// Microcode Instructions
// ==============================================================

public property push(SVM st, u16 k) -> SVM
requires st.sp < |st.stack|:
    return st{stack:=st.stack[st.sp:=k]}{sp:=st.sp+1}

public property peek(SVM st, int n) -> u16
requires st.sp < |st.stack|
requires 0 < n && n <= st.sp:
    return st.stack[st.sp - n]

public property pop(SVM st) -> SVM
requires st.sp > 0:
   return st{sp:=st.sp-1}

public property read(SVM st, u8 address) -> u16
requires address < |st.data|:
   return st.data[address]

public property store(SVM st, u8 address, u16 value) -> SVM
requires address < |st.data|:
   return st{data:=st.data[address:=value]}

public property halt(SVM st) -> SVM:
   return st{pc:=|st.code|}