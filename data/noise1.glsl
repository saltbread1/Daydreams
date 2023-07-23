#ifdef GL_ES
precision mediump float;
#endif

const float PI = 3.14159265;

uniform sampler2D texture;
uniform vec2 resolution;
uniform float time;

float random(const vec2 st)
{
    return fract(sin(dot(st, vec2(12.9898,78.233))) * 43758.5453);
}

float random3D(const vec3 v)
{
    return random(vec2(random(v.xy), v.z));
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

float noise3D(const vec3 v)
{
    vec3 i = floor(v);
    vec3 f = fract(v);
    vec3 u = f*f*(3.-2.*f);
    float z0 = mix( mix(random3D(i + vec3(0., 0., 0.)),
                        random3D(i + vec3(1., 0., 0.)), u.x),
                    mix(random3D(i + vec3(0., 1., 0.)),
                        random3D(i + vec3(1., 1., 0.)), u.x),
                    u.y);
    float z1 = mix( mix(random3D(i + vec3(0., 0., 1.)),
                        random3D(i + vec3(1., 0., 1.)), u.x),
                    mix(random3D(i + vec3(0., 1., 1.)),
                        random3D(i + vec3(1., 1., 1.)), u.x),
                    u.y);
    return mix(z0, z1, u.z);
}

void main()
{
    float scale = 2.3;
    vec2 st = gl_FragCoord.xy/resolution;
    float n_val = noise3D(vec3(noise(vec2(st.x*scale, st.y+cos(time))), 
                               noise(vec2(st.y*scale, st.x+sin(time))), 
                               noise(vec2(st.x*scale+cos(time*.13), st.y*scale+sin(time*.13))))*4.);
    float t = n_val*PI*2;
    vec2 p = st + (vec2(cos(t), sin(t)*.33) * noise(st*scale+time)*.04);

    gl_FragColor = texture2D(texture, fract(p));
}