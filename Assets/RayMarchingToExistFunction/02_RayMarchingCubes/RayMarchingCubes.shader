Shader "Custom/RayMarchingCubes"
{
	Properties
	{
		_Threshold("Threshold", Range(-1.0,1.0)) = 0.0 
		_Freqency("_Freqency", Range(0.0,10.0)) = 3.0 
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
			float _Freqency;

			// その場所にオブジェクトが存在するか？（=オブジェクト内か？）を返す存在関数
			// 形状は無限に並ぶ立方体
			// xyzそれぞれの軸に格子状に存在/非存在するので立方体になる
			bool isInObject(float3 pos) {
				const float PI2 = 6.28318530718;
				return 
					sin(PI2 * _Freqency * pos.x) < _Threshold && 
					sin(PI2 * _Freqency * pos.y) < _Threshold && 
					sin(PI2 * _Freqency * pos.z) < _Threshold;
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
				for (int i = 0; i < 100; i++) {
					if (isInObject(pos)) {
						col.xyz = 1.0 - i * 0.01;
						col.w = col.x;
						break;
					}
					pos.xyz += 0.01 * forward.xyz;
				}


				return col;
			}
			ENDCG
		}
	}
}
