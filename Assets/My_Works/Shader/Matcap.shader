
Shader "Custom/Matcap" {
	Properties{
		_NormalMap("NormalMap",2D) = "bump"{}
		_Matcap("Matcap",2D) = "grey"{}
		_FresnelPow("Fresnel Pow",range(0,5)) = 1
		_EnvSpeInt("Specular",range(0, 5)) = 1
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

			uniform sampler2D _NormalMap;
		    uniform sampler2D _Matcap;
		    uniform float _FresnelPow;
		    uniform float _EnvSpeInt;

				struct VertexInput {
					float4 vertex : POSITION;
					float2 uv0 : TEXCOORD0;
					float3 normal : NORMAL;
					float4 tangent : TANGENT;//切线信息
				};

				struct VertexOutput {
					float4 pos : SV_POSITION;//屏幕顶点位置
					float4 posWS : TEXCOORD1;
					float2 uv0 : TEXCOORD0;//UV信息
					float3 nDirWS : TEXCOORD2;
					float3 tDirWS : TEXCOORD3;
					float3 bDirWS :TEXCOORD4;
				};

				VertexOutput vert(VertexInput v) {
					VertexOutput o = (VertexOutput)0;
					    o.pos = UnityObjectToClipPos(v.vertex);
				    	o.uv0 = v.uv0;
						o.posWS = mul(unity_ObjectToWorld, v.vertex);
					    o.nDirWS = UnityObjectToWorldNormal(v.normal);
						o.tDirWS = normalize(mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0.0)).xyz);//
					    o.bDirWS = normalize(cross(o.nDirWS, o.tDirWS) * v.tangent.w);//
					return o;
				}

				float4 frag(VertexOutput i) : COLOR{
					//向量准備
					float3 nDirTS = UnpackNormal(tex2D(_NormalMap,i.uv0)).rgb;
					float3x3 TBN = float3x3(i.tDirWS, i.bDirWS, i.nDirWS);
					float3 nDirWS = normalize(mul(nDirTS, TBN));              //採樣法線貼圖，從切線空間轉化到世界空間
					float3 nDirVS = mul(UNITY_MATRIX_V, float4(nDirWS, 0.0));
					float3 vDirWS = normalize(_WorldSpaceCameraPos.xyz - i.posWS.xyz);
					float3 vrDirWS = reflect(-vDirWS, nDirWS);
					//中間量準備
					float2 matcapUV = nDirVS.rg*0.5+0.5;//視線方向的rg通道，並映射到0到1
					float ndotv = dot(nDirWS,vDirWS);
					//光照模型
					float3 matcap = tex2D(_Matcap, matcapUV);
					float3 fresnel = pow(1.0 - ndotv, _FresnelPow);
					float3 final = matcap * fresnel * _EnvSpeInt;
					return float4(final,1.0);
				}
				ENDCG
			}
		}

}
————————————————