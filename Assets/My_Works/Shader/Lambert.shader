
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
                float4 normal : NORMAL;//���뷨����Ϣ
            };

            struct VertexOutput {
                float4 pos : SV_POSITION;//�����ģ�Ͷ�����Ϣ��������Ķ�����Ļλ��
                float3 nDirWS : TEXCOORD0;//�����ģ�ͷ�����Ϣ�������������ռ䷨����Ϣ
            };

            VertexOutput vert(VertexInput v) {
                VertexOutput o = (VertexOutput)0;//�½�һ������ṹ
                o.pos = UnityObjectToClipPos(v.vertex);//�任������Ϣ�������丳ֵ������ṹ
                //�������ã�Unity������һ���������굽��Ļ�ռ�ķ�����ת����������Position
                o.nDirWS = UnityObjectToWorldNormal(v.normal);//�任������Ϣ�������丳ֵ������ṹ
                //�������ã�Unity������һ���������굽��������ķ�����ת����������Normal
                return o;
            }

            float4 frag(VertexOutput i) : COLOR{
                float3 nDir = i.nDirWS;
                float3 lDir = normalize(_WorldSpaceLightPos0.xyz);//��һ���Ĺⷽ����Ϣ
                float nDotl = dot(nDir, lDir);
                float lambert = max(0.0, nDotl);
                return float4(lambert,lambert,lambert,1);
            }
            ENDCG
        }
    }
        
}
��������������������������������