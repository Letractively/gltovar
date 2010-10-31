using UnityEngine;
using System.Collections;

public class FollowTransform : MonoBehaviour
{
	public Transform targetTransform;
	public bool faceForward = false;
	
	private Transform thisTransform;
	
	void Start ()
	{
		thisTransform = transform;
	}
	
	void Update ()
	{
		thisTransform.position = targetTransform.position;
		
		if( faceForward )
		{
			thisTransform.forward = targetTransform.forward;	
		}
	}
}

