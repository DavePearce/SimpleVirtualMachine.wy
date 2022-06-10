import std::array
import svm with SVM
import LDC,POP,ADD,NOP from svm

// Return true if both the data and stack match.
public property equiv(SVM m1, SVM m2) -> (bool r):
   return m1.data == m2.data && m1.sp == m2.sp &&
          array::equals(m1.stack,m2.stack,0,m1.sp)

public method test():
    SVM m1 = svm::create([LDC,1,LDC,2,ADD,NOP],1024,1024)    
    //    
    m1 = svm::execute(m1)
    m1 = svm::execute(m1)
    assert m1.pc == 4
    assert m1.sp > 2
    m1 = svm::execute(m1)
    //
    assert !svm::isHalted(m1)
    assert svm::peek(m1,1) == 3
