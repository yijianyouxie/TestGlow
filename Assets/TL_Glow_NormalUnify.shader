Shader "TLStudio/Effect/Glow_NormalUnify"
{
	//属性  
	Properties{
		_MainTex("MainTex 2D", 2D) = "white"{}
		_GlowColor("GlowColor", Color) = (1,0,0,1)
		_GlowFactor("GlowFactor", Range(0,0.05)) = 0.02
		_Opacity("Opacity", Range(0,1)) = 0.1
		_MaskTex("Mask tex",2D) = "white" {}
	}



	//子着色器    
	SubShader{ 
		Tags{ "Queue" = "Transparent" }

		Pass{
			Tags{ "LightMode" = "Always"}
			Cull Front ZWrite Off Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#include "UnityCG.cginc"  

			fixed4 _GlowColor;
			float _GlowFactor;
			float _Opacity;
			uniform sampler2D _MaskTex;
			uniform half4 _MaskTex_ST;

			struct v2f
			{
				float4 pos : SV_POSITION;
				float alpha : TEXCOORD0;
				half2 uv : TEXCOORD1;
			};

			v2f vert(appdata_full v)
			{
				v2f o;
				float4 view_vertex = mul(UNITY_MATRIX_MV, v.vertex);
				//将法线方向转换到视空间  
				float3 vnormal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);
				//将视空间法线xy坐标转化到投影空间，只有xy需要，z深度不需要了  
				float2 offset = TransformViewToProjection(vnormal.xy);
				//在最终投影阶段输出进行偏移操作
				view_vertex.xy += offset * _GlowFactor;
				o.pos = mul(UNITY_MATRIX_P, view_vertex);
				float3 delta = normalize(vnormal);
				o.alpha = 1 - (delta.x * delta.x + delta.y * delta.y);
				o.alpha *= _Opacity;

				o.uv = v.texcoord;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed mask = tex2D(_MaskTex, i.uv).r;
				//这个Pass直接输出描边颜色 
				_GlowColor.a = i.alpha * mask;

				return _GlowColor;
			}

			//使用vert函数和frag函数  
			#pragma vertex vert  
			#pragma fragment frag  
			ENDCG
		}

		Pass{
			Name "BACKGR" Tags{ "LightMode" = "Always" }
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Back //剔除后面
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			uniform sampler2D _MainTex;
			uniform half4 _MainTex_ST;

			struct v2f
			{
				float4 vertex :POSITION;
				float4 uv:TEXCOORD0;
			};

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
				return finalColor;
			}
			ENDCG
		}
	}
	//前面的Shader失效的话，使用默认的Diffuse  
	FallBack "Diffuse"
}