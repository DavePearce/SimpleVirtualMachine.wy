import std::array
import u8,u16 from std::int

import svm with SVM
import OK from svm
import DIV,JZ,LDC,LOAD,POP,ADD,NOP from svm

// Return true if both the data and stack match.
public property equiv(SVM m1, SVM m2) -> (bool r):
   return m1.data == m2.data && m1.sp == m2.sp &&
          array::equals(m1.stack,m2.stack,0,m1.sp)

public method test_add_01():
    SVM m1 = svm::execute([LDC,2,LDC,1,ADD],[],1024)
    // Check expected output.
    assert svm::exitCode(m1) == OK    
    assert svm::peek(m1,1) == 3

public method test_add_02(u16 x)
requires x < 65535:
    SVM m1 = svm::execute([LOAD,0,LDC,1,ADD],[x],1024)
    // Check expected output.
    assert svm::exitCode(m1) == OK    
    assert svm::peek(m1,1) > x

public method test_div_01(u16 x, u16 y):
    SVM m1 = svm::execute([LOAD,0,LOAD,1,DIV],[x,y],1024)
    // Check expected output.
    assert y == 0 || svm::exitCode(m1) == OK

public method test_div_02(u16 x, u16 y):
    SVM m1 = svm::execute([LOAD,0,LOAD,1,JZ,3,LOAD,1,DIV],[x,y],1024)
    // Check expected output.
    assert svm::exitCode(m1) == OK