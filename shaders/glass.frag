// This shader is based on a bunch of sources:
// - https://www.shadertoy.com/view/wccSDf for the refraction
// - https://iquilezles.org/articles/distfunctions2d/ for SDFs
// - Gracious help from @dkwingsmt for the Squircle SDF
// - https://github.com/whynotmake-it/flutter_liquid_glass Tim Lehmann for whynotmake.it
//
// Feel free to use this shader in your own projects, it'd be lovely if you could
// give some credit like I did here.

#include <flutter/runtime_effect.glsl>
precision highp float;

// Basic parameters
uniform vec2 u_resolution;
uniform sampler2D u_texture_input;

out vec4 frag_color;

// Convert pixel size to relative size (normalized by height)
float PX(float pixels) {
    return pixels / u_resolution.y;
}

// Shape generation functions
float sdfRRect(vec2 p, vec2 b, float r) {
    vec2 q = abs(p) - b + r;
    return min(max(q.x, q.y), 0.0) + length(max(q, 0.0)) - r;
}

// Calculate 3D normal using derivatives
vec3 getNormal(float sd, float thickness) {
    float dx = dFdx(sd);
    float dy = dFdy(sd);
    
    // The cosine and sine between normal and the xy plane
    float n_cos = max(thickness + sd, 0.0) / thickness;
    float n_sin = sqrt(max(0.0, 1.0 - n_cos * n_cos));
    
    return normalize(vec3(dx * n_cos, dy * n_cos, n_sin));
}

// Calculate height/depth of the liquid surface
float getHeight(float sd, float thickness) {
    if (sd >= 0.0 || thickness <= 0.0) {
        return 0.0;
    }
    if (sd < -thickness) {
        return thickness;
    }
    
    float x = thickness + sd;
    return sqrt(max(0.0, thickness * thickness - x * x));
}

void main() {
    vec2 uv = FlutterFragCoord().xy / u_resolution;

    vec2 centered = uv - 0.5;
    
    // Parameters
    float width = 0.42;
    float rectHeight = 0.2;
    float radius = 0.06;

    float distanceToEdge = sdfRRect(centered, vec2(width, rectHeight), radius);
    
    float offsetFactor = 0.2;
    float displacement = smoothstep(0.0, 0.8, max(0.0, -distanceToEdge + offsetFactor));
    
    float scaleFactor = 1.0 + displacement * 0.8;
    vec2 distortedUV = centered * scaleFactor + 0.5;
    
    if (displacement < 0.001) {
        frag_color = texture(u_texture_input, uv);
        return;
    }
    
    // Apply the distortion with refraction
    float refractiveIndex = 1.8;
    float chromaticAberration = 0.06;
    
    // Calculate normal for more realistic refraction
    float thickness = 40.0;
    vec3 normal = getNormal(distanceToEdge, thickness);
    float surfaceHeight = getHeight(distanceToEdge, thickness);
    
    vec4 refractColor;
    vec3 incident = vec3(0.0, 0.0, -1.0);
    float baseHeight = thickness * 12.0;
    
    // Different refractive indices for RGB channels
    float iorR = refractiveIndex - chromaticAberration * 0.04;
    float iorG = refractiveIndex;
    float iorB = refractiveIndex + chromaticAberration * 0.08;
    
    // Calculate refraction per channel
    vec3 refractVecR = refract(incident, normal, 1.0 / iorR);
    float refractLengthR = (surfaceHeight + baseHeight) / max(0.001, abs(refractVecR.z));
    vec2 refractedUVR = distortedUV + (refractVecR.xy * refractLengthR) / u_resolution;
    float red = texture(u_texture_input, refractedUVR).r;
    
    vec3 refractVecG = refract(incident, normal, 1.0 / iorG);
    float refractLengthG = (surfaceHeight + baseHeight) / max(0.001, abs(refractVecG.z));
    vec2 refractionDisplacement = refractVecG.xy * refractLengthG;
    vec2 refractedUVG = distortedUV + refractionDisplacement / u_resolution;
    vec4 greenSample = texture(u_texture_input, refractedUVG);
    float green = greenSample.g;
    float bgAlpha = greenSample.a;
    
    vec3 refractVecB = refract(incident, normal, 1.0 / iorB);
    float refractLengthB = (surfaceHeight + baseHeight) / max(0.001, abs(refractVecB.z));
    vec2 refractedUVB = distortedUV + (refractVecB.xy * refractLengthB) / u_resolution;
    float blue = texture(u_texture_input, refractedUVB).b;
    
    refractColor = vec4(red, green, blue, bgAlpha);
    
    float edgeHighlight = pow(1.0 - max(0.0, dot(normal, vec3(0.0, 0.0, 1.0))), 3.0) * 0.5;
    refractColor.rgb += vec3(edgeHighlight);
    
    // Mix with original for smoother transition at edges
    float mixFactor = smoothstep(-0.01, 0.0, distanceToEdge);
    vec4 originalColor = texture(u_texture_input, uv);
    
    frag_color = mix(refractColor, originalColor, mixFactor);
}