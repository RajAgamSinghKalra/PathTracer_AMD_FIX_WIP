// https://www.alextardif.com/HistogramLuminance.html
// https://bruop.github.io/exposure/

#include "/lib/buffer/state.glsl"
#include "/lib/camera/exposure.glsl"
#include "/lib/camera/film.glsl"
#include "/lib/utility/color.glsl"

layout (local_size_x = 16, local_size_y = 16, local_size_z = 1) in;
const vec2 workGroupsRender = vec2(1.0, 1.0);

uniform float viewWidth;
uniform float viewHeight;

shared uint histogramShared[256];

uint colorToBin(vec3 color_xyz) {
    float lum = color_xyz.y;
    if (lum < 0.001) {
        return 0u;
    }

    float logLum = toLogLuminance(lum);
    return uint(logLum * 254.0 + 1.0);
}

void main() {
    histogramShared[gl_LocalInvocationIndex] = 0u;
    barrier();

    if (renderState.frame == 0) {
        return;
    }

    uvec2 dim = uvec2(viewWidth, viewHeight);
    if (gl_GlobalInvocationID.x < dim.x && gl_GlobalInvocationID.y < dim.y) {
        vec3 color = getFilmAverageColor(ivec2(gl_GlobalInvocationID.xy));
        uint binIndex = colorToBin(color);
        atomicAdd(histogramShared[binIndex], 1u);
    }

    barrier();

    atomicAdd(renderState.histogram[gl_LocalInvocationIndex], histogramShared[gl_LocalInvocationIndex]);
}