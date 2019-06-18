Shader "Unlit/Raymarching"
{
    Properties
    {
        _FocalLength("Focal length", Float) = 1.5
        _CameraPos("Camera Pos", Vector) = (0, 0, -10, 0)
        _SpherePos("Sphere Pos", Vector) = (0, 0, 0, 0)
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _SpherePos;
            float4 _CameraPos;
            float _FocalLength;

            float3x3 camera(float3 ro, float3 ta, float3 up)
            {
                float3 cw = normalize(ta - ro);
                float3 cu = normalize(cross(cw, up));
                float3 cv = normalize(cross(cu, cw));
                return float3x3(cu, cv, cw);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float map(float3 p)
            {
                return length(p - _SpherePos.xyz) - 1.0;
            }

            float3 normal(float3 p)
            {
                float2 e = float2(0.001, 0.0);
                float d = map(p);
                float3 n = d - float3(
                    map(p - e.xyy),
                    map(p - e.yxy),
                    map(p - e.yyx)
                );
                return normalize(n);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv * 2.0 - 1.0;
                float3 ta = float3(0, 0, 0);
                float3 up = float3(0, 1, 0);
                float3 ro = _CameraPos.xyz;
                // float3 ro = float3(0, 0, -5);
                float3 ray = mul(camera(ro, ta, up), normalize(float3(uv, _FocalLength)));

                float3 col = float3(0, 0, 0);

                float3 p = ro;
                float d = 0.0;
                for (int i = 0; i < 64; i++)
                {
                    d = map(p);

                    if (d < 0.01) break;

                    p += ray * d;
                }

                if (d < 0.01)
                {
                    float3 n = normal(p);
                    float diff = dot(n, normalize(_WorldSpaceCameraPos.xyz));
                    col = float3(diff, diff, diff);
                }

                return float4(col, 1.0);
            }
            ENDCG
        }
    }
}
