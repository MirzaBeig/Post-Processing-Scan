using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class CustomRenderPassFeature : ScriptableRendererFeature
{
    [System.Serializable]
    public class CustomRenderPassSettings
    {
        public Material material;
        public RenderPassEvent renderPassEvent = RenderPassEvent.AfterRenderingTransparents;
    }

    CustomRenderPass m_ScriptablePass;
    public CustomRenderPassSettings settings = new CustomRenderPassSettings();

    /// <inheritdoc/>
    /// 
    public override void Create()
    {
        m_ScriptablePass = new CustomRenderPass(settings);
    }

    // Here you can inject one or multiple render passes in the renderer.
    // This method is called when setting up the renderer once per-camera.

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        //RenderTargetIdentifier source = renderer.cameraColorTarget;
        //m_ScriptablePass.Setup(source);

        renderer.EnqueuePass(m_ScriptablePass);
    }
}


