package modelo
{
	import componentes.clases.ConexionSocket;
	
	import flash.sampler.NewObjectSample;
	import flash.utils.Timer;
	
	import mx.charts.CandlestickChart;
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
		public var conexion:ConexionSocket;
		public var arrDataGraf:ArrayCollection = new ArrayCollection();
		public var contVela:int;
		public var objMin:Object = {};
		public var swEnvioClick:Boolean = false;
		
		
		
		
		public var arrMinimos:ArrayCollection = new ArrayCollection();
		public var arrMinimosExcluidos:ArrayCollection = new ArrayCollection();
		public var arrMaximos:ArrayCollection = new ArrayCollection();
		
		public var proyeccionAlcistaBL:Boolean;
		public var proyeccionAlcista:Number;
		public var corteMinAlcista:Number;
		
		public var proyeccionBajistaBL:Boolean;
		public var proyeccionBajista:Number;
		public var corteMinBajista:Number;
		
		
		public var grVelas:CandlestickChart;
		public var arrTendencias:ArrayCollection = new ArrayCollection();
		
		
		
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