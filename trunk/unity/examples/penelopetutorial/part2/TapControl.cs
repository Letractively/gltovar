using UnityEngine;
using System.Collections;

public class TapControl : MonoBehaviour
{
	
	public enum ControlState
	{
		WaitingForFirstTouch,
		WaitingForSecondTouch,
		MovingCharacter,
		WaitingForMovement,
		ZoomingCamera,
		RotatingCamera,
		WaitingForNoFingers
	}
	
	public float minimumTimeUntilMove = 0.25f;
	public bool zoomEnabled = true;
	public float zoomEpsilon = 25.0f;
	public bool rotateEnabled = true;
	public float rotateEpsilon = 10.0f;
	public GameObject cameraObject;
	public Transform cameraPivot;
	public GUITexture jumpButton;
	public float speed;
	public float jumpSpeed;
	public float inAirMultiplier = 0.25f;
	public float minimumDistanceToMove = 1.0f;
	public float zoomRate;
		
	private int state = (int)ControlState.WaitingForFirstTouch;
	private int[] fingerDown = new int[ 2 ];
	private Vector2[] fingerDownPosition = new Vector2[ 2 ];
	private int[] fingerDownFrame = new int [ 2 ];
	private float firstTouchTime;
	private ZoomCamera zoomCamera;
	private Camera cam;
	private Transform thisTransform;
	private CharacterController character;
	//private AnimationController animationController;
	private Vector3 targetLocation;
	private bool moving = false;
	private float rotationTarget;
	private float rotationVelocity;
	private Vector3 velocity;
	
	void Start ()
	{
		thisTransform = transform;
		zoomCamera = (ZoomCamera)cameraObject.GetComponent( typeof(ZoomCamera) );
		cam = cameraObject.camera;
		character = (CharacterController)GetComponent( typeof(CharacterController) );
		
		ResetControlState();
	}
	
	void CharacterControl()
	{
		int count = Input.touchCount;
		
		if( count == 1 && state == (int)ControlState.MovingCharacter ) 
		{
			Touch touch = Input.GetTouch(0);
			
			if( character.isGrounded && jumpButton.HitTest( touch.position ) )
			{
				velocity = character.velocity;
				velocity.y = jumpSpeed;
			}
			else if( !jumpButton.HitTest( touch.position ) && touch.phase != TouchPhase.Began )
			{
				RaycastHit hit;
				Ray ray = cam.ScreenPointToRay( new Vector3( touch.position.x, touch.position.y ) );
				if( Physics.Raycast( ray, out hit ) )
				{
					float touchDist = ( transform.position - hit.point ).magnitude;
					if( touchDist > minimumDistanceToMove )
					{
						targetLocation = hit.point;
					}
					moving = true;
				}
			}
		}
		
		Vector3 movement = Vector3.zero;
		
		if( moving )
		{
			movement = targetLocation - thisTransform.position;
			movement.y = 0;
			float dist = movement.magnitude;
			if( dist < 1 )
			{
				moving = false;
			}
			else
			{
				movement = movement.normalized * speed;
			}
		}
		
		if( !character.isGrounded )
		{
			velocity.y += Physics.gravity.y * Time.deltaTime;
			movement.x *= inAirMultiplier;
			movement.z *= inAirMultiplier;
		}
		
		movement += velocity;
		movement += Physics.gravity;
		movement *= Time.deltaTime;
		character.Move( movement );
		
		if( character.isGrounded )
		{
			velocity = Vector3.zero;
		}
		
		FaceMovementDirection();
	}
	
	void CameraControl( Touch touch0, Touch touch1 )
	{
		if( rotateEnabled && state == (int)ControlState.RotatingCamera )
		{
			// rotate stuff
			Vector2 currentVector = touch1.position - touch0.position;
			Vector2 currentDir = currentVector / currentVector.magnitude;
			Vector2 lastVector = ( touch1.position - touch1.deltaPosition) - 
									( touch0.position - touch0.deltaPosition );
			Vector2 lastDir = lastVector / lastVector.magnitude;
			float rotationCos = Vector2.Dot( currentDir, lastDir );
			
			if( rotationCos < 1 )
			{
				Vector3 currenctVector3 = new Vector3( currentVector.x, currentVector.y );
				Vector3 lastVector3 = new Vector3( lastVector.x, lastVector.y );
				float rotationDirection = Vector3.Cross( currenctVector3, lastVector3 ).normalized.z;
				float rotationRad = Mathf.Acos( rotationCos );
				rotationTarget += rotationRad * Mathf.Rad2Deg * rotationDirection;
				
				if( rotationTarget < 0 )
				{
					rotationTarget += 360;
				}
				else if( rotationTarget >= 360 )
				{
					rotationTarget -= 360;
				}
			}
		}
		else if( zoomEnabled && state == (int)ControlState.ZoomingCamera )
		{
			// zooming stuff
			float touchDistance = ( touch1.position - touch0.position ).magnitude;
			float lastTouchDistance = ( ( touch1.position - touch1.deltaPosition ) -
											( touch0.deltaPosition - touch0.deltaPosition ) ).magnitude;
			float deltaPinch = touchDistance - lastTouchDistance;
			
			zoomCamera.zoom += deltaPinch * zoomRate * Time.deltaTime;
		}
	}
		
	void FaceMovementDirection()
	{
		Vector3 horizontalVelocity = character.velocity;
		horizontalVelocity.y = 0;
		if( horizontalVelocity.magnitude > 0.1 )
		{
			thisTransform.forward = horizontalVelocity.normalized;
		}
	}
	
	void ResetControlState()
	{
		state = (int)ControlState.WaitingForFirstTouch;
		fingerDown[ 0 ] = -1;
		fingerDown[ 1 ] = -1;
	}
		
	void OnEndGame()
	{
		this.enabled = false;
	}
	
	void LateUpdate()
	{
		Vector3 tempVector3 = cameraPivot.eulerAngles;
		
		tempVector3.y = Mathf.SmoothDampAngle( cameraPivot.eulerAngles.y, 
															rotationTarget,
															ref rotationVelocity,
															0.3f );	
		cameraPivot.eulerAngles = tempVector3;
	}
	
	void Update ()
	{
		int touchCount = Input.touchCount;
		
		if( touchCount == 0 )
		{
			ResetControlState();
		}
		else
		{
			// everything else is going to go here
			int i;
			Touch touch;
			Touch[] touches = Input.touches;
			Touch touch0 = new Touch();
			Touch touch1 = new Touch();
			bool gotTouch0 = false;
			bool gotTouch1 = false;
			
			if( state == (int)ControlState.WaitingForFirstTouch )
			{
				for( i = 0; i < touchCount; i++ )
				{
					touch = touches[ i ];
					
					if( touch.phase != TouchPhase.Ended &&
						touch.phase != TouchPhase.Canceled )
					{
						state = (int)ControlState.WaitingForSecondTouch;
						firstTouchTime = Time.time;
						fingerDown[ 0 ] = touch.fingerId;
						fingerDownPosition[ 0 ] = touch.position;
						fingerDownFrame[ 0 ] = Time.frameCount;
						break;
					}
				}
			}
			
			if( state == (int)ControlState.WaitingForSecondTouch )
			{
				for( i = 0; i < touchCount; i++ )
				{
					touch = touches[ i ];
					if( touch.phase != TouchPhase.Canceled )
					{
						if( touchCount >= 2 &&
							touch.fingerId != fingerDown [ 0 ] )
						{
							state = (int)ControlState.WaitingForMovement;
							fingerDown[ 1 ] = touch.fingerId;
							fingerDownPosition[ 1 ] = touch.position;
							fingerDownFrame[ 1 ] = Time.frameCount;
							break;
						}
						else if ( touchCount == 1 )
						{
							Vector2 deltaSinceDown = touch.position - fingerDownPosition[ 0 ];
							if( touch.fingerId == fingerDown[ 0 ] &&
								( Time.time > firstTouchTime + minimumTimeUntilMove ||
									touch.phase == TouchPhase.Ended ) ) 
							{
								state = (int)ControlState.MovingCharacter;
								break;
							}
						}	
					}
				}
			}
			
			if( state == (int)ControlState.WaitingForMovement )
			{
				for( i = 0; i < touchCount; i++ )
				{
					touch = touches[ i ];
					if( touch.phase == TouchPhase.Began )
					{
						if( touch.fingerId == fingerDown[ 0 ] &&
							fingerDownFrame[ 0 ] == Time.frameCount )
						{
							touch0 = touch;
							gotTouch0 = true;
						}
						else if( touch.fingerId != fingerDown[ 0 ] &&
								touch.fingerId != fingerDown[ 1 ] )
						{
							fingerDown[ 1 ] = touch.fingerId;
							touch1 = touch;
							gotTouch1 = true;
						}
					}
					
					if( touch.phase == TouchPhase.Moved || 
					touch.phase == TouchPhase.Stationary ||
					touch.phase == TouchPhase.Ended )
					{
						if( touch.fingerId == fingerDown[ 0 ] )
						{
							touch0 = touch;
							gotTouch0 = true;
						}
						else if( touch.fingerId == fingerDown[ 1 ] )
						{
							touch1 = touch;
							gotTouch1 = true; 
						}
					}
				}
				
				if( gotTouch0 ) 
				{
					if( gotTouch1 )
					{
						Vector2 originalVector = fingerDownPosition[ 1 ] - fingerDownPosition[ 0 ];
						Vector2 currentVector = touch1.position - touch0.position;
						Vector2 originalDir = originalVector / originalVector.magnitude;
						Vector2 currentDir = currentVector / currentVector.magnitude;
						float rotationCos = Vector2.Dot( originalDir, currentDir );
						
						if( rotationCos < 1 )
						{
							float rotationRad = Mathf.Acos( rotationCos );
							
							if( rotationRad > rotateEpsilon * Mathf.Deg2Rad )
							{
								state = (int)ControlState.RotatingCamera;
							}
						}
						
						if( state == (int)ControlState.WaitingForMovement )
						{
							float deltaDistance = originalVector.magnitude - currentVector.magnitude;
							
							if( Mathf.Abs( deltaDistance ) > zoomEpsilon )
							{
								state = (int)ControlState.ZoomingCamera;
							}
						}
					}
				}
				else
				{
					state = (int)ControlState.WaitingForNoFingers;
				}
			}
			
			if( state == (int)ControlState.RotatingCamera ||
			state == (int)ControlState.ZoomingCamera ) 
			{
				for( i = 0; i < touchCount; i++ )
				{
					touch = touches[ i ];
					
					if( touch.phase == TouchPhase.Moved ||
						touch.phase == TouchPhase.Stationary ||
						touch.phase == TouchPhase.Ended )
					{
						if( touch.fingerId == fingerDown[ 0 ] )
						{
							touch0 = touch;
							gotTouch0 = true;
						}
						else if( touch.fingerId == fingerDown[ 1 ] )
						{
							touch1 = touch;
							gotTouch1 = true;
						}
					}
				}
				
				if( gotTouch0 )
				{
					if( gotTouch1 )
					{
						// Call our Camera Control Function	
					}
				}
				else
				{
					state = (int)ControlState.WaitingForNoFingers;
				}
			}
		}
		
		//Debug.Log( state );
		
		CharacterControl();
	}
}

