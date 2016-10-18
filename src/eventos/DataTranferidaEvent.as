package eventos
{
	import flash.events.Event;
	
	
	public class DataTranferidaEvent extends Event
	{
		public static const REGISTRA:String = 'registraEvent';
		
		
		public const clase:String = 'DataTranferidaEvent';
		public var msg:String = '';
		
		public function DataTranferidaEvent(type:String, _msg:String)
		{
			super(type);
			this.msg = _msg;
		}
	}
}