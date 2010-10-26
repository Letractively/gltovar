using UnityEngine;
using System.Collections;

public class Boundary
{
	public Vector2 min = Vector2.zero;
	public Vector2 max = Vector2.zero;
}

public class Joystick : MonoBehaviour
{
	static private Joystick[] joysticks;
	static private bool enumeratedJoysticks = false;
	static private float tapTimeDelta = 0.3f;
	
	public Vector2 deadZone = Vector2.zero;
	public int tapCount;
	public Vector2 position;
	public bool normalize;
	
	private GUITexture gui;
	private Rect defaultRect;
	private Vector2 guiTouchOffset;
	private Boundary guiBoundary = new Boundary();
	private Vector2 guiCenter;
	private int lastFingerId = -1;
	
	private float tapTimeWindow;
	
	public void Start ()
	{
		gui = (GUITexture)GetComponent( typeof(GUITexture) );
		
		// get where the gui texture was originally placed
		defaultRect = gui.pixelInset;
		
		// get our offset for center instead of corner;
		guiTouchOffset.x = defaultRect.width * 0.5f;
		guiTouchOffset.y = defaultRect.height * 0.5f;
		
		guiBoundary.min.x = defaultRect.x - guiTouchOffset.x;
		guiBoundary.max.x = defaultRect.x + guiTouchOffset.x;
		guiBoundary.min.y = defaultRect.y - guiTouchOffset.y;
		guiBoundary.max.y = defaultRect.y + guiTouchOffset.y;
		
		guiCenter.x = defaultRect.x + guiTouchOffset.x;
		guiCenter.y = defaultRect.y + guiTouchOffset.y;
		
	}
	
	public void Reset()
	{
		gui.pixelInset = defaultRect;	
		lastFingerId = -1;
	}
	
	public void LatchedFinger( int fingerId )
	{
		if( lastFingerId == fingerId )
		{
			Reset();
		}
	}
	
	public void Disable()
	{
		gameObject.active = false;
		enumeratedJoysticks = false;
	}
	
	public void Update ()
	{	
		if( !enumeratedJoysticks ) 
		{
			joysticks = (Joystick[]) FindObjectsOfType( typeof(Joystick) );
			enumeratedJoysticks = true;
		}
		
		int count = Input.touchCount;
		
		if( tapTimeWindow > 0 )
		{
			tapTimeWindow -= Time.deltaTime;
		}
		else
		{
			tapCount = 0;
		}
		
		// no fingers are touching, so we reset the position
		if( count == 0 )
		{
			Reset();	
		}
		else
		{
			int i;
			for( i = 0; i < count; i++)
			{
				Touch touch = Input.GetTouch(i);
				
				Vector2 guiTouchPos = touch.position - guiTouchOffset;
				
				if( gui.HitTest( touch.position ) &&
					( (lastFingerId == -1) ||
					(lastFingerId != touch.fingerId) ) )
				{	
					lastFingerId = touch.fingerId;
					
					if( tapTimeWindow > 0 )
					{
						tapCount++;	
					}
					else
					{
						tapCount = 1;
						tapTimeWindow = tapTimeDelta;
					}
			
					foreach( Joystick j in joysticks )
					{
						if( j != this )
						{
							j.LatchedFinger( touch.fingerId );	
						}
					} 
				}
						
				if( lastFingerId == touch.fingerId )
				{
					if( touch.tapCount > tapCount )
					{
						tapCount = touch.tapCount;
					}
					
					Rect tempRect = gui.pixelInset;
					tempRect.x = Mathf.Clamp( guiTouchPos.x,
											guiBoundary.min.x,
											guiBoundary.max.x );
					tempRect.y = Mathf.Clamp( guiTouchPos.y,
											guiBoundary.min.y,
											guiBoundary.max.y );
					gui.pixelInset = tempRect;
					
					// another check to see if fingers are touching
					if( touch.phase == TouchPhase.Ended 
						|| touch.phase == TouchPhase.Canceled )
					{
						Reset();	
					}
				}
			}
		}
		
		position.x = ( gui.pixelInset.x + guiTouchOffset.x - guiCenter.x ) / guiTouchOffset.x;
		position.y = ( gui.pixelInset.y + guiTouchOffset.y - guiCenter.y ) / guiTouchOffset.y;
		
		
		float absoluteX = (float)Mathf.Abs( position.x );
		float absoluteY = (float)Mathf.Abs( position.y );
		if( absoluteX < deadZone.x )
		{
			position.x = 0.0f;	
		}
		else if( normalize )
		{
			position.x = Mathf.Sign( position.x ) * ( absoluteX - deadZone.x ) / (1 - deadZone.x );
		}
		
		if( absoluteY < deadZone.y )
		{
			position.y = 0.0f;
		}
		else if( normalize )
		{
			position.y = Mathf.Sign( position.y ) * ( absoluteY - deadZone.y ) / ( 1 - deadZone.y);
		}
	}
}
