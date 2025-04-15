#ifndef _COMPLEX_MAT2_GLSL
#define _COMPLEX_MAT2_GLSL 1

#include "/lib/complex/float.glsl"

struct complexMat2 {
    complexFloat m00, m01;
    complexFloat m10, m11;
};

complexMat2 complexMul(complexMat2 x, complexMat2 y) {
    return complexMat2(
        complexAdd(complexMul(x.m00, y.m00), complexMul(x.m10, y.m01)), complexAdd(complexMul(x.m01, y.m00), complexMul(x.m11, y.m01)),
        complexAdd(complexMul(x.m00, y.m10), complexMul(x.m10, y.m11)), complexAdd(complexMul(x.m01, y.m10), complexMul(x.m11, y.m11))
    );
}

#endif // _COMPLEX_MAT2_GLSL