package vo
{
	import mx.collections.ArrayCollection;

	public class EcuacionRectaVO
	{
		public var pendiente:Number;
		public var coefCorte:Number;
		public var id:String;
		public var arrPtos:ArrayCollection = new ArrayCollection();
		public var ordAsoc:Object;
		public var resultado:int;
		public var velaSalida:Object;
		public function EcuacionRectaVO()
		{
			
		}
	}
}