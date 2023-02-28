// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/NewUnlitShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
        SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            #include "UnityCG.cginc"

            //Shader�ڵı���������������Properties�еĲ���ͬ�����ɲ�������
            float4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;

            //��������
            struct appdata
            {
                float4 vertex : POSITION;//ģ�Ϳռ䶥������
                float2 uv : TEXCOORD0;//��һ��uv
                //float2 uv1 : TEXCOORD1;//����������uv
                float4 color : COLOR;//������ɫ
                float4 normal : NORMAL;//���㷨��
                float4 tangent : TANGENT;//��������

            };

            //�������
            struct v2f
            {
                float4 pos : SV_POSITION;//������Ҫд�ģ��ü��ռ䶥����������
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;//�Զ��������壬ע��������Ĳ�һ������һ����uv��������д16��
            };

            //������ɫ��
            v2f vert (appdata v)
            {
                v2f o;
                float4 posWS = mul(unity_ObjectToWorld, v.vertex);
                float posVS = mul(UNITY_MATRIX_V, posWS);
                float posCS = mul(UNITY_MATRIX_P, posVS);
                o.pos = posCS;
                //o.pos = mul(UNITY_MATRIX_MVP, v.vertex);//һ����λ
                //o.pos = UnityObjectToClioPos(v.vertex);//һ����λ����һ��д��
                o.uv = v.uv * _MainTex_ST.xy + _MainTex_ST.zw;
                //o.uv = TRANSFORM_TEX(v.uv, _MainTex);һ����λ
                o.normal = v.normal;
                return o;
                
            }

            //ƬԪ��ɫ��
            fixed4 frag (v2f i) : SV_Target
            {
                float col = tex2D(_MainTex, i.uv);
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
