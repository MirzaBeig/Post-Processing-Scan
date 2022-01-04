using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Scan : MonoBehaviour
{
    public Material material;
    public Transform origin;

    void Start()
    {

    }

    void Update()
    {
        material.SetVector("_ScanOrigin", origin.position);
    }
}
