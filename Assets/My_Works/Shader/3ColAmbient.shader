
Shader "Custom/3Col" {
    Properties{
        _Occlusion("OA贴图",2d) = "white"{}
        _EnvUpCol("Up_Color",color) = (1.0,1.0,1.0,1.0)
        _EnvSideCol("Side_Color", color) = (0.5, 0.5, 0.5, 1.0)
        _EnvDownCol("Down_Color", color) = (0.0, 0.0, 0.0, 1.0)
    }

        SubShader
        {
            Tags {"RenderType" = "Opaque" }
            Pass {
                Name "FORWARD"
                Tags {"LightMode" = "ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma target 3.0

            uniform float3 _EnvUpCol;
            uniform float3 _EnvSideCol;
            uniform float3 _EnvDownCol;
            uniform sampler2D _Occlusion;

            struct VertexInput {
                float4 vertex : POSITION;
                float4 normal : NORMAL;
                float2 uv0 : TEXCOORD0;//uv0代表的是第一套uv
            };

            struct VertexOutput {
                float4 pos : SV_POSITION;
                float3 nDirWS : TEXCOORD0;
                float2 uv : TEXCOORD1;
            };

            VertexOutput vert(VertexInput v) {
                VertexOutput o = (VertexOutput)0;//新建一个输出结构
                   o.pos = UnityObjectToClipPos(v.vertex);
                   o.nDirWS = UnityObjectToWorldNormal(v.normal);
                   o.uv = v.uv0;
                return o;
            }

            float4 frag(VertexOutput i) : COLOR{
                //准备向量
                float3 nDir = i.nDirWS;
                //计算各部分遮罩
                float upMask = max(0.0, nDir.g);//取绿通道大于0的部分，即向上的部分
                float downMask = max(0.0, -nDir.g);
                float sideMask = 1.0-upMask-downMask;
                //混合环境色
                float3 envCol = _EnvUpCol * upMask + _EnvSideCol * sideMask + _EnvDownCol * downMask;
                //采样Occlusion贴图
                float occlusion = tex2D(_Occlusion, i.uv);
                //计算环境光照
                float3 envLighting = envCol * occlusion;
                //返回最终颜色
                return float4(envLighting, 1);
            }
            ENDCG
        }
    }
        
}
————————————————