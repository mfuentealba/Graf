package servicios
{
	
	
	
	import com.adobe.serialization.json.JSON;
	
	import componentes.clases.ConexionSocket;
	
	
	import flash.events.EventDispatcher;
	import flash.net.Responder;
	
	import flashx.textLayout.events.ModelChange;
	
	import modelo.Modelo;
	
	import mx.collections.ArrayCollection;
	import mx.managers.CursorManager;
	import mx.rpc.AsyncToken;
	import mx.rpc.Responder;
	import mx.rpc.events.ResultEvent;

	public class DelegadoNode extends EventDispatcher
	{
		
		
		protected var dbAsyncToken:AsyncToken;
		
		private var cache:ArrayCollection;
		
		public static const MOCK_ASYNC_TIME:int = 100;
		
		private var lastId:int;
		
		private static var delegado:DelegadoNode;
		private var connNode:ConexionSocket = Modelo.getInstance().conexion;
		private var _callbackRecep:Function;
		[Bindable] private var modelApp:Modelo = Modelo.getInstance();
		
		public static function getInstance():DelegadoNode
		{
			if ( delegado== null ){
				delegado = new DelegadoNode();
				
			}			
			return delegado;
		}
		
		public function DelegadoNode()
		{
			if(delegado){
				throw new Error("Singleton... use getInstance()");
				
			} 
			
			delegado = this;
			init();
		}
		
		private function init():void
		{
			
			/*****CREA EL DIRECTORIO QUE NECESITO PARA LA BASE****/
			connNode.callbackRecep = this.callbackRecep;

		}
		
		
		
		public function generaData(data:*, callback:Function):void{
			connNode.envia('GP|', callback);
		}
		
		
		public function generaPip(data:*, callback:Function):void{
			connNode.envia('EP|' + modelApp.codPer + '|', callback);
		}
		
		public function generaPipRefresh(data:*, callback:Function):void{
			connNode.envia('EPREFRESH|' + /*modelApp.codPer*/10800 + '|', callback);
		}
		
		public function generaPorPip(data:*, callback:Function):void{
			connNode.envia('EP2|', callback);
		}
		
		public function resetPip(data:*, callback:Function):void{
			connNode.envia('RESET|', callback);
		}
		

		public function get callbackRecep():Function
		{
			return _callbackRecep;
		}

		public function set callbackRecep(value:Function):void
		{
			_callbackRecep = value;
			this.connNode.callbackRecep = value;
		}
		
		
	}
}