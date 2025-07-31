// https://www.alextardif.com/HistogramLuminance.html
// https://bruop.github.io/exposure/

#include "/lib/buffer/state.glsl"
#include "/lib/camera/exposure.glsl"
#include "/lib/camera/film.glsl"
#include "/lib/utility/color.glsl"

layout (local_size_x = 256, local_size_y = 1, local_size_z = 1) in;
const ivec3 workGroups = ivec3(1, 1, 1);

uniform float viewWidth;
uniform float viewHeight;

// The preview stage may not populate viewport uniforms. Use the film buffer
// dimensions if the viewport values are invalid when computing statistics.

shared uint histogramShared[256];

void main() {
    uint count = renderState.histogram[gl_LocalInvocationIndex];
    histogramShared[gl_LocalInvocationIndex] = count * gl_LocalInvocationIndex;

    barrier();

    renderState.histogram[gl_LocalInvocationIndex] = 0u;

    if (renderState.frame == 0) {
        if (gl_LocalInvocationIndex == 0u) {
            renderState.avgLuminance = 12.0;
        }
        return;
    }

    for (uint cutoff = 128; cutoff > 0; cutoff >>= 1) {
        if (gl_LocalInvocationIndex < cutoff) {
            uint value = histogramShared[gl_LocalInvocationIndex + cutoff];
            histogramShared[gl_LocalInvocationIndex] += value;
        }

        barrier();
    }

    if (gl_LocalInvocationIndex == 0u) {
        float width = viewWidth;
        float height = viewHeight;
        if (width <= 0.0 || height <= 0.0) {
            ivec2 dim = imageSize(filmBuffer);
            width = float(dim.x);
            height = float(dim.y);
        }
        float logAverage = (float(histogramShared[0]) / max(width * height - float(count), 1.0)) - 1.0;
        float avgLum = fromLogLuminance(logAverage / 254.0);

        renderState.avgLuminance = avgLum;
    }
}
