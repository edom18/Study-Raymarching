Shader "Unlit/Raymarching"
{
    Properties
    {
        _FocalLength("Focal length", Float) = 1.5
        _CameraPos("Camera Pos", Vector) = (0, 0, -10, 0)
        _Target("Target", Vector) = (0, 0, 0, 0)
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
            float4 _Target;
            float _FocalLength;

            float3x3 camera(float3 ro, float3 ta)
            {
                float3 up = normalize(float3(0, 1, 0));
                float3 cw = normalize(ta - ro);
                float3 cu = normalize(cross(up, cw));
                float3 cv = normalize(cross(cw, cu));
                // float3 cw = normalize(ta - ro);
                // float3 cu = normalize(cross(cw, up));
                // float3 cv = normalize(cross(cu, cw));
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

            /// Refer to : https://qiita.com/Santarh/items/428d2e0f33852e6f37b5
            float getAspectRatio()
            {
                // 右上なので (x, y) = (1, 1)
                // かつ近平面に存在するので z は DirectX のとき 0, OpenGL のとき -1
                // w は nearClip の値
                float4 projectionSpaceUpperRight = float4(1, 1, UNITY_NEAR_CLIP_VALUE, _ProjectionParams.y);

                // プロジェクション行列の逆行列で変換
                float4 viewSpaceUpperRight = mul(unity_CameraInvProjection, projectionSpaceUpperRight);

                // 幅 / 高さ でアスペクト比
                float aspect = viewSpaceUpperRight.x / viewSpaceUpperRight.y;
                return aspect;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv * 2.0 - 1.0;
                uv.x *= getAspectRatio();
                float3 ta = _Target.xyz;
                float3 ro = _CameraPos.xyz;
                // float3 ro = float3(0, 0, -5);
                // float3 ta = float3(0, 1, 0);
                float3x3 cam = camera(ro, ta);
                float3 f = normalize(float3(uv, _FocalLength));
                float3 ray = mul(f, cam);

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
