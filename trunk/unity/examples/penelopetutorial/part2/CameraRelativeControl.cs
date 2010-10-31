using UnityEngine;
using System.Collections;

[RequireComponent( typeof( CharacterController ) )]
public class CameraRelativeControl : MonoBehaviour
{
	
	
	public Joystick moveJoystick;
	public Joystick rotateJoystick;
	public Transform cameraTransform;
	public Transform cameraPivot;
	public Vector2 rotationSpeed = new Vector2( 50, 25 );
	public float speed = 6.0f;
	public float jumpSpeed = 16.0f;
	public float inAirMultiplier = 0.25f;
	
	private Vector3 velocity;
	private Transform thisTransform;
	private CharacterController character;
	
	void Start ()
	{
		thisTransform = (Transform) GetComponent( typeof( Transform ) );
		character = (CharacterController) GetComponent( typeof( CharacterController ) );
	}
	
	void FaceMovementDirection()
	{
		Vector3 horizontalVelocity = character.velocity;
		horizontalVelocity.y = 0.0f;
		if( horizontalVelocity.magnitude > 0.1f )
		{
			thisTransform.forward = horizontalVelocity.normalized;	
		}
	}
	
	void OnEndGame()
	{
		moveJoystick.Disable();
		rotateJoystick.Disable();
		this.enabled = false;
	}

	void Update ()
	{
		Vector3 movement = cameraTransform.TransformDirection( new Vector3( moveJoystick.position.x,
																		0.0f,
																		moveJoystick.position.y ) );
		movement.y = 0.0f;
		movement.Normalize();
		
		Vector2 absJoyPos = new Vector2( Mathf.Abs( moveJoystick.position.x ), 
											Mathf.Abs( moveJoystick.position.y ) );
		movement *= speed * ( ( absJoyPos.x > absJoyPos.y ) ? absJoyPos.x : absJoyPos.y );
		
		if( character.isGrounded )
		{
			if( rotateJoystick.tapCount == 2 )
			{
				velocity = character.velocity;
				velocity.y = jumpSpeed;
			}
		}
		else
		{
			velocity.y += Physics.gravity.y * Time.deltaTime;
			movement.x *= inAirMultiplier;
			movement.z *= inAirMultiplier;
		}
		
		movement += velocity;
		movement += Physics.gravity;
		
		movement *= Time.deltaTime;
		
		character.Move(movement);
		FaceMovementDirection();
		
		if( character.isGrounded )
		{
			velocity = Vector3.zero;
		}
		
		
		Vector2 camRotation = rotateJoystick.position;
		
		camRotation.x *= rotationSpeed.x;
		camRotation.y *= rotationSpeed.y;
		camRotation *= Time.deltaTime;
		
		cameraPivot.Rotate( 0, camRotation.x, 0, Space.World );
		cameraPivot.Rotate( camRotation.y, 0, 0 );
	}
}

