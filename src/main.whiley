import std::array
import svm with SVM
import LDC,POP from svm

// Return true if both the data and stack match.
public property equiv(SVM m1, SVM m2) -> (bool r):
   return m1.data == m2.data && m1.sp == m2.sp &&
          array::equals(m1.stack,m2.stack,0,m1.sp)

public method test():
    SVM m1 = svm::create([LDC,0,POP],1024,1024)    
    //    
    m1 = svm::execute(m1)
