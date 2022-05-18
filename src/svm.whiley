import u8,u32 from std::integer

public type SVM is {
   // Program couner identifies next instruction
   // to execute
   u32 pc,
   // Stack pointer identifies first unused space.
   u32 sp,
   // Code memory holds bytecodes to execute.
   u8[] code,
   // Data memory is an arbitrary scratch area.
   u32[] data,   
   // Stack is used for evaluating bytecodes.
   u32[] stack
} where sp <= |stack|

public final u8 NOP = 0x00
// Load constant onto the stack
public final u8 LDC = 0x01
// Pop item off stack
public final u8 POP = 0x02

public property executeNOP(SVM st) -> (SVM nst):
    st{pc:=st.pc+1}

public property executeLDC(SVM st, u32 k) -> (SVM nst):
    st{pc:=st.pc+1}{stack:=st.stack[st.sp:=k]}{sp:=st.sp+1}

public property execytePOP(SVM st) -> (SVM nst):
    st{pc:=st.pc+1}{sp:=st.sp-1}