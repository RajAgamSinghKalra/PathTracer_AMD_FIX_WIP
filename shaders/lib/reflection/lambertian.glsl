#ifndef _LAMBERTIAN_GLSL
#define _LAMBERTIAN_GLSL 1

bsdf_value bsdfLambertian(material mat, vec3 lightDirection, vec3 viewDirection) {
    return bsdf_value(mat.albedo / PI, 0.0);
}

#endif // _LAMBERTIAN_GLSL