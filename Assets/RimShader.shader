Shader "Unlit/RimShader"
{
	//尝试使用rim来显示辉光。
	//模型要比正常模型大一圈。
	//尝试失败，效果不好。
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_RimColor("RimColor", Color) = (1,1,1,1)
		_RimRange("RimRange", Range(0,5)) = 1
	}
	SubShader
	{
		Tags { "Queue" = "Transparent" "RenderType"="Transparent" }
		LOD 150

		Pass
		{
			Cull Off 
			ZWrite Off 
			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			uniform fixed4 _RimColor;
			uniform float _RimRange;
			struct VertexInput {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				half2 texcoord0 : TEXCOORD0;
			};
			struct VertexOutput {
				float4 pos : SV_POSITION;
				half2 uv0 : TEXCOORD0;
				fixed3 viewDirection : TEXCOORD1;
				fixed3 normalDir : TEXCOORD2;
				float4 posWorld:TEXCOORD3;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			VertexOutput vert (VertexInput v)
			{
				VertexOutput o = (VertexOutput)0;
				o.uv0 = v.texcoord0;
				o.normalDir = UnityObjectToWorldNormal(v.normal);

				o.posWorld = mul(_Object2World, v.vertex);
				o.viewDirection = normalize(_WorldSpaceCameraPos.xyz - o.posWorld.xyz);
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (VertexOutput i) : SV_Target
			{
				fixed4 _MainTexColor = tex2D(_MainTex, TRANSFORM_TEX(i.uv0, _MainTex));
				fixed3 normalDirection = i.normalDir;
				fixed rimRange = abs(dot(i.viewDirection, normalDirection));
				fixed3 finalColor = _RimRange* rimRange * _RimColor;
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, finalColor);
				return fixed4(_RimColor.rgb, _RimRange* rimRange* rimRange* rimRange);
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
}
