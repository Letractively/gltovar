using UnityEngine;
using System.Collections;

public class ZoomCamera : MonoBehaviour
{
	
	public Transform origin;
	public float zoom;
	public float zoomMin = -5.0f;
	public float zoomMax = 5.0f;
	public float seekTime = 1.0f;
	public bool smoothZoomIn = false;
	
	private Vector3 defaultLocalPosition;
	private Transform thisTransform;
	private float currentZoom;
	private float targetZoom;
	private float zoomVelocity;
	
	// Use this for initialization
	void Start ()
	{
		// Cache component instead of looking it up every frame
		thisTransform = transform;
		
		// The default position is the position that is set in the editor
		defaultLocalPosition = thisTransform.localPosition;
		
		// Default the current zoom to what was set in the editor
		currentZoom = zoom;
	}

	// Update is called once per frame
	void Update ()
	{
		// The zoom set externally must still be with in the min-max range
		zoom = Mathf.Clamp( zoom, zoomMin, zoomMax );
		
		// Only collide with non-Player (8) layers
		int layerMask = ~( (1 << 8) | (1 << 2) );
		
		RaycastHit hit;
		Vector3 start = origin.position;
		Vector3 zoomedPosition = defaultLocalPosition + thisTransform.parent.InverseTransformDirection( this.thisTransform.forward * zoom );
		Vector3 end = thisTransform.parent.TransformPoint( zoomedPosition );
		
		// Cast a line from the origin transform to the camera and find out if we hit anything in-between
		if( Physics.Linecast( start, end,out hit, layerMask ) )
		{
			// We hit something, so translate this to a zoom value
			Vector3 position = hit.point + thisTransform.TransformDirection( Vector3.forward );
			Vector3 difference = position - thisTransform.parent.TransformPoint( defaultLocalPosition );
			targetZoom = difference.magnitude;
		}
		else
		{
			// We didn't hit anything, so the camera should use the zoom set externally
			targetZoom = zoom;
		}
		
		// Clamp the target zoom to our min-max range
		targetZoom = Mathf.Clamp( targetZoom, zoomMin, zoomMax );
		
		if( !smoothZoomIn && ( targetZoom - currentZoom ) > 0 )
		{
			// Snap the current zoom to our target if it is closer. This is useful if
			// some object is between the camera and the origin
			currentZoom = targetZoom;
		}
		else
		{
			// Smoothly seek towards our target zoom value
			currentZoom = Mathf.SmoothDamp( currentZoom, targetZoom,ref zoomVelocity, seekTime );
		}
		
		// Set the position of the camera
		zoomedPosition = defaultLocalPosition + thisTransform.parent.InverseTransformDirection( thisTransform.forward * currentZoom );
		thisTransform.localPosition = zoomedPosition;
	}
}

