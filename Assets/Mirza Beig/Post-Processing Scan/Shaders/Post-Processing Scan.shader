// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Mirza Beig/Post-Processing Scan"
{
	Properties
	{
		_MainTex ( "Screen", 2D ) = "black" {}
		[HDR]_Colour("Colour", Color) = (1,1,1,1)
		[HideInInspector]_MainTex("_MainTex", 2D) = "white" {}
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

		
		
		ZTest Always
		Cull Off
		ZWrite Off

		
		Pass
		{ 
			CGPROGRAM 

			

			#pragma vertex vert_img_custom 
			#pragma fragment frag
			#pragma target 3.0
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"


			struct appdata_img_custom
			{
				float4 vertex : POSITION;
				half2 texcoord : TEXCOORD0;
				
			};

			struct v2f_img_custom
			{
				float4 pos : SV_POSITION;
				half2 uv   : TEXCOORD0;
				half2 stereoUV : TEXCOORD2;
		#if UNITY_UV_STARTS_AT_TOP
				half4 uv2 : TEXCOORD1;
				half4 stereoUV2 : TEXCOORD3;
		#endif
				float4 ase_texcoord4 : TEXCOORD4;
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
			
			float3 InvertDepthDir72_g1( float3 In )
			{
				float3 result = In;
				#if !defined(ASE_SRP_VERSION) || ASE_SRP_VERSION <= 70301
				result *= float3(1,1,-1);
				#endif
				return result;
			}
			


			v2f_img_custom vert_img_custom ( appdata_img_custom v  )
			{
				v2f_img_custom o;
				float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord4 = screenPos;
				
				o.pos = UnityObjectToClipPos( v.vertex );
				o.uv = float4( v.texcoord.xy, 1, 1 );

				#if UNITY_UV_STARTS_AT_TOP
					o.uv2 = float4( v.texcoord.xy, 1, 1 );
					o.stereoUV2 = UnityStereoScreenSpaceUVAdjust ( o.uv2, _MainTex_ST );

					if ( _MainTex_TexelSize.y < 0.0 )
						o.uv.y = 1.0 - o.uv.y;
				#endif
				o.stereoUV = UnityStereoScreenSpaceUVAdjust ( o.uv, _MainTex_ST );
				return o;
			}

			half4 frag ( v2f_img_custom i ) : SV_Target
			{
				#ifdef UNITY_UV_STARTS_AT_TOP
					half2 uv = i.uv2;
					half2 stereoUV = i.stereoUV2;
				#else
					half2 uv = i.uv;
					half2 stereoUV = i.stereoUV;
				#endif	
				
				half4 finalColor;

				// ase common template code
				float2 uv_MainTex = i.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 ScreenColour19 = tex2D( _MainTex, uv_MainTex );
				float4 lerpResult158 = lerp( _Colour , ( _Colour * ScreenColour19 ) , _MultiplyBlend);
				float4 ScanColour88 = lerpResult158;
				float4 screenPos = i.ase_texcoord4;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 UV22_g3 = ase_screenPosNorm.xy;
				float2 localUnStereo22_g3 = UnStereo( UV22_g3 );
				float2 break64_g1 = localUnStereo22_g3;
				float clampDepth69_g1 = SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy );
				#ifdef UNITY_REVERSED_Z
				float staticSwitch38_g1 = ( 1.0 - clampDepth69_g1 );
				#else
				float staticSwitch38_g1 = clampDepth69_g1;
				#endif
				float3 appendResult39_g1 = (float3(break64_g1.x , break64_g1.y , staticSwitch38_g1));
				float4 appendResult42_g1 = (float4((appendResult39_g1*2.0 + -1.0) , 1.0));
				float4 temp_output_43_0_g1 = mul( unity_CameraInvProjection, appendResult42_g1 );
				float3 temp_output_46_0_g1 = ( (temp_output_43_0_g1).xyz / (temp_output_43_0_g1).w );
				float3 In72_g1 = temp_output_46_0_g1;
				float3 localInvertDepthDir72_g1 = InvertDepthDir72_g1( In72_g1 );
				float4 appendResult49_g1 = (float4(localInvertDepthDir72_g1 , 1.0));
				float SDF93 = length( distance( mul( unity_CameraToWorld, appendResult49_g1 ) , float4( _Origin , 0.0 ) ) );
				float mulTime73 = _Time.y * _Speed;
				float temp_output_141_0 = ( _MaskRadius + 1.0 );
				float lerpResult137 = lerp( 0.0 , ( temp_output_141_0 - 0.001 ) , _MaskHardness);
				float smoothstepResult134 = smoothstep( temp_output_141_0 , lerpResult137 , SDF93);
				float SDFMask107 = pow( smoothstepResult134 , _MaskPower );
				float ColourAlpha160 = _Colour.a;
				float Scan77 = ( ( pow( frac( ( ( SDF93 * _Tiling ) - mulTime73 ) ) , _Power ) * SDFMask107 ) * ColourAlpha160 );
				float4 lerpResult17 = lerp( ScreenColour19 , ScanColour88 , Scan77);
				

				finalColor = lerpResult17;

				return finalColor;
			} 
			ENDCG 
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18933
0;615.3334;1279.667;743.6667;5052.605;894.3427;5.055052;True;False
Node;AmplifyShaderEditor.FunctionNode;47;-2108.602,240.2021;Inherit;False;Reconstruct World Position From Depth;-1;;1;e7094bcbcc80eb140b2a3dbe6a861de8;0;0;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector3Node;56;-1991.662,370.7399;Inherit;False;Property;_Origin;Origin;2;0;Create;True;0;0;0;False;0;False;0,0,0;-2,0,1.75;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DistanceOpNode;63;-1609.62,317.4224;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;102;-2288.97,856.3031;Inherit;False;Property;_MaskRadius;Mask Radius;6;0;Create;True;0;0;0;False;0;False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;141;-2089.453,873.4872;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;99;-1402.422,322.7205;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;140;-1914.857,962.3724;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.001;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;93;-1183.009,315.1564;Inherit;False;SDF;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;105;-2227.27,1039.948;Inherit;False;Property;_MaskHardness;Mask Hardness;7;0;Create;True;0;0;0;False;0;False;1;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;84;-2358.02,1706.742;Inherit;False;Property;_Speed;Speed;5;0;Create;True;0;0;0;False;0;False;1;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;133;-2038.428,756.6665;Inherit;False;93;SDF;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;94;-2416.371,1429.616;Inherit;False;93;SDF;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;137;-1733.33,979.2886;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;87;-2399.692,1534.835;Inherit;False;Property;_Tiling;Tiling;4;0;Create;True;0;0;0;False;0;False;1;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;73;-2120.765,1702.397;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;134;-1477.368,855.3109;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;147;-1500.711,993.5451;Inherit;False;Property;_MaskPower;Mask Power;8;0;Create;True;0;0;0;False;0;False;1;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;86;-2068.711,1505.144;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;146;-1198.498,856.3147;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;76;-1776.362,1535.004;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;10;-1758.689,-731.5511;Inherit;True;Property;_MainTex;_MainTex;1;1;[HideInInspector];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;19;-1420.177,-731.819;Inherit;False;ScreenColour;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;18;-2222.791,-386.779;Inherit;False;Property;_Colour;Colour;0;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;1,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FractNode;71;-1558.384,1538.299;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;107;-975.4067,852.9305;Inherit;False;SDFMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;70;-1555.655,1651.428;Inherit;False;Property;_Power;Power;3;0;Create;True;0;0;0;False;0;False;10;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;151;-2009.759,-71.55238;Inherit;False;19;ScreenColour;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;110;-1330.237,1662.619;Inherit;False;107;SDFMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;160;-1951.559,-188.5635;Inherit;False;ColourAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;69;-1304.96,1539.294;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;161;-1663.276,-392.4261;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;109;-1105.926,1570.47;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;155;-1897.945,51.72219;Inherit;False;Property;_MultiplyBlend;Multiply Blend;9;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;152;-1612.079,-236.0615;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;163;-1260.195,1779.949;Inherit;False;160;ColourAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;162;-908.202,1610.993;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;158;-1366.864,-299.9297;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;88;-1130.105,-305.0225;Inherit;False;ScanColour;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;77;-656.2078,1567.089;Inherit;False;Scan;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;20;-123.345,418.7804;Inherit;False;19;ScreenColour;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;78;-126.3958,647.4068;Inherit;False;77;Scan;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;89;-115.4345,522.7502;Inherit;False;88;ScanColour;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;17;334.047,527.5439;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;159;563.7056,528.0174;Float;False;True;-1;2;ASEMaterialInspector;0;5;Mirza Beig/Post-Processing Scan;c71b220b631b6344493ea3cf87110c93;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;True;7;False;-1;False;True;0;False;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;63;0;47;0
WireConnection;63;1;56;0
WireConnection;141;0;102;0
WireConnection;99;0;63;0
WireConnection;140;0;141;0
WireConnection;93;0;99;0
WireConnection;137;1;140;0
WireConnection;137;2;105;0
WireConnection;73;0;84;0
WireConnection;134;0;133;0
WireConnection;134;1;141;0
WireConnection;134;2;137;0
WireConnection;86;0;94;0
WireConnection;86;1;87;0
WireConnection;146;0;134;0
WireConnection;146;1;147;0
WireConnection;76;0;86;0
WireConnection;76;1;73;0
WireConnection;19;0;10;0
WireConnection;71;0;76;0
WireConnection;107;0;146;0
WireConnection;160;0;18;4
WireConnection;69;0;71;0
WireConnection;69;1;70;0
WireConnection;161;0;18;0
WireConnection;109;0;69;0
WireConnection;109;1;110;0
WireConnection;152;0;18;0
WireConnection;152;1;151;0
WireConnection;162;0;109;0
WireConnection;162;1;163;0
WireConnection;158;0;161;0
WireConnection;158;1;152;0
WireConnection;158;2;155;0
WireConnection;88;0;158;0
WireConnection;77;0;162;0
WireConnection;17;0;20;0
WireConnection;17;1;89;0
WireConnection;17;2;78;0
WireConnection;159;0;17;0
ASEEND*/
//CHKSM=FA701EB0A069E3FB8C71C719A17DA95679B31BF0