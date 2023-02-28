
Shader "Custom/OldSchoolPlus" {
    Properties{
        _BaseCol("Base_Color",color) = (0.5,0.5,0.5,1.0)
        _LightCol("Light_Color", color) = (1.0,1.0,1.0,1.0)
        _SpecPow("Specular_Pow",Range(0,1)) = 30
        _Occlusion("OA��ͼ",2d) = "white"{}
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
            //include�ļ�
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
                //LIGHTING_COORDS(3, 4);//ͶӰ���ꡣ�����Ѿ�ռ�ñ��0,1,2�ˣ����ռ��3��4
                
            };

            VertexOutput vert(VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                   o.posCS = UnityObjectToClipPos(v.vertex);//�任����λ�� OS>CS
                   o.uv0 = v.uv0;//����uv����
                   o.posWS = mul(unity_ObjectToWorld, v.vertex);//�任����λ�� OS>WS
                   o.nDirWS = UnityObjectToWorldNormal(v.normal);//�任���߷��� OS>WS
                  //TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }

            float4 frag(VertexOutput i) : COLOR{
                //׼������
                float3 nDir = normalize(i.nDirWS);
                float3 lDir = _WorldSpaceLightPos0.xyz;
                float3 vDir = normalize(_WorldSpaceCameraPos.xyz - i.posWS.xyz);
                float3 rDir = reflect(-lDir, nDir);
                //׼��������
                float nDotl = dot(nDir, lDir);
                float vdotr = dot(vDir, rDir);

                //����ģ�ͣ�ֱ�ӹ��գ�
                //float shadow = LIGHT_ATTENUATION(i);
                float lambert = max(0.0, nDotl);
                float phong = pow(max(0.0, vdotr), _SpecPow);
                float3 dirLighting = (_BaseCol * lambert + phong)* _LightCol//*shadow;
                //����ģ�ͣ��������գ�
                float upMask = max(0.0, nDir.g);
                float downMask = max(0.0, -nDir.g);
                float sideMask = 1.0 - upMask - downMask;//��������������
                float3 envCol = _EnvUpCol * upMask + _EnvSideCol * sideMask + _EnvDownCol * downMask;//��ϻ���ɫ
                float occlusion = tex2D(_Occlusion, i.uv0);//����Occlusion��ͼ
                float3 envLighting = envCol * occlusion;//���㻷������

                //���ؽ��
                float3 finalRGB = dirLighting + envLighting;
                return float4(finalRGB, 1.0);
            }
            ENDCG
        }
    }
        
}
��������������������������������