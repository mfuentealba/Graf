package componentes.clases
{
	
	import controlador.Controlador;
	
	import eventos.DataTranferidaEvent;
	import eventos.GeneraDataEvent;
	
	import flash.display.Sprite;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.net.XMLSocket;
	import flash.ui.Keyboard;
	
	import flashx.textLayout.events.ModelChange;
	
	import modelo.Modelo;
	
	import mx.core.FlexGlobals;
	import mx.managers.PopUpManager;

	public class ConexionSocket extends Sprite
	{
		
		public var _xmlSocket:XMLSocket;
		public var server:String = "192.168.2.4";
		public var port:int = 9003;
		public var callback:Function;
		public var callbackRecep:Function;
		public var funPostConexion:Function;
		[Bindable] private var modelApp:Modelo = Modelo.getInstance();
		public function ConexionSocket()
		{
			//this.ini();
			
		}
		
		public function ini():void{
			try{
				_xmlSocket = new XMLSocket(server, port);
				_xmlSocket.addEventListener(Event.CONNECT,          _onConnected);
				_xmlSocket.addEventListener(IOErrorEvent.IO_ERROR,  _onIOError);
				
				
				
			} catch(e:*) {
				
			}
			
		}
		
		private function _onConnected(aEvent : Event):void
		{
			//  TRACE
			trace("onConnect() aEvent: " + aEvent);
			
			//  EVENTS
			_xmlSocket.removeEventListener(Event.CONNECT,           _onConnected);
			_xmlSocket.removeEventListener(IOErrorEvent.IO_ERROR,   _onIOError);
			//
			_xmlSocket.addEventListener(DataEvent.DATA,             _onDataReceived);
			_xmlSocket.addEventListener(Event.CLOSE,                _onSocketClose);
			//
			//stage.addEventListener(KeyboardEvent.KEY_UP,            _onKeyUp);
			if(funPostConexion != null){
				funPostConexion.call(this);
			}
		}
		
		private function _onSocketClose(aEvent : Event):void
		{
			//  TRACE
			trace("_onSocketClose aEvent : " + aEvent);
			
			//  EVENTS
		//	stage.removeEventListener(KeyboardEvent.KEY_UP, _onKeyUp);
			_xmlSocket.removeEventListener(Event.CLOSE, _onSocketClose);
			_xmlSocket.removeEventListener(DataEvent.DATA, _onDataReceived);
		}
		
		private function _onKeyUp(evt:KeyboardEvent):void
		{
			//  HANDLE KEYS
			if (evt.keyCode == Keyboard.ESCAPE) {
				//1. SEND 'KILL THE SERVER' TO THE SERVER
				_xmlSocket.send("exit");
			}
			else {
				//2. SEND ANY NON-ESCAPE KEY'S CODE ('38' FOR EXAMPLE) TO SERVER
				//      THIS IS A SILLY EXAMPLE OF SENDING A NUMBER TO THE SERVER
				//      JUST SO THE SERVER CAN SEND IT BACK. SIMPLE.
				_xmlSocket.send(evt.keyCode);
			}
		}
		
		private function _onDataReceived(aEvent : DataEvent):void
		{
			try {
				
				//  Show the server data in text
				/*_textField.htmlText += ("From Server: " + aEvent.data + "n");
				
				//scroll down to show latest line
				_textField.scrollV = _textField.maxScrollV;*/
				var event:DataTranferidaEvent = new DataTranferidaEvent(DataTranferidaEvent.REGISTRA, String(aEvent.data));
				Controlador.getInstance().dispatchEvent(event);
				//trace(aEvent.data);
				if(String(aEvent.data).split('|')[0] == 'RECEP'){
					this.callbackRecep.call(this, aEvent);	
				} else {
					if(this.callback != null){
						this.callback.call(this, aEvent);	
					}	
				}
				 
				
				
			} catch (error : Error) {
				//  TRACE
				trace("_onDataReceived error:  " + error);
			} 
			if(modelApp.swEnvioClick && modelApp.contVela < modelApp.maxVelas){
				modelApp.swEnvioClick = false;
				var generaDataEvent:GeneraDataEvent = new GeneraDataEvent(GeneraDataEvent.AUTOGENERACION);
				FlexGlobals.topLevelApplication.dispatchEvent(generaDataEvent);
			}
			
		}
		
		private function _onIOError(aEvent : IOErrorEvent):void
		{
			//  TRACE
			trace("_onIOError aEvent: " + aEvent);
			
			//  EVENTS
			_xmlSocket.removeEventListener(Event.CONNECT, _onConnected);
			_xmlSocket.removeEventListener(IOErrorEvent.IO_ERROR, _onIOError);
			//stage.addEventListener(MouseEvent.CLICK, _onAddedToStage);
		}
		
		public function envia(msg:String, _callback:Function = null):void{
			var event:DataTranferidaEvent = new DataTranferidaEvent(DataTranferidaEvent.REGISTRA, String(msg));
			Controlador.getInstance().dispatchEvent(event);
			if(this._xmlSocket.connected == false){
				this.ini();
			}
			this.callback = _callback;
			this._xmlSocket.send(msg);
		}
		
		
	}
}