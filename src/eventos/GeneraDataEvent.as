package eventos
{
	import flash.events.Event;
	
	
	public class GeneraDataEvent extends Event
	{
		public static const GENERA_DATA:String = 'GeneraDataEvent';
		public static const GENERA_PIP:String = 'GeneraPipEvent';
		public static const GENERA_POR_PIP:String = 'GeneraPorPipEvent';
		public static const RESET_PIP:String = 'ResetPipEvent';
		public static const EPREFRESH:String = 'ResetPipRefreshEvent';
		
		
		public const clase:String = 'GeneraDataEvent';
		
		public function GeneraDataEvent(type:String)
		{
			super(type);
		}
	}
}