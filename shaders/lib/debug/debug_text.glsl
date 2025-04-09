#ifndef _DEBUG_TEXT_GLSL
#define _DEBUG_TEXT_GLSL 1

#include "/lib/buffer/state.glsl"
#include "/lib/debug/text_renderer.glsl"
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
	printFloat(renderState.fNumber);
	printLine();
}

void renderDebugText(inout vec3 color, ivec2 resolution, ivec2 position) {
    beginText(resolution, position);

    printLensType();
    printCameraSettings();

	endText(color);
}

#endif // _DEBUG_TEXT_GLSL