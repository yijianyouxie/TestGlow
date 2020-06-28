using UnityEngine;
using UnityEditor;


[ExecuteInEditMode]
public class Rotation : MonoBehaviour
{

    Transform tr;
    // Use this for initialization
    void Start()
    {
        tr = this.transform;
    }

    // Update is called once per frame
    void Update()
    {
        var ro = tr.eulerAngles;
        ro.y += 2;

        tr.eulerAngles = ro;
    }
}

