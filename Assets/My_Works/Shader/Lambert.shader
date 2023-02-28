
Shader "Custom/Lanbert" {
    Properties{
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
            struct VertexInput {
                float4 vertex : POSITION;
                float4 normal : NORMAL;//输入法线信息
            };

            struct VertexOutput {
                float4 pos : SV_POSITION;//输出由模型顶点信息换算而来的顶点屏幕位置
                float3 nDirWS : TEXCOORD0;//输出由模型法线信息换算而来的世界空间法线信息
            };

            VertexOutput vert(VertexInput v) {
                VertexOutput o = (VertexOutput)0;//新建一个输出结构
                o.pos = UnityObjectToClipPos(v.vertex);//变换顶点信息，并将其赋值给输出结构
                //函数作用：Unity声明的一个物体坐标到屏幕空间的方法，转换的内容是Position
                o.nDirWS = UnityObjectToWorldNormal(v.normal);//变换法线信息，并将其赋值给输出结构
                //函数作用：Unity声明的一个物体坐标到世界坐标的方法，转换的内容是Normal
                return o;
            }

            float4 frag(VertexOutput i) : COLOR{
                float3 nDir = i.nDirWS;
                float3 lDir = normalize(_WorldSpaceLightPos0.xyz);//归一化的光方向信息
                float nDotl = dot(nDir, lDir);
                float lambert = max(0.0, nDotl);
                return float4(lambert,lambert,lambert,1);
            }
            ENDCG
        }
    }
        
}
————————————————