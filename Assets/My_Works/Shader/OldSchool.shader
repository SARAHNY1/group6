
Shader "Custom/Oldschool" {
    Properties{
        _MainCol("��ɫ",color) = (1.0,1.0,1.0,1.0)
        _SpecularPow("�߹����",range(1,90)) = 30
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
        //������������Ҫ����VertexInput�ṹǰ��

            struct VertexInput {
                float4 vertex : POSITION;
                float4 normal : NORMAL;//���뷨����Ϣ
            };

            struct VertexOutput {
                float4 posCS : SV_POSITION;//������Ļλ��
                float4 posWS : TEXCOORD0;//����ռ䶥��λ�ã�TEXCOORD���������ݣ�
                float3 nDirWS : TEXCOORD1;//����ռ䷨����Ϣ
            };

            VertexOutput vert(VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                  o.posCS = UnityObjectToClipPos(v.vertex);//�任����λ�� OS>CS
                  o.posWS = mul(unity_ObjectToWorld, v.vertex);//�任����λ��
                  o.nDirWS = UnityObjectToWorldNormal(v.normal);//�任���߷���
                return o;
            }

            float4 frag(VertexOutput i) : COLOR{
                //׼������
                float3 nDir = i.nDirWS;
                float3 lDir = normalize(_WorldSpaceLightPos0.xyz);//��һ���Ĺⷽ����Ϣ
                float3 vDir = normalize(_WorldSpaceCameraPos.xyz - i.posWS.xyz);
                float3 hDir = normalize(vDir + lDir);
                //׼��������
                float nDotl = dot(nDir, lDir);
                float nDoth = dot(nDir, hDir);
                //����ģ��
                float lambert = max(0.0, nDotl);
                float blingPhong = pow(max(0.0, nDoth), _SpecularPow);
                float3 finalRGB = _MainCol * lambert + blingPhong;
                //���ؽ��
                return float4(finalRGB, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
��������������������������������