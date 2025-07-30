#ifndef _PROJECTION_GLSL
#define _PROJECTION_GLSL 1

vec3 projectAndDivide(mat4 projectionMatrix, vec3 position){
    vec4 homogeneous = projectionMatrix * vec4(position, 1.0);
    return homogeneous.xyz / homogeneous.w;
}

#endif // _PROJECTION_GLSL
