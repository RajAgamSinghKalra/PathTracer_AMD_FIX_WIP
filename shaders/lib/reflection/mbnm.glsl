#ifndef _MBNM_GLSL
#define _MBNM_GLSL 1

#include "/lib/reflection/heitz.glsl"

float mbnm_projectedArea_p(material m, vec3 wi) {
    return max(0.0, dot(wi, m.normal)) / max(0.0, m.normal.z);
}

float mbnm_projectedArea_t(material m, vec3 wi, vec3 wt) {
    return max(0.0, dot(wi, wt)) * sqrt(1.0 - m.normal.z * m.normal.z) / max(0.0, m.normal.z);
}

float mbnm_lambda_p(material m, vec3 wi, vec3 wt) {
    float ap = mbnm_projectedArea_p(m, wi);
    return ap / (ap + mbnm_projectedArea_t(m, wi, wt));
}

float mbnm_lambda_t(material m, vec3 wi, vec3 wt) {
    float at = mbnm_projectedArea_t(m, wi, wt);
    return at / (at + mbnm_projectedArea_p(m, wi));
}

float mbnm_G1(material m, vec3 wi, vec3 wt, vec3 wm) {
    if (dot(wi, wm) < 0.0) return 0.0;
    return min(1.0, max(0.0, wi.z) / (mbnm_projectedArea_p(m, wi) + mbnm_projectedArea_t(m, wi, wt)));
}

float evalMicrosurfaceBSDF_MBN(material m, vec3 wi, vec3 wo) {
    if (abs(m.normal.x) + abs(m.normal.y) < 1.0e-5) {
        return evalMicrosurfaceBSDF(m, wi, wo);
    }

    vec3 wt = normalize(-vec3(m.normal.xy, 0.0));
    bool wp_first = random1() < mbnm_lambda_p(m, wi, wt);
    vec3 wm = wp_first ? m.normal : wt;
    vec3 wr = -wi;
    
    vec3 b1, b2;
    buildOrthonormalBasis(wt, b1, b2);
    mat3 wtToLocal = mat3(b1, b2, wt);

    buildOrthonormalBasis(m.normal, b1, b2);
    mat3 wpToLocal = mat3(b1, b2, m.normal);

    mat3 wmToLocal = wp_first ? wpToLocal : wtToLocal;

    int wpType = m.type;
    vec2 wpIOR = m.ior;

    float sum = 0.0;
    float throughput = 1.0;
    for (int i = 0; i < 256; i++) {
        vec3 wm_wr = wr * wmToLocal;
        vec3 wm_wo = wo * wmToLocal;

        float phase = evalMicrosurfaceBSDF(m, -wm_wr, wm_wo);
        float shadowing = mbnm_G1(m, wo, wt, wm);
        float I = phase * shadowing;

        if (!isinf(I)) {
            sum += throughput * I;
        }

        float weight;
        if (!sampleMicrosurfaceBSDF(m, -wm_wr, wm_wr, weight)) {
            break;
        }
        wr = wmToLocal * wm_wr;
        throughput *= weight;

        if (random1() < mbnm_G1(m, wr, wt, wm)) {
            break;
        } else {
            wmToLocal = wm == wt ? wpToLocal : wtToLocal;
            wm = wm == wt ? m.normal : wt;
        }
    }

    return sum;
}

bool sampleMicrosurfaceBSDF_MBN(material m, vec3 wi, out vec3 wo, out float throughput) {
    if (abs(m.normal.x) + abs(m.normal.y) < 1.0e-5) {
        return sampleMicrosurfaceBSDF(m, wi, wo, throughput);
    }

    vec3 wt = normalize(-vec3(m.normal.xy, 0.0));
    bool wp_first = random1() < mbnm_lambda_p(m, wi, wt);
    vec3 wm = wp_first ? m.normal : wt;
    vec3 wr = -wi;
    
    vec3 b1, b2;
    buildOrthonormalBasis(wt, b1, b2);
    mat3 wtToLocal = mat3(b1, b2, wt);

    buildOrthonormalBasis(m.normal, b1, b2);
    mat3 wpToLocal = mat3(b1, b2, m.normal);

    mat3 wmToLocal = wp_first ? wpToLocal : wtToLocal;

    int wpType = m.type;
    vec2 wpIOR = m.ior;

    throughput = 1.0;
    for (int i = 0; i <= 256; i++) {
        float weight;
        vec3 wm_wr = wr * wmToLocal;
        if (!sampleMicrosurfaceBSDF(m, -wm_wr, wm_wr, weight)) {
            return false;
        }
        wr = wmToLocal * wm_wr;
        throughput *= weight;

        if (random1() < mbnm_G1(m, wr, wt, wm)) {
            wo = wr;
            return true;
        } else {
            wmToLocal = wm == wt ? wpToLocal : wtToLocal;
            wm = wm == wt ? m.normal : wt;
        }
    }

    return false;
}

float evalMicrosurfacePDF_MBN(material m, vec3 wi, vec3 wo) {
    if (abs(m.normal.x) + abs(m.normal.y) < 1.0e-5) {
        return evalMicrosurfacePDF(m, wi, wo);
    }

    vec3 wt = normalize(-vec3(m.normal.xy, 0.0));
    float p_wp = mbnm_lambda_p(m, wi, wt);

    float pdf = 0.0;
    if (p_wp > 0.0) {
        vec3 w1, w2;
        buildOrthonormalBasis(m.normal, w1, w2);
        mat3 wpToLocal = mat3(w1, w2, m.normal);
        pdf += p_wp * evalMicrosurfacePDF(m, wi * wpToLocal, wo * wpToLocal);
    }
    if (p_wp < 1.0) {
        vec3 w1, w2;
        buildOrthonormalBasis(wt, w1, w2);
        mat3 wtToLocal = mat3(w1, w2, wt);
        pdf += (1.0 - p_wp) * evalMicrosurfacePDF(m, wi * wtToLocal, wo * wtToLocal);
    }

    pdf *= mbnm_G1(m, wo, wt, m.normal);
    return pdf + wo.z / PI;
}

#endif // _MBNM_GLSL