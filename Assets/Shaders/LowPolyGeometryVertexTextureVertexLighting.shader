﻿Shader "Custom/Low_PolyVertexTextureVertexLighting"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "LightMode" = "ForwardBase" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2g
			{
				float4 vertex : SV_POSITION;
				float4 textureColor : TEXCOORD0;
			};

			struct g2f
			{
				float4 vertex : SV_POSITION;
				float4 textureColor : TEXCOORD0;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2g vert (appdata v)
			{
				v2g o;
				o.vertex = mul(unity_ObjectToWorld, v.vertex);
				v.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.textureColor = tex2Dlod(_MainTex, float4(v.uv,0,0));

				return o;
			}
			
			[maxvertexcount(3)]
			void geom(triangle v2g IN[3], inout TriangleStream<g2f> triStream) {
				
				float4 v0 = IN[0].vertex;
				float4 v1 = IN[1].vertex;
				float4 v2 = IN[2].vertex;

				float3 normal = normalize(cross(v1 - v0, v2 - v1));

				float4x4 vp = mul(UNITY_MATRIX_MVP, unity_WorldToObject);
				
				g2f pIn;

				float4 triColor = (IN[0].textureColor + IN[1].textureColor + IN[2].textureColor) / 3;
				triColor *= max(dot(normalize(_WorldSpaceLightPos0), normal), 0);

				pIn.vertex = mul(vp, v0);
				pIn.textureColor = triColor;
				triStream.Append(pIn);

				pIn.vertex = mul(vp, v1);
				pIn.textureColor = triColor;
				triStream.Append(pIn);

				pIn.vertex = mul(vp, v2);
				pIn.textureColor = triColor;;
				triStream.Append(pIn);

			}

			fixed4 frag (g2f i) : SV_Target
			{
				return i.textureColor;
			}
			ENDCG
		}
	}
}
