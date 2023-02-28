
Shader "Custom/Oldschool" {
    Properties{
        _MainCol("颜色",color) = (1.0,1.0,1.0,1.0)
        _SpecularPow("高光次幂",range(1,90)) = 30
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
        uniform float3 _MainCol;
        uniform float _SpecularPow;
        //参数的声明需要放在VertexInput结构前面

            struct VertexInput {
                float4 vertex : POSITION;
                float4 normal : NORMAL;//输入法线信息
            };

            struct VertexOutput {
                float4 posCS : SV_POSITION;//顶点屏幕位置
                float4 posWS : TEXCOORD0;//世界空间顶点位置（TEXCOORD＝顶点数据）
                float3 nDirWS : TEXCOORD1;//世界空间法线信息
            };

            VertexOutput vert(VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                  o.posCS = UnityObjectToClipPos(v.vertex);//变换顶点位置 OS>CS
                  o.posWS = mul(unity_ObjectToWorld, v.vertex);//变换顶点位置
                  o.nDirWS = UnityObjectToWorldNormal(v.normal);//变换法线方向
                return o;
            }

            float4 frag(VertexOutput i) : COLOR{
                //准备向量
                float3 nDir = i.nDirWS;
                float3 lDir = normalize(_WorldSpaceLightPos0.xyz);//归一化的光方向信息
                float3 vDir = normalize(_WorldSpaceCameraPos.xyz - i.posWS.xyz);
                float3 hDir = normalize(vDir + lDir);
                //准备点积结果
                float nDotl = dot(nDir, lDir);
                float nDoth = dot(nDir, hDir);
                //光照模型
                float lambert = max(0.0, nDotl);
                float blingPhong = pow(max(0.0, nDoth), _SpecularPow);
                float3 finalRGB = _MainCol * lambert + blingPhong;
                //返回结果
                return float4(finalRGB, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
————————————————