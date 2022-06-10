// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Mirza Beig/Post-Processing Scan (PPSv2)"
{
	Properties
	{
		[HDR]_Colour("Colour", Color) = (1,1,1,1)
		_Origin("Origin", Vector) = (0,0,0,0)
		_Power("Power", Float) = 10
		_Tiling("Tiling", Float) = 1
		_Speed("Speed", Float) = 1
		_MaskRadius("Mask Radius", Float) = 5
		_MaskHardness("Mask Hardness", Range( 0 , 1)) = 1
		_MaskPower("Mask Power", Float) = 1
		_MultiplyBlend("Multiply Blend", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}

	SubShader
	{
		LOD 0

		Cull Off
		ZWrite Off
		ZTest Always
		
		Pass
		{
			CGPROGRAM

			

			#pragma vertex Vert
			#pragma fragment Frag
			#pragma target 3.0

			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"
			#define ASE_NEEDS_FRAG_SCREEN_POSITION_NORMALIZED

		
			struct ASEAttributesDefault
			{
				float3 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				
			};

			struct ASEVaryingsDefault
			{
				float4 vertex : SV_POSITION;
				float2 texcoord : TEXCOORD0;
				float2 texcoordStereo : TEXCOORD1;
			#if STEREO_INSTANCING_ENABLED
				uint stereoTargetEyeIndex : SV_RenderTargetArrayIndex;
			#endif
				
			};

			uniform sampler2D _MainTex;
			uniform half4 _MainTex_TexelSize;
			uniform half4 _MainTex_ST;
			
			uniform float4 _Colour;
			uniform float _MultiplyBlend;
			UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
			uniform float4 _CameraDepthTexture_TexelSize;
			uniform float3 _Origin;
			uniform float _Tiling;
			uniform float _Speed;
			uniform float _Power;
			uniform float _MaskRadius;
			uniform float _MaskHardness;
			uniform float _MaskPower;


			float2 UnStereo( float2 UV )
			{
				#if UNITY_SINGLE_PASS_STEREO
				float4 scaleOffset = unity_StereoScaleOffset[ unity_StereoEyeIndex ];
				UV.xy = (UV.xy - scaleOffset.zw) / scaleOffset.xy;
				#endif
				return UV;
			}
			
			float3 InvertDepthDir72_g5( float3 In )
			{
				float3 result = In;
				#if !defined(ASE_SRP_VERSION) || ASE_SRP_VERSION <= 70301
				result *= float3(1,1,-1);
				#endif
				return result;
			}
			

			float2 TransformTriangleVertexToUV (float2 vertex)
			{
				float2 uv = (vertex + 1.0) * 0.5;
				return uv;
			}

			ASEVaryingsDefault Vert( ASEAttributesDefault v  )
			{
				ASEVaryingsDefault o;
				o.vertex = float4(v.vertex.xy, 0.0, 1.0);
				o.texcoord = TransformTriangleVertexToUV (v.vertex.xy);
#if UNITY_UV_STARTS_AT_TOP
				o.texcoord = o.texcoord * float2(1.0, -1.0) + float2(0.0, 1.0);
#endif
				o.texcoordStereo = TransformStereoScreenSpaceTex (o.texcoord, 1.0);

				v.texcoord = o.texcoordStereo;
				float4 ase_ppsScreenPosVertexNorm = float4(o.texcoordStereo,0,1);

				

				return o;
			}

			float4 Frag (ASEVaryingsDefault i  ) : SV_Target
			{
				float4 ase_ppsScreenPosFragNorm = float4(i.texcoordStereo,0,1);

				float2 uv_MainTex = i.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 ScreenColour19 = tex2D( _MainTex, uv_MainTex );
				float4 lerpResult151 = lerp( _Colour , ( _Colour * ScreenColour19 ) , _MultiplyBlend);
				float4 ScanColour154 = lerpResult151;
				float2 UV22_g6 = ase_ppsScreenPosFragNorm.xy;
				float2 localUnStereo22_g6 = UnStereo( UV22_g6 );
				float2 break64_g5 = localUnStereo22_g6;
				float clampDepth69_g5 = SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_ppsScreenPosFragNorm.xy );
				#ifdef UNITY_REVERSED_Z
				float staticSwitch38_g5 = ( 1.0 - clampDepth69_g5 );
				#else
				float staticSwitch38_g5 = clampDepth69_g5;
				#endif
				float3 appendResult39_g5 = (float3(break64_g5.x , break64_g5.y , staticSwitch38_g5));
				float4 appendResult42_g5 = (float4((appendResult39_g5*2.0 + -1.0) , 1.0));
				float4 temp_output_43_0_g5 = mul( unity_CameraInvProjection, appendResult42_g5 );
				float3 temp_output_46_0_g5 = ( (temp_output_43_0_g5).xyz / (temp_output_43_0_g5).w );
				float3 In72_g5 = temp_output_46_0_g5;
				float3 localInvertDepthDir72_g5 = InvertDepthDir72_g5( In72_g5 );
				float4 appendResult49_g5 = (float4(localInvertDepthDir72_g5 , 1.0));
				float SDF125 = length( distance( mul( unity_CameraToWorld, appendResult49_g5 ) , float4( _Origin , 0.0 ) ) );
				float mulTime135 = _Time.y * _Speed;
				float temp_output_123_0 = ( _MaskRadius + 1.0 );
				float lerpResult128 = lerp( 0.0 , ( temp_output_123_0 - 0.001 ) , _MaskHardness);
				float smoothstepResult134 = smoothstep( temp_output_123_0 , lerpResult128 , SDF125);
				float SDFMask140 = pow( smoothstepResult134 , _MaskPower );
				float ColourAlpha143 = _Colour.a;
				float Scan153 = ( ( pow( frac( ( ( SDF125 * _Tiling ) - mulTime135 ) ) , _Power ) * SDFMask140 ) * ColourAlpha143 );
				float4 lerpResult117 = lerp( ScreenColour19 , ScanColour154 , Scan153);
				

				float4 color = lerpResult117;
				
				return color;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18933
0;615.3334;1279.667;743.6667;4320.155;437.1179;4.259816;True;False
Node;AmplifyShaderEditor.FunctionNode;118;-3050.389,286.7619;Inherit;False;Reconstruct World Position From Depth;-1;;5;e7094bcbcc80eb140b2a3dbe6a861de8;0;0;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector3Node;119;-2933.449,417.2997;Inherit;False;Property;_Origin;Origin;1;0;Create;True;0;0;0;False;0;False;0,0,0;-2,0,1.75;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;121;-3230.757,902.8633;Inherit;False;Property;_MaskRadius;Mask Radius;5;0;Create;True;0;0;0;False;0;False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;120;-2551.407,363.9822;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;122;-2344.209,369.2803;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;123;-3031.24,920.0474;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;124;-2856.644,1008.932;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.001;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;125;-2124.796,361.7162;Inherit;False;SDF;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;126;-3169.057,1086.508;Inherit;False;Property;_MaskHardness;Mask Hardness;6;0;Create;True;0;0;0;False;0;False;1;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;131;-3299.807,1753.302;Inherit;False;Property;_Speed;Speed;4;0;Create;True;0;0;0;False;0;False;1;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;130;-2980.215,803.2267;Inherit;False;125;SDF;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;129;-3358.158,1476.176;Inherit;False;125;SDF;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;128;-2675.117,1025.849;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;127;-3341.479,1581.395;Inherit;False;Property;_Tiling;Tiling;3;0;Create;True;0;0;0;False;0;False;1;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;9;-2977.243,-777.4985;Inherit;False;0;0;_MainTex;Shader;False;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;135;-3062.552,1748.957;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;133;-3010.498,1551.704;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;134;-2419.156,901.8712;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;132;-2442.499,1040.105;Inherit;False;Property;_MaskPower;Mask Power;7;0;Create;True;0;0;0;False;0;False;1;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;136;-2140.285,902.8749;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;137;-2718.149,1581.564;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;10;-2791.967,-782.496;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;138;-3164.578,-340.2189;Inherit;False;Property;_Colour;Colour;0;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;1,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FractNode;139;-2500.171,1584.859;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;19;-2462.718,-782.4297;Inherit;False;ScreenColour;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;141;-2497.442,1697.988;Inherit;False;Property;_Power;Power;2;0;Create;True;0;0;0;False;0;False;10;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;140;-1917.194,899.4907;Inherit;False;SDFMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;143;-2893.346,-142.0035;Inherit;False;ColourAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;144;-2951.546,-24.99239;Inherit;False;19;ScreenColour;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;145;-2246.747,1585.854;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;142;-2272.024,1709.179;Inherit;False;140;SDFMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;149;-2047.713,1617.03;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;150;-2605.063,-345.866;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;147;-2201.982,1826.509;Inherit;False;143;ColourAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;146;-2553.866,-189.5014;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;148;-2839.732,98.28214;Inherit;False;Property;_MultiplyBlend;Multiply Blend;8;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;151;-2308.651,-253.3696;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;152;-1849.989,1657.553;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;153;-1597.995,1613.649;Inherit;False;Scan;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;154;-2071.892,-258.4624;Inherit;False;ScanColour;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;155;-990.1193,459.9823;Inherit;False;19;ScreenColour;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;156;-993.1702,688.6088;Inherit;False;153;Scan;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;157;-982.2087,563.9522;Inherit;False;154;ScanColour;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;117;-532.7272,568.7459;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;114;-282.8665,576.2399;Float;False;True;-1;2;ASEMaterialInspector;0;2;Mirza Beig/Post-Processing Scan (PPSv2);32139be9c1eb75640a847f011acf3bcf;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;True;7;False;-1;False;False;False;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;120;0;118;0
WireConnection;120;1;119;0
WireConnection;122;0;120;0
WireConnection;123;0;121;0
WireConnection;124;0;123;0
WireConnection;125;0;122;0
WireConnection;128;1;124;0
WireConnection;128;2;126;0
WireConnection;135;0;131;0
WireConnection;133;0;129;0
WireConnection;133;1;127;0
WireConnection;134;0;130;0
WireConnection;134;1;123;0
WireConnection;134;2;128;0
WireConnection;136;0;134;0
WireConnection;136;1;132;0
WireConnection;137;0;133;0
WireConnection;137;1;135;0
WireConnection;10;0;9;0
WireConnection;139;0;137;0
WireConnection;19;0;10;0
WireConnection;140;0;136;0
WireConnection;143;0;138;4
WireConnection;145;0;139;0
WireConnection;145;1;141;0
WireConnection;149;0;145;0
WireConnection;149;1;142;0
WireConnection;150;0;138;0
WireConnection;146;0;138;0
WireConnection;146;1;144;0
WireConnection;151;0;150;0
WireConnection;151;1;146;0
WireConnection;151;2;148;0
WireConnection;152;0;149;0
WireConnection;152;1;147;0
WireConnection;153;0;152;0
WireConnection;154;0;151;0
WireConnection;117;0;155;0
WireConnection;117;1;157;0
WireConnection;117;2;156;0
WireConnection;114;0;117;0
ASEEND*/
//CHKSM=1FECB51F15F8B44BF5F9449C0F76EC8F3D9D22DE