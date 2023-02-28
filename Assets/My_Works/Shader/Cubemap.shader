
Shader "Custom/Cubemap" {
	Properties{
		_Cubemap("Cubemap",2D) = "grey"{}
	    _CubemapMip("CubemapMip",Range(0,7)) = 0
		_NormalMap("NormalMap",2D) = "bump"{}
		_FresnelPow("Fresnel Pow",range(0,5)) = 1
		_EnvSpeInt("Specular",range(0, 5)) = 1
		_Occlusion("AO",2D) = "white"{}
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

			uniform sampler2D _Cubemap;
		    uniform sampler2D _NormalMap;
		    uniform float _FresnelPow;
		    uniform float _EnvSpeInt;
			uniform float _CubemapMip;
			uniform sampler2D _Occlusion;

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
					float3 vDirWS = normalize(_WorldSpaceCameraPos.xyz - i.posWS.xyz);
					float3 vrDirWS = reflect(-vDirWS, nDirWS);
					//中間量準備
					float ndotv = dot(nDirWS, vDirWS);
					//光照模型
					float3 occlusion = tex2D(_Occlusion, i.uv0).r;
					float3 cubemap = texCUBElod(_Cubemap, float4(vrDirWS, _CubemapMip));
					float3 fresnel = pow(1.0 - ndotv, _FresnelPow);
					float3 final = matcap * fresnel * _EnvSpeInt * occlusion;
					//返回值
					return float4(final, 1.0);
				}
				ENDCG
			}
		}

}
————————————————