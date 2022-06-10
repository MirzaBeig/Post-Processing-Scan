
#if UNITY_POST_PROCESSING_STACK_V2

using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[Serializable]
[PostProcess(typeof(PostProcessingScanRenderer), PostProcessEvent.BeforeStack, "Mirza Beig/Post-Processing Scan (PPSv2)", true)]
public sealed class PostProcessingScan : PostProcessEffectSettings
{
    [Tooltip("Origin")]
    public Vector3Parameter _Origin = new Vector3Parameter { value = new Vector3(0.0f, 0.0f, 0.0f) };

    [Tooltip("Colour")]
    [ColorUsage(true, true)]
    public ColorParameter _Colour = new ColorParameter { value = Color.white };

    [Space]

    [Tooltip("Power")]
    public FloatParameter _Power = new FloatParameter { value = 10.0f };

    [Space]

    [Tooltip("Tiling")]
    public FloatParameter _Tiling = new FloatParameter { value = 1.0f };

    [Tooltip("Speed")]
    public FloatParameter _Speed = new FloatParameter { value = 1.0f };

    [Header("Mask")]

    [Tooltip("Mask Radius")]
    public FloatParameter _MaskRadius = new FloatParameter { value = 5.0f };

    [Tooltip("Mask Hardness")]
    [Range(0.0f, 1.0f)]
    public FloatParameter _MaskHardness = new FloatParameter { value = 1.0f };

    [Tooltip("Mask Power")]
    public FloatParameter _MaskPower = new FloatParameter { value = 1.0f };

    //[Range(1, 10)]
    //public IntParameter iterations;
}

public sealed class PostProcessingScanRenderer : PostProcessEffectRenderer<PostProcessingScan>
{
    public override void Render(PostProcessRenderContext context)
    {
        var sheet = context.propertySheets.Get(Shader.Find("Mirza Beig/Post-Processing Scan (PPSv2)"));

        sheet.properties.SetColor("_Colour", settings._Colour);
        sheet.properties.SetVector("_Origin", settings._Origin);
        sheet.properties.SetFloat("_Power", settings._Power);
        sheet.properties.SetFloat("_Tiling", settings._Tiling);
        sheet.properties.SetFloat("_Speed", settings._Speed);
        sheet.properties.SetFloat("_MaskRadius", settings._MaskRadius);
        sheet.properties.SetFloat("_MaskHardness", settings._MaskHardness);
        sheet.properties.SetFloat("_MaskPower", settings._MaskPower);

        context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);
    }
}

#endif
