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

            //Shader内的变量声明，与上述Properties中的参数同名即可产生链接
            float4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;

            //输入数据
            struct appdata
            {
                float4 vertex : POSITION;//模型空间顶点坐标
                float2 uv : TEXCOORD0;//第一套uv
                //float2 uv1 : TEXCOORD1;//最多可以四套uv
                float4 color : COLOR;//顶点颜色
                float4 normal : NORMAL;//顶点法线
                float4 tangent : TANGENT;//顶点切线

            };

            //输出数据
            struct v2f
            {
                float4 pos : SV_POSITION;//（必须要写的）裁剪空间顶点坐标数据
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;//自定义数据体，注意与上面的不一样，不一定是uv，最多可以写16个
            };

            //顶点着色器
            v2f vert (appdata v)
            {
                v2f o;
                float4 posWS = mul(unity_ObjectToWorld, v.vertex);
                float posVS = mul(UNITY_MATRIX_V, posWS);
                float posCS = mul(UNITY_MATRIX_P, posVS);
                o.pos = posCS;
                //o.pos = mul(UNITY_MATRIX_MVP, v.vertex);//一步到位
                //o.pos = UnityObjectToClioPos(v.vertex);//一步到位的另一种写法
                o.uv = v.uv * _MainTex_ST.xy + _MainTex_ST.zw;
                //o.uv = TRANSFORM_TEX(v.uv, _MainTex);一步到位
                o.normal = v.normal;
                return o;
                
            }

            //片元着色器
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
