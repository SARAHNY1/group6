
Shader "Custom/OldSchoolPlus" {
    Properties{
        _BaseCol("Base_Color",color) = (0.5,0.5,0.5,1.0)
        _LightCol("Light_Color", color) = (1.0,1.0,1.0,1.0)
        _SpecPow("Specular_Pow",Range(0,1)) = 30
        _Occlusion("OA贴图",2d) = "white"{}
        _EnvInt("Ambient_Intensity",Range(0,1)) = 0.2
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
            //include文件
            //#include "AutoLight.cginc"
            //#include "Lighting.cgnic"

            uniform float3 _BaseCol;
            uniform float3 _LightCol;
            uniform float _SpecPow;
            uniform float _EnvInt;
            uniform float3 _EnvUpCol;
            uniform float3 _EnvSideCol;
            uniform float3 _EnvDownCol;
            uniform sampler2D _Occlusion;

            struct VertexInput {
                float4 vertex : POSITION;
                float4 normal : NORMAL;
                float2 uv0 : TEXCOORD0;
            };

            struct VertexOutput {
                float4 posCS : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWS : TEXCOORD1;
                float3 nDirWS : TEXCOORD2;
                //LIGHTING_COORDS(3, 4);//投影坐标。上面已经占用编号0,1,2了，这边占用3和4
                
            };

            VertexOutput vert(VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                   o.posCS = UnityObjectToClipPos(v.vertex);//变换定点位置 OS>CS
                   o.uv0 = v.uv0;//传递uv数据
                   o.posWS = mul(unity_ObjectToWorld, v.vertex);//变换定点位置 OS>WS
                   o.nDirWS = UnityObjectToWorldNormal(v.normal);//变换法线方向 OS>WS
                  //TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }

            float4 frag(VertexOutput i) : COLOR{
                //准备向量
                float3 nDir = normalize(i.nDirWS);
                float3 lDir = _WorldSpaceLightPos0.xyz;
                float3 vDir = normalize(_WorldSpaceCameraPos.xyz - i.posWS.xyz);
                float3 rDir = reflect(-lDir, nDir);
                //准备点积结果
                float nDotl = dot(nDir, lDir);
                float vdotr = dot(vDir, rDir);

                //光照模型（直接光照）
                //float shadow = LIGHT_ATTENUATION(i);
                float lambert = max(0.0, nDotl);
                float phong = pow(max(0.0, vdotr), _SpecPow);
                float3 dirLighting = (_BaseCol * lambert + phong)* _LightCol//*shadow;
                //光照模型（环境光照）
                float upMask = max(0.0, nDir.g);
                float downMask = max(0.0, -nDir.g);
                float sideMask = 1.0 - upMask - downMask;//计算三部分遮罩
                float3 envCol = _EnvUpCol * upMask + _EnvSideCol * sideMask + _EnvDownCol * downMask;//混合环境色
                float occlusion = tex2D(_Occlusion, i.uv0);//采样Occlusion贴图
                float3 envLighting = envCol * occlusion;//计算环境光照

                //返回结果
                float3 finalRGB = dirLighting + envLighting;
                return float4(finalRGB, 1.0);
            }
            ENDCG
        }
    }
        
}
————————————————