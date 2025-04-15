#ifndef _COMPLEX_FLOAT_GLSL
#define _COMPLEX_FLOAT_GLSL 1

#include "/lib/utility/constants.glsl"

#define complexFloat vec2

float complexAbs(complexFloat a) {
    return length(a);
}

float complexNorm(complexFloat a) {
    return dot(a, a);
}

complexFloat complexAdd(complexFloat a, complexFloat b) {
    return a + b;
}

complexFloat complexSub(complexFloat a, complexFloat b) {
    return a - b;
}

complexFloat complexMul(complexFloat a, complexFloat b) {
    return complexFloat(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x);
}

complexFloat complexDiv(complexFloat a, complexFloat b) {
    return complexFloat(a.x * b.x + a.y * b.y, a.y * b.x - a.x * b.y) / complexNorm(b);
}

complexFloat complexSqrt(complexFloat a) {
    float m = complexAbs(a);
    return complexFloat(sqrt((m + a.x) * 0.5), sign(a.y) * sqrt((m - a.x) * 0.5));
}

complexFloat complexExp(complexFloat a) {
    return complexMul(complexFloat(exp(a.x), 0.0), complexFloat(cos(a.y), sin(a.y)));
}

complexFloat complexSin(complexFloat a) {
    complexFloat e1 = complexExp(complexFloat(a.y, -a.x));
    complexFloat e2 = complexExp(complexFloat(-a.y, a.x));
    return complexMul(complexFloat(0.0, 0.5), complexSub(e1, e2));
}

complexFloat complexCos(complexFloat a) {
    complexFloat e1 = complexExp(complexFloat(-a.y, a.x));
    complexFloat e2 = complexExp(complexFloat(a.y, -a.x));
    return complexMul(complexFloat(0.5, 0.0), complexAdd(e1, e2));
}

float complexArg(complexFloat a) {
    return atan(a.y, a.x);
}

complexFloat complexLog(complexFloat a) {
    return complexFloat(log(complexAbs(a)), complexArg(a));
}

complexFloat complexArcsin(complexFloat a) {
    complexFloat b = complexMul(complexFloat(0.0, 1.0), a);
    complexFloat c = complexSqrt(complexSub(complexFloat(1.0, 0.0), complexMul(a, a)));
    return complexMul(complexFloat(0.0, -1.0), complexLog(complexAdd(b, c)));
}

complexFloat complexArccos(complexFloat a) {
    return complexSub(complexFloat(PI / 2.0, 0.0), complexArcsin(a));
}

#endif // _COMPLEX_FLOAT_GLSL