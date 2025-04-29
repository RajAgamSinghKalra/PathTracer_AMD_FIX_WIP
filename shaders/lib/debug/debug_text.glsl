#ifndef _DEBUG_TEXT_GLSL
#define _DEBUG_TEXT_GLSL 1

#include "/lib/buffer/state.glsl"
#include "/lib/debug/text_renderer.glsl"
#include "/lib/lens/configuration.glsl"
#include "/lib/lens/reflection.glsl"
#include "/lib/settings.glsl"

void printLensType() {
#if (LENS_TYPE == 0)
    printString((_L, _e, _n, _s, _colon, _space, _D, _o, _u, _b, _l, _e, _space, _G, _a, _u, _s, _s));
    printLine();
#elif (LENS_TYPE == 1)
    printString((_L, _e, _n, _s, _colon, _space, _F, _i, _s, _h, _e, _y, _e));
    printLine();
#elif (LENS_TYPE == 2)
    printString((_L, _e, _n, _s, _colon, _space, _T, _e, _s, _s, _a, _r));
    printLine();
#elif (LENS_TYPE == 3)
    printString((_L, _e, _n, _s, _colon, _space, _C, _o, _o, _k, _e, _space, _T, _r, _i, _p, _l, _e, _t));
    printLine();
#elif (LENS_TYPE == 4)
    printString((_L, _e, _n, _s, _colon, _space, _P, _e, _t, _z, _v, _a, _l));
    printLine();
#endif
}

void printCameraSettings() {
    printString((_S, _h, _u, _t, _t, _e, _r, _space, _s, _p, _e, _e, _d, _colon, _space,  _1, _slash));
    printInt(int(SHUTTER_SPEED));
    printChar(_s);
    printLine();

    printString((_I, _S, _O, _space));
    printInt(int(ISO));

    text.fpPrecision = 2;

    printString((_space, _space, _f, _slash));
    printFloat(round(renderState.fNumber * 100.0) / 100.0);
    printLine();
}

void printCoatingInfo() {
    printString((_A, _R, _space, _C, _o, _a, _t, _i, _n, _g, _space, _l, _a, _y, _e, _r, _s, _colon));
    printLine();

    text.fpPrecision = 2;

    for (int i = 0; i < COATING_LAYERS.length(); i++) {
        coating_layer layer = COATING_LAYERS[i];
        printString((_minus, _space));

        if (layer.material == MgF2) {
            printString((_M, _g, _F, _2));
        } else if (layer.material == SiO2) {
            printString((_S, _i, _O, _2));
        } else if (layer.material == Al2O3) {
            printString((_A, _l, _2, _O, _3));
        } else if (layer.material == ZrO2) {
            printString((_Z, _r, _O, _2));
        }

        printChar(_space);
        printFloat(getLensCoatingThickness(layer.material, layer.wavelength, layer.tDenom));
        printString((_n, _m, _space, _opprn, _lambda, _slash));
        printInt(int(layer.tDenom));
        printString((_comma, _space, _lambda, _equal));
        printInt(int(layer.wavelength));
        printChar(_clprn);
        printLine();
    }

    int coatedElements = 0;
    int totalElements = 0;
    for (int i = 0; i < LENS_ELEMENTS.length(); i++) {
        if (LENS_ELEMENTS[i].curvature == 0.0) {
            continue;
        }
        if (LENS_ELEMENTS[i].coated && (i == 0 || LENS_ELEMENTS[i].glass == AIR || LENS_ELEMENTS[i - 1].glass == AIR)) {
            coatedElements++;
        }
        totalElements++;
    }

    printString((_C, _o, _a, _t, _e, _d, _space, _e, _l, _e, _m, _e, _n, _t, _s, _colon, _space));

    printInt(coatedElements);
    printChar(_slash);
    printInt(totalElements);

    printLine();
}

int getLeapYears(int year) {
    year--;
    return year / 4 - year / 100 + year / 400;
}

ivec3 getRenderTime(ivec2 time) {
    ivec2 startTime = renderState.startTime;
    int years = time.x - startTime.x;
    int leapYears = getLeapYears(time.x) - getLeapYears(startTime.x);
    int seconds = time.y - startTime.y;
    seconds += years * (365 * 24 * 60 * 60);
    seconds += leapYears * 24 * 60 * 60;

    int hours = seconds / 3600;
    int minutes = (seconds - hours * 3600) / 60;
    seconds -= (hours * 60 + minutes) * 60;

    return ivec3(hours, minutes, seconds);
}

void printRenderTime(ivec2 time) {
    ivec3 renderTime = getRenderTime(time);

    printString((_R, _e, _n, _d, _e, _r, _space, _T, _i, _m, _e, _colon, _space));

    for (int i = 0; i < 3; i++) {
        if (renderTime[i] < 10) {
            printChar(_0);
        }
        printInt(renderTime[i]);
        if (i != 2) {
            printChar(_colon);
        }
    }

    printLine();
}

void printSamples() {
    printString((_S, _a, _m, _p, _l, _e, _s, _colon, _space));
    printInt(renderState.frame);
    printLine();
}

void printFrameTime(float frameTime) {
    printString((_F, _r, _a, _m, _e, _space, _t, _i, _m, _e, _colon, _space));
    
    text.fpPrecision = 1;
    printFloat(frameTime * 1000.0);

    printLine();
}

void renderTextOverlay(inout vec3 color, ivec2 resolution, ivec2 position, ivec2 time, float frameTime) {
#if (DEBUG_INFO == 0)
    return;
#elif (DEBUG_INFO == 1)
    if (renderState.frame != 0) {
        return;
    }
#endif

    beginText(resolution, position);

    if (renderState.frame == 0) {
        printString((_P, _r, _e, _s, _s, _space, _F, _1, _space, _t, _o, _space, _b, _e, _g, _i, _n, _space, _r, _e, _n, _d, _e, _r, _i, _n, _g, _dot));
        printLine();
    }

    text.fgCol = vec4(1.0, 0.0, 0.0, 1.0);
    if (renderState.invalidSplat > 0) {
        printString((_I, _n, _v, _a, _l, _i, _d, _space, _S, _p, _l, _a, _t, _exclm));
        printLine();
    }
    text.fgCol = vec4(1.0);

#ifdef PRINT_LENS_TYPE
    printLensType();
#endif

#ifdef PRINT_CAMERA_SETTINGS
    printCameraSettings();
#endif

#ifdef PRINT_COATING_INFO
    printCoatingInfo();
#endif

#ifdef PRINT_RENDER_TIME
    if (time != renderState.startTime) {
        printRenderTime(time);
    }
#endif

#ifdef PRINT_SAMPLES
    if (renderState.frame != 0) {
        printSamples();
    }
#endif

#ifdef PRINT_FRAME_TIME
    printFrameTime(frameTime);
#endif

    endText(color);
}

#endif // _DEBUG_TEXT_GLSL