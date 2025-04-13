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
    printString((_A, _R, _space, _C, _o, _a, _t, _i, _n, _g, _colon, _space));

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

    printInt(coatedElements);
    printChar(_slash);
    printInt(totalElements);

    printChar(_space);
    printInt(int(getLensCoatingThickness()));
    printString((_n, _m, _space));

    if (AR_COATING_MATERIAL == MgF2) {
        printString((_M, _g, _F, _2));
    }

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
    seconds -= minutes * 60;

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

void renderDebugText(inout vec3 color, ivec2 resolution, ivec2 position, ivec2 time) {
    beginText(resolution, position);

    printLensType();
    printCameraSettings();
    printCoatingInfo();
    printRenderTime(time);

	endText(color);
}

#endif // _DEBUG_TEXT_GLSL