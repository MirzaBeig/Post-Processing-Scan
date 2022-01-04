// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Scan"
{
	Properties
	{
		_MainTex ( "Screen", 2D ) = "black" {}
		[HDR]_ScanColour("Scan Colour", Color) = (0,0,0,0)
		_ScanOrigin("Scan Origin", Vector) = (0,0,0,0)
		_ScanPower("Scan Power", Float) = 0
		_ScanTiling("Scan Tiling", Float) = 1
		_ScanSpeed("Scan Speed", Float) = 1
		_DepthMaskAmount("Depth Mask Amount", Range( 0 , 1)) = 1
		_DepthMaskPower("Depth Mask Power", Float) = 1
		_SDFMaskAmount("SDF Mask Amount", Range( 0 , 1)) = 0.1
		_SDFMaskPower("SDF Mask Power", Float) = 1
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
			
			uniform float4 _ScanColour;
			UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
			uniform float4 _CameraDepthTexture_TexelSize;
			uniform float _DepthMaskAmount;
			uniform float _DepthMaskPower;
			uniform float3 _ScanOrigin;
			uniform float _ScanTiling;
			uniform float _ScanSpeed;
			uniform float _ScanPower;
			uniform float _SDFMaskAmount;
			uniform float _SDFMaskPower;
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
				float4 tex2DNode10 = tex2D( _MainTex, uv_MainTex );
				float4 ScreenColour19 = tex2DNode10;
				float4 ScanColour88 = _ScanColour;
				float4 screenPos = i.ase_texcoord4;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float eyeDepth2 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
				float Depth21 = saturate( pow( ( eyeDepth2 * _DepthMaskAmount ) , _DepthMaskPower ) );
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
				float SDF93 = length( distance( mul( unity_CameraToWorld, appendResult49_g1 ) , float4( _ScanOrigin , 0.0 ) ) );
				float mulTime73 = _Time.y * _ScanSpeed;
				float SDFMask107 = saturate( ( 1.0 - pow( ( SDF93 * _SDFMaskAmount ) , _SDFMaskPower ) ) );
				float Scan77 = ( pow( frac( ( ( SDF93 * _ScanTiling ) - mulTime73 ) ) , _ScanPower ) * SDFMask107 );
				float4 lerpResult17 = lerp( ScreenColour19 , ScanColour88 , ( ( 1.0 - Depth21 ) * Scan77 ));
				

				finalColor = lerpResult17;

				return finalColor;
			} 
			ENDCG 
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18921
0;72.66667;1280;522;3226.179;1039.989;2.804577;True;False
Node;AmplifyShaderEditor.Vector3Node;56;-2757.404,757.7444;Inherit;False;Property;_ScanOrigin;Scan Origin;1;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0.5;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.FunctionNode;47;-2874.343,664.6569;Inherit;False;Reconstruct World Position From Depth;-1;;1;e7094bcbcc80eb140b2a3dbe6a861de8;0;0;1;FLOAT4;0
Node;AmplifyShaderEditor.DistanceOpNode;63;-2406.572,698.1851;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;99;-2227.462,697.2415;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;93;-2073.689,690.2907;Inherit;False;SDF;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;96;-2927.26,1069.593;Inherit;False;93;SDF;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;102;-3020.556,1168.943;Inherit;False;Property;_SDFMaskAmount;SDF Mask Amount;7;0;Create;True;0;0;0;False;0;False;0.1;0.3;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;98;-2593.07,1085.458;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;105;-2649.194,1208.161;Inherit;False;Property;_SDFMaskPower;SDF Mask Power;8;0;Create;True;0;0;0;False;0;False;1;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;94;-3081.172,1415.976;Inherit;False;93;SDF;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;97;-2335.928,1107.086;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;84;-3052.796,1679.78;Inherit;False;Property;_ScanSpeed;Scan Speed;4;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;87;-3049.154,1520.865;Inherit;False;Property;_ScanTiling;Scan Tiling;3;0;Create;True;0;0;0;False;0;False;1;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-2914.392,289.8068;Inherit;False;Property;_DepthMaskAmount;Depth Mask Amount;5;0;Create;True;0;0;0;False;0;False;1;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;86;-2763.487,1478.182;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;106;-2141.767,1104.859;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;73;-2815.541,1675.435;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenDepthNode;2;-2881.707,181.9159;Inherit;False;0;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;-2513.988,231.4422;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-2603.965,358.7894;Inherit;False;Property;_DepthMaskPower;Depth Mask Power;6;0;Create;True;0;0;0;False;0;False;1;99;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;76;-2471.139,1508.042;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;111;-1972.266,1102.094;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;70;-2250.433,1624.466;Inherit;False;Property;_ScanPower;Scan Power;2;0;Create;True;0;0;0;False;0;False;0;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;107;-1808.849,1098.259;Inherit;False;SDFMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;23;-2273.957,282.9559;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;71;-2253.162,1511.337;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;69;-1999.738,1512.332;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;110;-2025.015,1635.657;Inherit;False;107;SDFMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;85;-2098.133,281.1682;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;9;-2077.931,-666.5462;Inherit;False;0;0;_MainTex;Shader;False;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;109;-1800.704,1543.508;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;21;-1926.745,272.1412;Inherit;False;Depth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;18;-1751.515,-330.5386;Inherit;False;Property;_ScanColour;Scan Colour;0;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;77;-1627.242,1532.562;Inherit;False;Scan;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;10;-1900.984,-666.5462;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;22;-944.2941,306.0674;Inherit;False;21;Depth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;78;-785.2211,412.1388;Inherit;False;77;Scan;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;88;-1177.978,-284.1128;Inherit;False;ScanColour;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;19;-1260.647,-612.6697;Inherit;False;ScreenColour;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;82;-736.6284,310.4895;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;81;-480.122,290.2768;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;20;-658.2532,54.42265;Inherit;False;19;ScreenColour;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;89;-665.8827,154.5076;Inherit;False;88;ScanColour;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCGrayscale;90;-1570.123,-474.5054;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;91;-1315.061,-376.1722;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;17;-200.8612,163.1862;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;22.39759,168.4597;Float;False;True;-1;2;ASEMaterialInspector;0;2;Scan;c71b220b631b6344493ea3cf87110c93;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;True;True;2;False;-1;True;7;False;-1;False;True;0;False;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;63;0;47;0
WireConnection;63;1;56;0
WireConnection;99;0;63;0
WireConnection;93;0;99;0
WireConnection;98;0;96;0
WireConnection;98;1;102;0
WireConnection;97;0;98;0
WireConnection;97;1;105;0
WireConnection;86;0;94;0
WireConnection;86;1;87;0
WireConnection;106;0;97;0
WireConnection;73;0;84;0
WireConnection;11;0;2;0
WireConnection;11;1;15;0
WireConnection;76;0;86;0
WireConnection;76;1;73;0
WireConnection;111;0;106;0
WireConnection;107;0;111;0
WireConnection;23;0;11;0
WireConnection;23;1;24;0
WireConnection;71;0;76;0
WireConnection;69;0;71;0
WireConnection;69;1;70;0
WireConnection;85;0;23;0
WireConnection;109;0;69;0
WireConnection;109;1;110;0
WireConnection;21;0;85;0
WireConnection;77;0;109;0
WireConnection;10;0;9;0
WireConnection;88;0;18;0
WireConnection;19;0;10;0
WireConnection;82;0;22;0
WireConnection;81;0;82;0
WireConnection;81;1;78;0
WireConnection;90;0;10;0
WireConnection;91;0;90;0
WireConnection;91;1;18;0
WireConnection;17;0;20;0
WireConnection;17;1;89;0
WireConnection;17;2;81;0
WireConnection;1;0;17;0
ASEEND*/
//CHKSM=C25B799DADF970494E81B884419642A78388CA4B