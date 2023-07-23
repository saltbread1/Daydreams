#ifdef GL_ES
precision mediump float;
#endif

const float NOISE_SCALE = 40.;
const int OCTAVES = 6;
const int WARP_ITERATIONS = 3;
vec2 n_offsets[WARP_ITERATIONS*2];

uniform vec2 resolution;
uniform float time;
uniform int kernel_size;
uniform float hue_offset;

float random(const vec2 st)
{
    return fract(sin(dot(st, vec2(12.9898,78.233))) * 43758.5453);
}

vec2 random2D(const vec2 st)
{
    vec2 val = vec2( dot(st,vec2(127.1,311.7)),
                     dot(st,vec2(269.5,183.3)) );
    return fract(sin(val)*43758.5453123);
}

float noise(const vec2 v)
{
    vec2 i = floor(v);
    vec2 f = fract(v);
    vec2 u = f*f*(3.-2.*f);
    return mix( mix( random( i + vec2(0., 0.) ),
                     random( i + vec2(1., 0.) ), u.x),
                mix( random( i + vec2(0., 1.) ),
                     random( i + vec2(1., 1.) ), u.x), u.y);
}

float fbm(const vec2 v)
{
    vec2 p = v;
    float result = 0.0;
    float amplitude = .8;

    for (int i = 0; i < OCTAVES; i++)
    {
        result += amplitude * noise(p);
        amplitude *= 0.5;
        p *= 2.0;
    }

    return result;
}

float domainWarp(const vec2 v)
{
    vec2 n_val = vec2(0);
    for (int i = 0; i < WARP_ITERATIONS; i++)
    {
        vec2 val = n_val * 4. + v;
        float n1 = fbm(val + n_offsets[i*2] + time*.16*4);
        float n2 = fbm(val + n_offsets[i*2+1] + time*.62*4);
        n_val = vec2(n1, n2);
    }
    return n_val.x;
}

vec3 hsb2rgb(const vec3 hsb)
{
    return ((clamp(abs(fract(hsb.x+vec3(0,2,1)/3.)*6.-3.)-1.,0.,1.)-1.)*hsb.y+1.)*hsb.z;
}

void main()
{
    for (int i = 0; i < WARP_ITERATIONS*2; i++)
    {
        n_offsets[i] = random2D(vec2(i)) * 10.;
    }
    
    vec2 st = floor(gl_FragCoord.xy / kernel_size) / min(resolution.x, resolution.y);
    
    float n_val = domainWarp(st*NOISE_SCALE);
    float h_val = fract(n_val*1.36 + hue_offset);
    float s_val = clamp(n_val*.71, 0., 1.);
    float b_val = clamp((1.-n_val)*1.64, 0., 1.);
    vec3 hsb = vec3(h_val, s_val, b_val);

    gl_FragColor = vec4(hsb2rgb(hsb), 1.);
}