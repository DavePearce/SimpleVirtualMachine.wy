import std::array
import svm with SVM

public property equiv(SVM m1, SVM m2) -> (bool r):
   // Data and stack pointer must match
   m1.data == m2.data && m1.sp == m2.sp &&
   // Stack upto stack pointer must match
   array::equals(m1.stack,m2.stack,0,m1.sp)

public method test():
   SVM m1 = svm::create([0],1024,1024)
   //
   SVM m2 = svm::executeLDC(m1,1)
   m2 = svm::executePOP(m2)
   //
   assert equiv(m1,m2)
   