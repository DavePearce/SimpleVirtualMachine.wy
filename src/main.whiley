import std::array
import u8,u16 from std::int

import svm with SVM
import OK from svm
import DIV,LDC,LOAD,POP,ADD,NOP from svm

// Return true if both the data and stack match.
public property equiv(SVM m1, SVM m2) -> (bool r):
   return m1.data == m2.data && m1.sp == m2.sp &&
          array::equals(m1.stack,m2.stack,0,m1.sp)

public method test_add_01():
    SVM m1 = svm::execute([LDC,2,LDC,1,ADD],[],1024)
    // Check expected output.
    assert svm::haltCode(m1) == OK    
    assert svm::peek(m1,1) == 3

public method test_add_02(u16 val)
requires val < 65535:
    SVM m1 = svm::execute([LOAD,0,LDC,1,ADD],[val],1024)
    // Check expected output.
    assert svm::haltCode(m1) == OK    
    assert svm::peek(m1,1) > val
