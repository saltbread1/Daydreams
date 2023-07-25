#ifdef GL_ES
precision mediump float;
#endif

const float PI = 3.14159265;
const float TAU = PI*2.;

uniform sampler2D texture;
uniform vec2 resolution;
uniform float time;

float random(const vec2 st)
{
    return fract(sin(dot(st, vec2(12.9898,78.233))) * 43758.5453);
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

void main()
{
    vec2 st = gl_FragCoord.xy / resolution.xy;
    float n = noise(vec2(floor(st.x*64)/64.+time, floor(st.y*64)/64.+time*.4));
    vec2 dist = fract(vec2(n, n*1.6)*8.) - .5;
    float r = texture2D(texture, st+dist*.002).r;
    float g = texture2D(texture, st+dist*.013).g;
    float b = texture2D(texture, st+dist*.009).b;
    
    gl_FragColor = vec4(vec3(r, g, b), 1.);
}