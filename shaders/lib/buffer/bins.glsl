#ifndef _BINS_GLSL
#define _BINS_GLSL 1

struct bin_data {
    int x0;
    int y0;
    int x1;
    int y1;
};

layout (std430, binding = 2) buffer bin_buffer {
    int numBins;
    bin_data bins[1024];
    int binIndexes[];
} binBuffer;

#endif // _BINS_GLSL