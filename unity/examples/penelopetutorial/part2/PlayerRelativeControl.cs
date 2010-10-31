using UnityEngine;
using System.Collections;

[RequireComponent( typeof( CharacterController ) )]
public class PlayerRelativeControl : MonoBehaviour
{
	public Joystick moveJoystick;
	public Joystick rotateJoystick;
	public Transform cameraPivot;
	public float forwardSpeed = 6;
	public float backwardSpeed = 3;
	public float sidestepSpeed = 4;
	public float jumpSpeed = 4;
	public float inAirMultiplier = 0.25f;
	public Vector2 rotationSpeed = new Vector2( 50, 25 );
	
	private Transform thisTransform;
	private CharacterController character;
	private Vector3 cameraVelocity;
	private Vector3 velocity;
	
	void Start ()
	{
		thisTransform = (Transform)GetComponent( typeof(Transform) );
		character = (CharacterController)GetComponent( typeof(CharacterController) );
	}
	
	void OnEndGame()
	{
		moveJoystick.Disable();
		rotateJoystick.Disable();
		this.enabled = false;
	}

	void Update ()
	{
		Vector3 movement = thisTransform.TransformDirection( new Vector3( moveJoystick.position.x,
																			0,
																			moveJoystick.position.y ) );
		movement.y = 0;
		movement.Normalize();
		
		Vector3 cameraTarget = Vector3.zero;
		Vector2 absJoyPos = new Vector2( Mathf.Abs( moveJoystick.position.x ),
											Mathf.Abs( moveJoystick.position.y ) );
		if( absJoyPos.y > absJoyPos.x )
		{
			if( moveJoystick.position.y > 0 )
			{
				movement *= forwardSpeed * absJoyPos.y;	
			}
			else
			{
				movement *= backwardSpeed * absJoyPos.y;
				cameraTarget.z = moveJoystick.position.y * 0.75f;
			}
		}
		else
		{
			movement *= sidestepSpeed * absJoyPos.x;
			cameraTarget.x = -moveJoystick.position.x * 0.5f;
		}
		
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
			cameraTarget.z = -jumpSpeed * 0.25f;
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
		
		Vector3 pos = cameraPivot.localPosition;
		pos.x = Mathf.SmoothDamp( pos.x, cameraTarget.x, ref cameraVelocity.x, 0.3f );
		pos.z = Mathf.SmoothDamp( pos.z, cameraTarget.z, ref cameraVelocity.z, 0.5f );
		cameraPivot.localPosition = pos;
		
		if( character.isGrounded )
		{
			var camRotation = rotateJoystick.position;
			camRotation.x *= rotationSpeed.x;
			camRotation.y *= rotationSpeed.y;
			camRotation *= Time.deltaTime;
			thisTransform.Rotate( 0, camRotation.x, 0, Space.World );
			cameraPivot.Rotate( camRotation.y, 0, 0 );
		}
		
		
	}
}

