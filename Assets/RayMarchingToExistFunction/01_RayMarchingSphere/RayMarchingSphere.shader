Shader "Custom/RayMarchingSphere"
{
	Properties
	{
		_Threshold("Threshold", Range(0.0,3.0)) = 0.6 // sliders
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

			// 座標がオブジェクト内か？を返し，形状を定義する形状関数
			// 形状は原点を中心とした球．
			// 原点から一定の距離内の座標に存在するので球になる．
			bool isInObject(float3 pos) {
				return distance(pos, float3(0.0, 0.0, 0.0)) < _Threshold;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 col;

				// 初期の色（黒）を設定
				col.xyz = 0.0;
				col.w = 1.0;

				// レイの初期位置
				float3 pos = i.pos.xyz; 

				// レイの進行方向
				float3 forward = normalize(pos.xyz - _WorldSpaceCameraPos); 

				// レイが進むことを繰り返す．
				// オブジェクト内に到達したら進行距離に応じて色決定
				// 当たらなかったらそのまま（今回は黒）
				const int StepNum = 30;
				const float MarchingDist = 0.03;
				for (int i = 0; i < StepNum; i++) {
					if (isInObject(pos)) {
						col.xyz = 1.0 - i * 0.02;
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
