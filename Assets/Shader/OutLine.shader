//±ßÔµ½¥±ä
Shader "OutLine"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Controller ("Controller",Range(0,1)) = 0.2
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
				float3 normal : TEXCOORD1;
				float3 viewDir : TEXCOORD2;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
                o.uv = v.uv;
				o.normal = UnityObjectToWorldNormal(v.normal);
				o.viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(_Object2World, v.vertex).xyz);
                return o;
            }

            sampler2D _MainTex;
			float _Controller;

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

				if(dot(i.normal, i.viewDir) > _Controller)
				{
					 return col;
				}
                return fixed4(i.uv.xy,0.5f,1);
            }
            ENDCG
        }
    }
}