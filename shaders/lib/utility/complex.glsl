#ifndef _COMPLEX_GLSL
#define _COMPLEX_GLSL 1

#define complex vec2

float complexAbs(complex a) {
    return length(a);
}
float complexAbs2(complex a) {
    return dot(a, a);
}

complex complexAdd(complex a, complex b) {
    return a + b;
}
complex complexAdd(complex a, float b) {
    return complexAdd(a, complex(b, 0.0));
}
complex complexAdd(float a, complex b) {
    return complexAdd(complex(a, 0.0), b);
}

complex complexSub(complex a, complex b) {
    return a - b;
}
complex complexSub(complex a, float b) {
    return complexSub(a, complex(b, 0.0));
}
complex complexSub(float a, complex b) {
    return complexSub(complex(a, 0.0), b);
}

complex complexMul(complex a, complex b) {
    return complex(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x);
}
complex complexMul(complex a, float b) {
    return complexMul(a, complex(b, 0.0));
}
complex complexMul(float a, complex b) {
    return complexMul(complex(a, 0.0), b);
}

complex complexDiv(complex a, complex b) {
    return complex(a.x * b.x + a.y * b.y, a.y * b.x - a.x * b.y) / complexAbs2(b);
}
complex complexDiv(complex a, float b) {
    return complexDiv(a, complex(b, 0.0));
}
complex complexDiv(float a, complex b) {
    return complexDiv(complex(a, 0.0), b);
}

complex complexSqrt(complex a) {
    float m = complexAbs(a);
    return complex(sqrt((m + a.x) * 0.5), sign(a.y) * sqrt((m - a.x) * 0.5));
}

#endif // _COMPLEX_GLSL