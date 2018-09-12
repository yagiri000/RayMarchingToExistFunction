Shader "Custom/RayMarchingSinPosPlusSinDist"
{
	Properties
	{
		_Threshold("Threshold", Range(-10.0,10.0)) = -0.6 
		_TimeRate("TimeRate", Range(-100.0,100.0)) = 10.0 
		_Scale("Scale", Range(1.0,100.0)) = 8.0 
		_FreqScale("FreqScale", Range(1.0,100.0)) = 10.0 
		_DistScale("DistScale", Range(1.0,10.0)) = 1.0 
	}
	SubShader
	{
		Tags{ "Queue" = "Transparent" }
		LOD 100

		Pass
		{
			ZWrite On
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 pos : POSITION1;
				float4 vertex : SV_POSITION;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.pos = mul(unity_ObjectToWorld, v.vertex);
				o.uv = v.uv;
				return o;
			}

			float _Threshold;
			float _TimeRate;
			float _Scale;
			float _FreqScale;
			float _DistScale;

			// 座標がオブジェクト内か？を返し，形状を定義する形状関数
			// 形状は名状しがたい
			bool isInObject(float3 pos) {
				pos.x += _Time.y * _TimeRate;
				pos.xyz *= _Scale;
				float dist = sin(pos.x) * sin(pos.y) * sin(pos.z);
				dist = pow(dist, 2);
				float sxsy = sin(pos.x) * sin(pos.y);
				float sxsz = sin(pos.x) * sin(pos.z);
				float szsy = sin(pos.z) * sin(pos.y);
				return sin(dist*_DistScale) + sin(sxsy * _FreqScale) + sin(sxsz * _FreqScale) + sin(szsy * _FreqScale) < _Threshold;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 col;
				
				// 初期の色（透明）を設定
				col.xyz = 0.0;
				col.w = 0.0;
				
				// レイの初期位置
				float3 pos = i.pos.xyz; 
				
				// レイの進行方向
				float3 forward = normalize(pos.xyz - _WorldSpaceCameraPos);
				
				// レイが少し進むことを繰り返す．
				// オブジェクト内に到達したら進行距離に応じて色決定
				// 当たらなかったらそのまま（今回は透明）
				const int StepNum = 20;
				const float MarchingDist = 0.02;
				for (int i = 0; i < StepNum; i++) {
					if (isInObject(pos)) {
						col.xyz = 1.0 - i * 0.01;
						col.w = col.x;
						break;
					}
					pos.xyz += MarchingDist * forward.xyz;
				}

				return col;
			}
			ENDCG
		}
	}
}
