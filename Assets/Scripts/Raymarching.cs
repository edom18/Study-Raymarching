using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Raymarching : MonoBehaviour
{
    [SerializeField]
    private Transform _target = null;

    [SerializeField]
    private Transform _sphereTrans = null;

    private Material _material = null;
    private Camera _camera = null;
    private Transform _cameraTrans = null;
    private float _focalLength = 1.0f;

    private void Start()
    {
        _camera = GetComponent<Camera>();
        _cameraTrans = _camera.transform;

        _material = _target.GetComponent<Renderer>().material;
    }

    private void Update()
    {
        UpdateCamera();
        UpdateMaterial();
    }

    private void OnDrawGizmos()
    {
        if (!Application.isPlaying)
        {
            return;
        }
        Gizmos.color = Color.white;
        Gizmos.DrawFrustum(_cameraTrans.position, _camera.fieldOfView, _camera.farClipPlane, _camera.nearClipPlane, _camera.aspect);
    }

    private void UpdateCamera()
    {
        Vector3 delta = _target.position - _cameraTrans.position;
        float d = delta.magnitude;
        float th = Mathf.Atan(0.5f / d);
        _camera.fieldOfView = (th * Mathf.Rad2Deg) * 2f;
        _focalLength = d;
    }

    private void UpdateMaterial()
    {
        _material.SetVector("_CameraPos", new Vector4(_cameraTrans.position.x, _cameraTrans.position.y, _cameraTrans.position.z, 0.0f));
        _material.SetVector("_SpherePos", new Vector4(_sphereTrans.position.x, _sphereTrans.position.y, _sphereTrans.position.z, 0.0f));
        _material.SetFloat("_FocalLength", _focalLength);
    }
}
