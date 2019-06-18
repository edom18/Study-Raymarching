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
        Matrix4x4 prev = Gizmos.matrix;
        Gizmos.matrix = _cameraTrans.localToWorldMatrix;
        Gizmos.DrawFrustum(Vector3.zero, _camera.fieldOfView, _camera.farClipPlane, _camera.nearClipPlane, _camera.aspect);

        Gizmos.color = Color.cyan;
        Gizmos.DrawLine(Vector3.zero, new Vector3(0, 0, _focalLength));

        Gizmos.color = Color.magenta;
        Gizmos.DrawLine(Vector3.zero, new Vector3(0,  0.5f, _focalLength));
        Gizmos.DrawLine(Vector3.zero, new Vector3(0, -0.5f, _focalLength));
        Gizmos.matrix = prev;
    }

    private void UpdateCamera()
    {
        Vector3 delta = _target.position - _cameraTrans.position;
        float d = delta.magnitude;
        float th = Mathf.Atan(0.5f / d);
        _camera.fieldOfView = (th * Mathf.Rad2Deg) * 2f;
        _target.transform.localScale = new Vector3(_camera.aspect, 1f, 1f);
        _focalLength = d;
    }

    private void UpdateMaterial()
    {
        _material.SetVector("_CameraPos", _cameraTrans.position);
        _material.SetVector("_CameraUp", _cameraTrans.up);
        _material.SetVector("_Target", _cameraTrans.position + _cameraTrans.forward);
        _material.SetVector("_SphereParam", new Vector4(_sphereTrans.position.x, _sphereTrans.position.y, _sphereTrans.position.z, _sphereTrans.lossyScale.x * 0.5f));
        _material.SetFloat("_FocalLength", _focalLength);
    }
}
