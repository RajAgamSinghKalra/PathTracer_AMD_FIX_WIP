#ifndef _LAMBERTIAN_GLSL
#define _LAMBERTIAN_GLSL 1

float bsdfLambertian(material mat, vec3 lightDirection, vec3 viewDirection) {
    return mat.albedo / PI;
}

#endif // _LAMBERTIAN_GLSL