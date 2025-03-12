#ifndef _LAMBERTIAN_GLSL
#define _LAMBERTIAN_GLSL 1

bsdf_value bsdfLambertian(material mat, vec3 lightDirection, vec3 viewDirection) {
    if (dot(lightDirection, mat.normal) < 0.0) {
        return bsdf_value(0.0, 0.0);
    }
    return bsdf_value(mat.albedo / PI, 0.0);
}

#endif // _LAMBERTIAN_GLSL