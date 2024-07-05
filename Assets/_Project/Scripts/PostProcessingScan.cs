
using UnityEngine;

[ExecuteAlways]
public class PostProcessingScan : MonoBehaviour
{
    public Material material;

    void Start()
    {

    }

    void LateUpdate()
    {
        material.SetVector("_Position", transform.position);
        material.SetFloat("_Radius", transform.lossyScale.x);
    }

    void OnDrawGizmos()
    {
        Gizmos.color = material.GetColor("_Colour");
        Gizmos.DrawWireSphere(transform.position, transform.lossyScale.x);
    }
}
