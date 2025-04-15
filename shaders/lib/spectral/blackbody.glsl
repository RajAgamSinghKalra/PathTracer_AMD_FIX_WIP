#ifndef _BLACKBODY_GLSL
#define _BLACKBODY_GLSL 1

float blackbody(float lambda, float T) {
    float l = lambda * 1.0e-9;
    float l2 = l * l;
    
    const float c = 299792458.0;
    const float h = 6.62606957e-34;
    const float k = 1.3806488e-23;
    return (2.0 * h * c * c) / ((l2 * l2 * l) * (exp((h * c) / (l * k * T)) - 1.0));
}

float blackbodyScaled(int lambda, int T) {
    float p = blackbody(float(lambda), float(T));
    float radiated = 5.670374419e-8 * float(T * T) * float(T * T);
    return 15.0 * p / radiated;
}

#endif // _BLACKBODY_GLSL