package
{
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.net.GroupSpecifier;
	import flash.net.NetConnection;
	import flash.net.NetGroup;
	import flash.text.TextField;
	
	public class Main extends Sprite
	{
		private const CirrusAddress:String = 'rtmfp://p2p.rtmfp.net/';
		private const DeveloperKey:String = 'YOUR KEY HERE!!!';
		private var _netConnection:NetConnection;
		private var _groupSpecifier:GroupSpecifier;
		private var _netGroup:NetGroup;
		private var _user:String;
		private var _connected:Boolean;
		private var _textfieldMessages:TextField;
		
		public function Main()
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void
		{
			// entry point
			
			_textfieldMessages = new TextField();
			_textfieldMessages.width = 400;
			_textfieldMessages.height = 400;
			_textfieldMessages.text = 'hi';
			addChild(_textfieldMessages);
			
			_netConnection = new NetConnection();
			_netConnection.addEventListener( NetStatusEvent.NET_STATUS, onNetStatus);
			_netConnection.connect( CirrusAddress + DeveloperKey );

			addEventListener(MouseEvent.CLICK, onClick);
			
		}
		
		private  function onClick(e:MouseEvent):void
		{
			sendMessage();
		}
		
		private function setupGroup():void
		{
			_groupSpecifier = new GroupSpecifier( 'com.gltovar.rtmfpdemos.testing' );
			_groupSpecifier.postingEnabled = true;
			
			_groupSpecifier.serverChannelEnabled = true;
			
			_netGroup = new NetGroup( _netConnection, _groupSpecifier.groupspecWithAuthorizations() );
			_netGroup.addEventListener( NetStatusEvent.NET_STATUS, onNetStatus );
			
			_user = 'user'+Math.round( Math.random()* 10000 );
		}
		
		private function onNetStatus(e:NetStatusEvent):void
		{
			switch( e.info.code )
			{
				case 'NetConnection.Connect.Success':
					write('connect success');
					setupGroup();
					break;
				case 'NetGroup.Connect.Success':
					write('group success');
					_connected = true;
					break;
				case 'NetGroup.Posting.Notify':
					receiveMessage( e.info.message );
					break;
			}
			
		}
		
		private function sendMessage():void
		{
			var message:Object = new Object();
			message.sender = _netGroup.convertPeerIDToGroupAddress(_netConnection.nearID);
			message.user = _user;
			message.text = 'testing ' + Math.round(Math.random()*100);
			
			_netGroup.post( message );
			receiveMessage( message );
			
		}
		
		private function receiveMessage( message:Object ):void
		{
			write( message.user+': '+message.text);
		}
		
		private function write(txt:String):void
		{
			_textfieldMessages.appendText( txt+'\n');
		}
		
	}
}