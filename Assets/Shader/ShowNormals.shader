// Upgrade NOTE: replaced '_World2Object' with '_World2Object'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with '_Object2World'
// Upgrade NOTE: replaced '_World2Object' with '_World2Object'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/ShowNormals"
{
	Properties
	{
		_MainTex("Main tex",2D) = "black" {}
		_LineLength("LineLength",float) = 0.03
		_LineColor("LineColor",COLOR) = (1,0,0,1)
		_Alpha("Alpha", float) = 1
	}
		SubShader
	{
		Pass
	{
		Tags{ "RenderType" = "Opaque" }
		LOD 200

		CGPROGRAM
#pragma target 5.0
#pragma vertex VS_Main
#pragma fragment FS_Main
#pragma geometry GS_Main
#include "UnityCG.cginc"

		float _LineLength;
	fixed4 _LineColor;


	struct GS_INPUT
	{
		float4    pos       : POSITION;
		float3    normal    : NORMAL;
		float2  tex0        : TEXCOORD0;
	};
	struct FS_INPUT
	{
		float4    pos       : POSITION;
		float2  tex0        : TEXCOORD0;
	};
	//step1
	GS_INPUT VS_Main(appdata_base v)
	{
		GS_INPUT output = (GS_INPUT)0;
		output.pos = mul(_Object2World, v.vertex);
		//output.pos = UnityObjectToClipPos(v.vertex);
		output.normal = v.normal;
		//float4 viewNormal = mul(UNITY_MATRIX_IT_MV, float4(v.normal, 0));
		float3 worldNormal = UnityObjectToWorldNormal(v.normal);
		output.normal = normalize(worldNormal);
		output.tex0 = float2(0, 0);
		return output;
	}
	[maxvertexcount(4)]
	void GS_Main(point GS_INPUT p[1], inout LineStream<FS_INPUT> triStream)
	{
		FS_INPUT pIn;
		pIn.pos = mul(UNITY_MATRIX_VP, p[0].pos);// UnityObjectToClipPos(p[0].pos);
		pIn.tex0 = float2(0.0f, 0.0f);
		triStream.Append(pIn);
		FS_INPUT pIn1;
		float4 pos = p[0].pos + float4(p[0].normal,0) *_LineLength;
		pIn1.pos = mul(UNITY_MATRIX_VP, pos);
		pIn1.tex0 = float2(0.0f, 0.0f);
		triStream.Append(pIn1);

	}

	//step3
	fixed4 FS_Main(FS_INPUT input) : COLOR
	{
		return _LineColor;
	}
		ENDCG
	}

		Pass
	{
		Name "BACKGR" Tags{ "LightMode" = "Always" }
		Blend SrcAlpha OneMinusSrcAlpha
		Cull Off //剔除后面
		CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"

		struct v2f
	{
		float4 vertex :POSITION;
		float4 uv:TEXCOORD0;
	};
	uniform sampler2D _MainTex;
	uniform half4 _MainTex_ST;
	float _Alpha;

	v2f vert(appdata_full v)
	{
		v2f o;
		o.vertex = mul(UNITY_MATRIX_MVP,v.vertex);
		o.uv = v.texcoord;
		return o;
	}

	fixed4 frag(v2f IN) :COLOR
	{
		fixed4 _MainTex_Var = tex2D(_MainTex,IN.uv);
	fixed4 finalColor = _MainTex_Var;
	finalColor.a = _Alpha;
	return finalColor;
	}
		ENDCG
	}
	}
}