package modelo
{
	import componentes.clases.ConexionSocket;
	
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	
	import spark.components.Application;
	import spark.components.PopUpAnchor;
	
	
	

	[Bindable]
	public class Modelo
	{
		private static var modelLocator:Modelo;
		public var totalOperaciones:String = '0';
		public var mayorOperaciones:String = '0';
		public var menorOperaciones:String = '0';
		public var conexion:ConexionSocket = new ConexionSocket();
		public var arrDataGraf:ArrayCollection = new ArrayCollection();
		
		public var arrMinimos:ArrayCollection = new ArrayCollection();
		public var arrMaximos:ArrayCollection = new ArrayCollection();
		
		public var proyeccionAlcistaBL:Boolean;
		public var proyeccionAlcista:Number;
		public var corteMinAlcista:Number;
		
		
		
		
		public var arrDataGrafVelas:ArrayCollection = new ArrayCollection();
		public var codPer:int = 60;
		public var codPerIn:int = 0;
		public var arrDataGrafOrd:ArrayCollection = new ArrayCollection();
		public var arrDataGrafOrdExec:ArrayCollection = new ArrayCollection();
		public var objDataGrafOrdExec:Object = {};
		public var arrDataNiveles:ArrayCollection = new ArrayCollection();
		public var objDataNiveles:Object = {};
		public var txtEURUSD:String;
		public var txtEURUSDTotal:String = "0";
		public var txtUSDCHFTotal:String = "0";
		public var txtUSDCHF:String;
		public var txtSec:String;
		
		public var arrDataGrafPR:ArrayCollectionUp = new ArrayCollectionUp();
		public var arrDataGrafPROrig:ArrayCollectionMio = new ArrayCollectionMio();
		public var objDataGrafPR:Object = {};
		
		
/*		arrTipoIngreso.addItem({id: 1, nombre: 'Efectivo'}); 
		arrTipoIngreso.addItem({id: 2, nombre: 'Cheque al Día'}); 
		arrTipoIngreso.addItem({id: 3, nombre: 'Cheque a Fecha'}); 
		arrTipoIngreso.addItem({id: 4, nombre: 'Transferencia'});*/
		
		
		
		public static function getInstance():Modelo
		{
			if ( modelLocator == null ){
				modelLocator = new Modelo();
			}
				
			return modelLocator;
		}
		
		public function Modelo()
		{
			if(modelLocator){
				throw new Error("Singleton... use getInstance()");
			} 
			modelLocator = this;
		}
		
		
	}
}