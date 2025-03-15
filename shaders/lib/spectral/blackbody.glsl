#ifndef _BLACKBODY_GLSL
#define _BLACKBODY_GLSL 1

const float[] RADIATED_POWER = float[](1.0e7*1.82276e-11,1.0e7*0.0331853,1.0e7*50.7817,1.0e7*7150.02,1.0e7*55406.5,1.0e7*230310.0,1.0e7*664367.0,1.0e7*1.51427e6,1.0e7*2.93432e6,1.0e7*5.05655e6,1.0e7*7.98043e6,1.0e7*1.17707e7,1.0e7*1.64604e7,1.0e7*2.20563e7,1.0e7*2.85449e7,1.0e7*3.58984e7,1.0e7*4.40791e7,1.0e7*5.30438e7,1.0e7*6.27459e7,1.0e7*7.31383e7,1.0e7*8.41742e7,1.0e7*9.58084e7,1.0e7*1.07998e8,1.0e7*1.20702e8,1.0e7*1.33883e8,1.0e7*1.47506e8,1.0e7*1.61538e8,1.0e7*1.75949e8,1.0e7*1.90711e8,1.0e7*2.05799e8,1.0e7*2.2119e8,1.0e7*2.36862e8,1.0e7*2.52796e8);

float blackbody(float lambda, float T) {
    float l = lambda * 1.0e-9;
    float l2 = l * l;
    
    const float c = 299792458.0;
    const float h = 6.62606957e-34;
    const float k = 1.3806488e-23;
    return (2.0 * h * c * c) / ((l2 * l2 * l) * (exp((h * c) / (l * k * T)) - 1.0));
}

float blackbodyScaled(int lambda, int T) {
    if (T <= 0 || T > 16000) {
        return 0.0;
    }

    int index = T / 500;
    float t = float(T - index * 500) / 500.0;

    float radiated = mix(RADIATED_POWER[index], RADIATED_POWER[index + 1], t);

    float p = blackbody(float(lambda), float(T));
    return 150.0 * (p / radiated);
}

#endif // _BLACKBODY_GLSL