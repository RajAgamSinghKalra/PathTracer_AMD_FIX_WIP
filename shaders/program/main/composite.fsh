#include "/lib/buffer/state.glsl"
#include "/lib/camera/exposure.glsl"
#include "/lib/camera/film.glsl"
#include "/lib/debug/debug_text.glsl"
#include "/lib/post/tonemap.glsl"
#include "/lib/utility/color.glsl"
#include "/lib/utility/time.glsl"
#include "/lib/settings.glsl"

in vec2 texcoord;

uniform float frameTimeSmooth;
uniform float viewWidth;
uniform float viewHeight;
// The preview mode doesn't always provide valid viewport uniforms.
// Query the film texture size instead.

/* RENDERTARGETS: 0 */
layout(location = 0) out vec3 color;

void main() {
    ivec2 dim = textureSize(filmSampler, 0);
    float width = float(dim.x);
    float height = float(dim.y);
    float filmAspect = width / height;
    float screenAspect = filmAspect;
    if (viewWidth > 0.0 && viewHeight > 0.0) {
        screenAspect = viewWidth / viewHeight;
    }

    // Map screen texcoords to the film aspect without stretching.
    vec2 filmCoord = texcoord;
    float aspectScale = filmAspect / screenAspect;
    if (aspectScale < 1.0) {
        filmCoord.x = (filmCoord.x - 0.5) * aspectScale + 0.5;
    } else {
        filmCoord.y = (filmCoord.y - 0.5) / aspectScale + 0.5;
    }
    bool outside = filmCoord.x < 0.0 || filmCoord.x > 1.0 ||
                   filmCoord.y < 0.0 || filmCoord.y > 1.0;
    filmCoord = clamp(filmCoord, vec2(0.0), vec2(1.0));
    filmCoord = filmCoord * 2.0 - 1.0;
    color = outside ? vec3(0.0) : getFilmAverageColor(filmCoord);
#ifdef NEIGHBOURHOOD_CLAMPING
    vec3 maxNeighbour = max(
        max(getFilmAverageColor(filmCoord, ivec2(1, 0)).rgb, getFilmAverageColor(filmCoord, ivec2(-1, 0)).rgb),
        max(getFilmAverageColor(filmCoord, ivec2(0, 1)).rgb, getFilmAverageColor(filmCoord, ivec2(0, -1)).rgb)
    );
    color = min(color, maxNeighbour);
#endif

    color = max(XYZ_TO_sRGB * color, 0.0);

    float ev100 = 0.0;
#if (EXPOSURE == 0)
    ev100 = averageLuminanceToEV100(renderState.avgLuminance);
#elif (EXPOSURE == 1)
    ev100 = cameraSettingsToEV100(float(SHUTTER_SPEED), float(ISO), renderState.fNumber);
#endif

    // Prevent excessive exposure gain in very dark scenes by clamping
    // the calculated exposure value to a minimum of 0 EV. This keeps
    // nighttime renders from being artificially bright and overexposed.
    ev100 = max(ev100, 0.0);

    color *= exposureFromEV100(ev100 - float(EV));

    color = tonemap(color);
    color = linearToSrgb(color);

    ivec2 time = ivec2(currentDate.x, currentYearTime.x);
    renderTextOverlay(color, ivec2(gl_FragCoord.xy) / 2, ivec2(1.0, height * 0.5 - 1.0), time, frameTimeSmooth);
}
