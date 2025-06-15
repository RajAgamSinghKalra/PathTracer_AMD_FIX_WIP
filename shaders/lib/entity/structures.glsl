#ifndef _ENTITY_STRUCTURES_GLSL
#define _ENTITY_STRUCTURES_GLSL 1

struct texture_key {
    vec4 mipTexel;
    ivec2 resolution;
    int entityId;
};

struct entity_texture {
    int index;
    ivec2 position;
    uint hash;
    texture_key key;
    int next;
};

struct texture_cell {
    ivec2 localPosition;
    int index;
};

struct entity_data {
    uint textureIndex;
    uint cellIndex;
    int hashTable[1024];
    uint tableLock[1024];
    entity_texture textures[4096];
    texture_cell subdividedCells[256];
};

#endif // _ENTITY_STRUCTURES_GLSL