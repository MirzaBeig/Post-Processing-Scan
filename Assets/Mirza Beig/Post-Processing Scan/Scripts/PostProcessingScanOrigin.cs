using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class PostProcessingScanOrigin : MonoBehaviour
{
    public Material material;

    void Start()
    {

    }

    void LateUpdate()
    {
        material.SetVector("_Origin", transform.position);
    }
}
