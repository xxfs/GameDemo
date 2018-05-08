Shader "Custom/Texture/RampTexture"
{
	Properties
	{
		_Color("Color",Color) = (1,1,1,1)
		_RampTex("RampTexture", 2D) = "white" {}
	_Specular("Specular",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8.0,256)) = 20
	}
		SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		LOD 100

		Pass
	{
		Tags{ "LightMode" = "ForwardBase" }
		CGPROGRAM
#pragma vertex vert
#pragma fragment frag

#include "UnityCG.cginc"
#include "Lighting.cginc"

		fixed4 _Color;
	sampler2D _RampTex;
	float4 _RampTex_ST;
	float4 _Specular;
	float _Gloss;

	struct appdata
	{
		float4 vertex : POSITION;
		float4 uv : TEXCOORD0;
		float3 normal:NORMAL;
	};

	struct v2f
	{
		float4 vertex :SV_POSITION;
		float2 uv : TEXCOORD0;
		float3 worldNormal:TEXCOORD2;
		float3 worldPos:TEXCOORD1;
	};

	v2f vert(appdata v)
	{
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uv = TRANSFORM_TEX(v.uv, _RampTex);
		o.worldNormal = UnityObjectToWorldNormal(v.normal);
		o.worldPos = mul(unity_ObjectToWorld,v.vertex);
		return o;
	}

	fixed4 frag(v2f i) : SV_Target
	{
		fixed3 worldNormal = normalize(i.worldNormal);
	fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
	fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
	fixed halfLambent = 0.5*dot(worldLightDir,worldNormal) + 0.5;
	//提取对于位置渐变纹理中中的像素颜色
	fixed3 diffuseColor = tex2D(_RampTex,fixed2(halfLambent,halfLambent)).rgb * _Color.rgb;

	fixed3 diffuse = _LightColor0.rgb*diffuseColor.rgb;

	fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
	fixed3 halfDir = normalize(viewDir + worldNormal);

	fixed3 specular = _LightColor0.rgb*_Specular.rgb*pow(max(0,dot(worldNormal,halfDir)),_Gloss);

	return  fixed4(ambient + diffuse + specular,1.0);

	}
		ENDCG
	}
	}
		Fallback "Specular"
}