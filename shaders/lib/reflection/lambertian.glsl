#ifndef _LAMBERTIAN_GLSL
#define _LAMBERTIAN_GLSL 1

bsdf_value bsdfLambertian(material mat) {
    return bsdf_value(mat.albedo / PI, vec3(0.0));
}

#endif // _LAMBERTIAN_GLSL