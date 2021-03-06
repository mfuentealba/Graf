package controlador
{
	
	import com.adobe.serialization.json.JSON;
	
	import componentes.clases.Callback;
	
	import eventos.DataTranferidaEvent;
	import eventos.GeneraDataEvent;
	
	import flash.data.SQLResult;
	import flash.events.DataEvent;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	
	import modelo.Modelo;
	
	import mx.charts.chartClasses.DataTransform;
	import mx.charts.series.LineSeries;
	import mx.collections.ArrayCollection;
	import mx.core.ApplicationGlobals;
	import mx.core.FlexGlobals;
	import mx.events.CollectionEvent;
	import mx.managers.PopUpManager;
	import mx.rpc.Responder;
	import mx.rpc.events.ResultEvent;
	
	import servicios.DelegadoNode;
	
	import spark.components.Application;
	import spark.components.Button;
	
	import vo.EcuacionRectaVO;
	import vo.NodoPendientes;
	
	
	public class Controlador extends EventDispatcher
	{
		private static var controladorGeneral:Controlador;
		[Bindable] private var modelApp:Modelo = Modelo.getInstance();
		[Bindable] private var dlNode:DelegadoNode = DelegadoNode.getInstance();
		public var fnProc:Function;
		
		
		public static function getInstance():Controlador
		{
			if ( controladorGeneral == null ){
				controladorGeneral = new Controlador();
				
			}
			
			return controladorGeneral;
		}
		
		
		public function Controlador(target:IEventDispatcher=null)
		{
			if(controladorGeneral){
				throw new Error("Singleton... use getInstance()");
			} 
			controladorGeneral = this;
			inic();
		}
		
		
		
		public function inic():void{
			
			addEventListener(GeneraDataEvent.GENERA_DATA, despachar);
			addEventListener(GeneraDataEvent.GENERA_PIP, despachar);
			addEventListener(GeneraDataEvent.GENERA_POR_PIP, despachar);
			addEventListener(GeneraDataEvent.RESET_PIP, despachar);
			addEventListener(GeneraDataEvent.EPREFRESH, despachar);
			fnProc = fnInicial;
			dlNode.callbackRecep = callbackRecep;
			
		}
		
		
		
		
		
		private function despachar(event:*):void{
			switch(event.clase){
				case 'GeneraDataEvent':
					//var sesionEvent:SesionEvent = event as SesionEvent;
					switch(event.type){
						case GeneraDataEvent.GENERA_DATA:
							DelegadoNode.getInstance().generaData(event, null);
							break;
						//DelegadoSQLite.getInstance().fnDelegado(fn del controller que actualiza vista, fn callback del evento para alguna otra actualizacion mas visual)
						case GeneraDataEvent.GENERA_PIP:
							DelegadoNode.getInstance().generaPip(event, null);
							break;
						case GeneraDataEvent.GENERA_POR_PIP:
							DelegadoNode.getInstance().generaPorPip(event, null);
							break;
						case GeneraDataEvent.RESET_PIP:
							DelegadoNode.getInstance().resetPip(event, null);
							break;
						case GeneraDataEvent.EPREFRESH:
							DelegadoNode.getInstance().generaPipRefresh(event, null);
							break;
					}
					break;
			}
		}
		
		
		
		/*******Respuestas base de datos********/
		
		
		private function getConfigResultHandler(event:SQLResult):void{
			/****Fn que se ejecuta en respuesta de actualización de la vista ej: en el delegadosqlite getConfigResultHandler.execute(-1, new flash.net.Responder(getEventosResultHandler, onDBError));*****/
		}
		
		/***************NODEJS**************************************/
		
		public function fnRecalculaOrden(obj:*, index:int, array:Array):void{
			if(obj['divisa'] == 'EURUSD'){
				
				if(obj.estado != 'Cerrado'){
					modelApp.totalOperaciones = (Number(modelApp.totalOperaciones) - Number(obj['ganancia'])) + '';
					obj['ganancia'] += movEURUSD['mov'] * (obj['tipo'] == 'C' ? 1 : -1);
					obj['pip'] += movEURUSD['mov'] * (obj['tipo'] == 'C' ? 1 : -1);
					obj['spread'] = movEURUSD['spread'];
					modelApp.totalOperaciones = (Number(modelApp.totalOperaciones) + Number(obj['ganancia'])) + '';
					/*if(obj.sl > obj['ganancia']){
						obj.estado = 'Cerrado';
					} else {
						if(obj['ganancia'] > 100){
							obj.sl = obj['ganancia'] - 50;	
						}
						
					}*/
					/*if(obj.tp < obj['ganancia']){
						obj.estado = 'Cerrado';
					}*/
				}
				
			} else if(obj['divisa'] == 'USDCHF'){
				if(obj.estado != 'Cerrado'){
					modelApp.totalOperaciones = (Number(modelApp.totalOperaciones) - Number(obj['ganancia'])) + '';
					obj['ganancia'] += movUSDCHF['mov'] * (obj['tipo'] == 'C' ? 1 : -1);
					obj['pip'] += movUSDCHF['mov'] * (obj['tipo'] == 'C' ? 1 : -1);
					obj['spread'] = movUSDCHF['spread'];	
					modelApp.totalOperaciones = (Number(modelApp.totalOperaciones) + Number(obj['ganancia'])) + '';
				}
				
			}
			
		}
		
		
		
		public function fnRecalculaOrden3(obj:*, index:int, array:Array):void{
			if(obj.estado != 'Cerrado'){
				modelApp.totalOperaciones = (Number(modelApp.totalOperaciones) - Number(obj['ganancia'])) + '';
				obj['ganancia'] += movEURUSD['mov'] * (obj['tipo'] == 'C' ? 1 : -1);
				obj['pip'] += movEURUSD['mov'] * (obj['tipo'] == 'C' ? 1 : -1);
				obj['spread'] = movEURUSD['spread'];
				modelApp.totalOperaciones = (Number(modelApp.totalOperaciones) + Number(obj['ganancia'])) + '';
				if(obj.sl > obj['ganancia']){
					obj.estado = 'Cerrado';
				} else {
					if(obj['ganancia'] > 30){
						if(obj.sl < obj['ganancia'] - 30){
							obj.sl = obj['ganancia'] - 30;	
						}
					}
					
				}
				
				/*if(obj.tp < obj['ganancia']){
				obj.estado = 'Cerrado';
				}*/
			}			
		}
		
		
		
		public function fnRecalculaOrden2(obj:*, index:int, array:Array, opt:String):void{
			if(obj['divisa'] == 'EURUSD'){
				
				if(obj.estado != 'Cerrado' && opt == obj['tipo']){
					obj.estado = 'Cerrado';	
					modelApp.proyeccionAlcistaBL = false;
					modelApp.proyeccionBajistaBL = false;
					
				}
				
			} else if(obj['divisa'] == 'USDCHF'){
				if(obj.estado != 'Cerrado'){
					modelApp.totalOperaciones = (Number(modelApp.totalOperaciones) - Number(obj['ganancia'])) + '';
					obj['ganancia'] += movUSDCHF['mov'] * (obj['tipo'] == 'C' ? 1 : -1);
					obj['pip'] += movUSDCHF['mov'] * (obj['tipo'] == 'C' ? 1 : -1);
					obj['spread'] = movUSDCHF['spread'];	
					modelApp.totalOperaciones = (Number(modelApp.totalOperaciones) + Number(obj['ganancia'])) + '';
				}
				
			}
			
		}
		
		private var movEURUSD:Object;
		private var movUSDCHF:Object;
		
		
		
		private function fnGeneraLineaTendencia_y_orden(j:int, valorInicial:Object, objNuevo:Object, arrMin:ArrayCollection):void{
			var linea:EcuacionRectaVO = new EcuacionRectaVO();
			linea.pendiente = modelApp.proyeccionAlcista;
			linea.coefCorte = modelApp.corteMinAlcista;
			
			linea.arrPtos = new ArrayCollection();
			linea.arrPtos.addItem(valorInicial);
			linea.arrPtos.addItem(arrMin.removeItemAt(1));
			linea.arrPtos.addItem(arrMin.removeItemAt(1));
			
			
			
			Graf(FlexGlobals.topLevelApplication).removeEventListener(GeneraDataEvent.AUTOGENERACION, Graf(FlexGlobals.topLevelApplication).fnCicloGenerador);

			modelApp.arrTendencias.addItem(linea);
			var serieLinea:LineSeries = new LineSeries();
			serieLinea.yField = 'Tendencia_' + modelApp.arrTendencias.length;
			linea.id = serieLinea.yField;
			var arrTraspaso:Array = modelApp.grVelas.series;
			modelApp.grVelas.series = null;
			arrTraspaso.push(serieLinea);
			modelApp.grVelas.series = arrTraspaso;	
			var ini:int = modelApp.arrDataGrafVelas.length + (valorInicial['num'] - modelApp.contVela) - 1;
			var x:int = valorInicial['num'];
			var factor:int = 0;
			factor = valorInicial['num'];
			if(ini < 0){
				factor -= ini;
				ini = 0;
				 
			} else {
				
			}
			var fin:int = modelApp.arrDataGrafVelas.length + (objNuevo['num'] - modelApp.contVela);
			var s:int = 0;
			for(x = ini; x <= fin; x++){
				var velaActualizar:Object = modelApp.arrDataGrafVelas.getItemAt(x);
				velaActualizar[serieLinea.yField] = modelApp.proyeccionAlcista * (factor + (s++)) + modelApp.corteMinAlcista;
				modelApp.arrDataGrafVelas.setItemAt(velaActualizar, x);
			}
			//if(!modelApp.proyeccionAlcistaBL && modelApp.proyeccionAlcista > 2){
				
				modelApp.proyeccionAlcistaBL = true;
				
				modelApp.corteMinAlcista = objNuevo['valor'] - objNuevo['num'] * modelApp.proyeccionAlcista;
				
				var obj:Object = modelApp.arrDataGraf.source[modelApp.arrDataGraf.length - 1];
				var item2:Object = {};
				
				item2 = {};
				item2.fecha = obj.fechaTrans;
				item2.ganancia = -obj.spreadEURUSD;
				item2.sl = -100;
				item2.tp = 500;
				item2.spread = -obj.spreadEURUSD;
				item2.pip = 0;
				item2.num = 'EURUSD|' + obj['id']; 
				item2.divisa = 'EURUSD';
				item2.tipo = 'C';
				item2.movIni = obj["movAcumEURUSD"];
				item2.estado = "Abierta";
				modelApp.totalOperaciones = (int(modelApp.totalOperaciones) + item2.ganancia) + '';
				modelApp.arrDataGrafOrdExec.addItem(item2);
				modelApp.arrDataGrafOrdExecGrilla.addItem(item2);
				linea.ordAsoc = item2;
				item2.ecu = linea;
			//}
		}
		
		
		private function fnGeneraOrdenLinea(tipo:String):void{
					
			Graf(FlexGlobals.topLevelApplication).removeEventListener(GeneraDataEvent.AUTOGENERACION, Graf(FlexGlobals.topLevelApplication).fnCicloGenerador);
					
			var obj:Object = modelApp.arrDataGraf.source[modelApp.arrDataGraf.length - 1];
			var item2:Object = {};
			
			item2 = {};
			item2.fecha = obj.fechaTrans;
			item2.ganancia = -obj.spreadEURUSD;
			item2.sl = -100;
			item2.tp = 500;
			item2.spread = -obj.spreadEURUSD;
			item2.pip = 0;
			item2.num = 'EURUSD|' + obj['id']; 
			item2.divisa = 'EURUSD';
			item2.tipo = tipo;
			item2.movIni = obj["movAcumEURUSD"];
			item2.estado = "Abierta";
			modelApp.totalOperaciones = (int(modelApp.totalOperaciones) + item2.ganancia) + '';
			modelApp.arrDataGrafOrdExec.addItem(item2);
			modelApp.arrDataGrafOrdExecGrilla.addItem(item2);
			
		}
		
		
		
		
		
		
		private function callbackRecep(result:DataEvent):void{
			var arrParam:Array = String(result.data).split('|');
			switch(arrParam[1]){
				case 'INI':
					var obj:Object = com.adobe.serialization.json.JSON.decode(arrParam[2]);
					var obj2:Object = com.adobe.serialization.json.JSON.decode(arrParam[3]);
					modelApp.txtSec = arrParam[4];
					obj["movAcumUSDCHF"] = obj2['movAcumUSDCHF'];
					/*if(modelApp.arrDataGraf.length > 500){
					//modelApp.arrDataGraf = new ArrayCollection();
					modelApp.arrDataGraf.source.splice(0, 1);
					
					}*/
					modelApp.arrDataGraf.addItem(obj);
					movEURUSD = {};
					movUSDCHF = {};
					movEURUSD['mov'] = obj["movEURUSD"];
					movUSDCHF['mov'] = obj2["movUSDCHF"];
					movEURUSD['spread'] = obj["spreadEURUSD"];
					movUSDCHF['spread'] = obj2["spreadUSDCHF"];
					modelApp.txtEURUSD = (int(obj["movAcumEURUSD"]) - int(obj['spread'])) + '';
					modelApp.txtUSDCHF = (int(obj2["movAcumUSDCHF"]) - int(obj2['spread'])) + '';
					modelApp.arrDataGrafOrdExec.source.forEach(fnRecalculaOrden);
					modelApp.arrDataGrafOrdExec.refresh();
					
					//trace(obj.dif)
					break;
				case 'INIPIP':
					obj = com.adobe.serialization.json.JSON.decode(arrParam[2]);
					
					
					//obj2 = com.adobe.serialization.json.JSON.decode(arrParam[3]);
					modelApp.txtSec = arrParam[3];
					if(modelApp.arrDataGraf.length > 10){
						//modelApp.arrDataGraf = new ArrayCollection();
						modelApp.arrDataGraf.removeItemAt(1);
						
						
					}
					
					/*modelApp.arrDataGrafPR.addItem(obj);
					modelApp.objDataGrafPR[obj['sec']] = {pos: modelApp.arrDataGrafPR.source.length - 1, obj: obj};*/
					
					
					
					if(modelApp.arrDataGrafVelas.length > 120){
						//modelApp.arrDataGraf = new ArrayCollection();
						
						modelApp.arrDataGrafVelas.removeItemAt(0);
						
					}
					
					modelApp.arrDataGrafOrdExec.source.forEach(fnRecalculaOrden);
					modelApp.arrDataGrafOrdExec.refresh();
					
					fnProc.call(this, obj, arrParam[4], arrParam[5]);
					
					
					
					
					
					
					
					
					//trace(obj.dif)
					break;
				
				
				case 'INIPIPREFRESH':
					obj = com.adobe.serialization.json.JSON.decode(arrParam[2]);
					/*
					var index:int = modelApp.arrDataGrafPR.getItemIndex(modelApp.objDataGrafPR[obj['sec']]['obj']);
					
					if(index < 0 ){
						
						obj2 = modelApp.arrDataGrafPR.source[modelApp.objDataGrafPR[obj['sec']]['pos']];
						
					} else {
						obj2 = modelApp.arrDataGrafPR.getItemAt(index);
						
					}
					
					for(var str:String in obj){
						obj2[str] = obj[str]; 
					}					
					if(index > -1 ){
						modelApp.arrDataGrafPR.setItemAt(obj2, index);
					}
					*/
					break;
				
				
				case 'ORD':
					obj = com.adobe.serialization.json.JSON.decode(arrParam[2]);
					obj2 = com.adobe.serialization.json.JSON.decode(arrParam[3]);
					obj["movAcumUSDCHF"] = obj2['movAcumUSDCHF'];
					//modelApp.arrDataGrafOrd.refresh();
					
					var obj3:Object = {};
					obj3.fecha = obj.fechaEURUSD;
					obj3.ganancia = (int(obj["movAcumEURUSD"]) - int(obj['spread'])) + (int(obj2["movAcumUSDCHF"]) - int(obj2['spread']));
					modelApp.arrDataGrafOrd.addItem(obj3);
					modelApp.txtEURUSD = (int(obj["movAcumEURUSD"]) - int(obj['spread'])) + '';
					modelApp.txtUSDCHF = (int(obj2["movAcumUSDCHF"]) - int(obj2['spread'])) + '';
					//trace(obj.dif)
					break;
				case 'EXECORDUSDCHF':
					obj = com.adobe.serialization.json.JSON.decode(arrParam[2]);
					
					var item:Object = {};
					item.fecha = obj.fechaTrans;
					item.ganancia = -obj.spreadUSDCHF;
					item.spread = -obj.spreadUSDCHF;
					item.pip = 0;
					item.num = 'USDCHF|' + obj['id'];
					item.divisa = 'USDCHF';
					item.tipo = obj['orden'];
					item.movIni = obj["movAcumUSDCHF"];
					item.estado = "Abierta";
					i = modelApp.arrDataGrafOrdExec.source.push(item);
					modelApp.objDataGrafOrdExec[item.num] = i - 1;
					modelApp.arrDataGrafOrdExec.refresh();
					break;
				
				case 'EXECORDEURUSD':
					obj = com.adobe.serialization.json.JSON.decode(arrParam[2]);
					
					item = {};
					item.fecha = obj.fechaTrans;
					item.ganancia = -obj.spreadEURUSD;
					item.spread = -obj.spreadEURUSD;
					item.pip = 0;
					item.num = 'EURUSD|' + obj['id']; 
					item.divisa = 'EURUSD';
					item.tipo = obj['orden'];
					item.movIni = obj["movAcumEURUSD"];
					item.estado = "Abierta";
					i = modelApp.arrDataGrafOrdExec.source.push(item);
					modelApp.objDataGrafOrdExec[item.num] = i - 1;
					modelApp.arrDataGrafOrdExec.refresh();
					break;
				case 'CLOSEORDUSDCHF':
					obj = com.adobe.serialization.json.JSON.decode(arrParam[2]);
					obj = com.adobe.serialization.json.JSON.decode(arrParam[2]);
					modelApp.arrDataGrafOrdExec.source[modelApp.objDataGrafOrdExec[obj['divisa'] + '|' + obj['id']]]['estado'] = 'Cerrado';
					modelApp.txtUSDCHFTotal = (Number(modelApp.txtUSDCHFTotal) + Number(obj['ganancia'])) + '';
					modelApp.arrDataGrafOrdExec.refresh();
					break;
				
				case 'CLOSEORDEURUSD':
					obj = com.adobe.serialization.json.JSON.decode(arrParam[2]);
					modelApp.arrDataGrafOrdExec.source[modelApp.objDataGrafOrdExec[obj['divisa'] + '|' + obj['id']]]['estado'] = 'Cerrado';
					modelApp.txtEURUSDTotal = (Number(modelApp.txtEURUSDTotal) + Number(obj['ganancia'])) + ''; 
					modelApp.arrDataGrafOrdExec.refresh();
					break;
				case 'NIVELEURUSD':
					obj = com.adobe.serialization.json.JSON.decode(arrParam[2]);
					obj2 = com.adobe.serialization.json.JSON.decode(arrParam[4]);
					if(modelApp.objDataNiveles.hasOwnProperty(obj2["clave"])){
						modelApp.arrDataNiveles.source[modelApp.objDataNiveles[obj2["clave"]]]['cant'] = obj2['cantidadPtos'] - obj2['cantidadCruce'];
					} else {
						item = {};					
						item.movIni = obj2["clave"];//obj["movAcumEURUSD"];
						item.divisa = 'EURUSD';
						item.mov = obj['tendencia'] + ' -> ' + arrParam[3];
						item.cant = 1;
						var i:int = modelApp.arrDataNiveles.source.push(item);
						modelApp.objDataNiveles[obj2["clave"]] = i - 1;
					}
					modelApp.arrDataNiveles.refresh();
					break;
				
				case 'NIVELUSDCHF':
					obj = com.adobe.serialization.json.JSON.decode(arrParam[2]);
					obj2 = com.adobe.serialization.json.JSON.decode(arrParam[4]);
					if(modelApp.objDataNiveles.hasOwnProperty(obj2["clave"])){
						modelApp.arrDataNiveles.source[modelApp.objDataNiveles[obj2["clave"]]]['cant'] = obj2['cantidadPtos'] - obj2['cantidadCruce'];						
					} else {
						item = {};					
						item.movIni = obj2["clave"];//obj["movAcumUSDCHF"];
						item.divisa = 'USDCHF';
						item.mov = obj['tendencia'] + ' -> ' + arrParam[3];
						item.cant = 1;
						i = modelApp.arrDataNiveles.source.push(item);
						modelApp.objDataNiveles[obj2["clave"]] = i - 1;
					}
					modelApp.arrDataNiveles.refresh();
					break;
				
			}
		}
		
		public var vela:Object;
		public function fnInicial(obj:Object, opt:String, serie:String):void{
			obj["movAcumUSDCHF"] = 0;
			obj["movAcumEURUSD"] = 0;
			obj["tendenciaEURUSD"] = 'N';
			obj["tendenciaUSDCHF"] = 'N';
			
			vela = {Open: 0,  High: 0, Low: 0, Close:0/*, arrMov: []*/};
			modelApp.arrDataGrafVelas.addItem(vela);
			vela = {Open: 0,  High: 0, Low: 0, Close:0/*, arrMov: []*/};
			modelApp.arrDataGrafVelas.addItem(vela);
			modelApp.arrDataGraf.addItem(obj);
			modelApp.contVela = 1;
			
			fnProc = fnSec;
			//modelApp.codPerIn++;
		}
		
		private function fnSec(obj:Object, opt:String, serie:String):void{
			
			try{
				obj["movAcumEURUSD"] = int((obj["precio_bidEURUSD"] - modelApp.arrDataGraf.source[0]["precio_bidEURUSD"]) * 100000);
				//obj["movAcumUSDCHF"] = int((obj2["precio_bidUSDCHF"] - modelApp.arrDataGraf.source[0]["precio_bidUSDCHF"]) * 100000);
				obj["movEURUSD"] = int((obj["precio_bidEURUSD"] - modelApp.arrDataGraf.source[modelApp.arrDataGraf.length - 1]["precio_bidEURUSD"]) * 100000);
				//obj["movUSDCHF"] = int((obj2["precio_bidUSDCHF"] - modelApp.arrDataGraf.source[modelApp.arrDataGraf.length - 1]["precio_bidUSDCHF"]) * 100000);
				obj['claveEURUSD'] = 'EURUSD|' + modelApp.arrDataGraf.source[modelApp.arrDataGraf.length - 1]["movAcumEURUSD"];
				
				if(obj["movEURUSD"] > 0){
					obj['tendenciaEURUSD'] = 'A';
				} else if(obj["movEURUSD"] < 0){
					obj['tendenciaEURUSD'] = 'B';
				} else {
					obj['tendenciaEURUSD'] = modelApp.arrDataGraf.source[modelApp.arrDataGraf.length - 1]["tendenciaEURUSD"];
				}
				
				
				movEURUSD = {};
				movUSDCHF = {};
				movEURUSD['mov'] = obj["movEURUSD"];
				movEURUSD['spread'] = obj["spreadEURUSD"];
				
				
				if(modelApp.codPerIn + 1 == modelApp.codPer){				
					
					modelApp.codPerIn = 0;
					
					modelApp.swEnvioClick = true;
					
					/****************************************-NIVELES-**********************************/
					vela = modelApp.arrDataGrafVelas.source[modelApp.arrDataGrafVelas.length - 1];
					var velaAnterior:Object = modelApp.arrDataGrafVelas.source[modelApp.arrDataGrafVelas.length - 2];
					
					
					vela.promedio = modelApp.promedioVela / modelApp.cantidadTRansVela;
					vela.cantidad = modelApp.cantidadTRansVela;
					
					modelApp.promedioVela = 0;
					modelApp.cantidadTRansVela = 0;
					
					/*
					if(vela.promedio < vela.Close){
						Graf(FlexGlobals.topLevelApplication).removeEventListener(GeneraDataEvent.AUTOGENERACION, Graf(FlexGlobals.topLevelApplication).fnCicloGenerador);
					}*/
					
					
					var item:Object;
					
					if(modelApp.contVela == 372){//1883
						modelApp.contVela = 372;
					}
					
					var objNuevo:Object = {num: vela['Close'] < velaAnterior['Close'] ? modelApp.contVela : modelApp.contVela - 1,  valor: vela['Close'] < velaAnterior['Close'] ? vela['Close'] : velaAnterior['Close']};
					if(modelApp.arrMinimos.length > 10){
						trace("tiene " + modelApp.arrMinimos.length + "NODOS DE MINIMOS" );
					}
					
					var arrElim:Array = [];
					var ptoElim:Object;
					var a:NodoPendientes;
					var n:int = modelApp.arrMinimos.length;
					
					/*
					if(modelApp.arrDataGrafVelas.length > 20){
						
						
						
						
						INDICADOR MEDIA MOVIL
						
						if(Math.abs(vela['rapida'] - vela['lenta']) < 5){
							modelApp.ordenEnabledConfirm++;
							if(modelApp.ordenEnabledConfirm > 5){
								modelApp.ordenEnabledConfirm = 5;
							}
						} else {
							modelApp.ordenEnabledConfirm--;
							if(modelApp.ordenEnabledConfirm < 0){
								modelApp.ordenEnabledConfirm = 0;
							}
						}
						
						
						if(modelApp.ordenEnabledConfirm > 4){
							modelApp.ordenEnabled = false;
						} else {
							modelApp.ordenEnabled = true;
						}	
					}*/
					
					
					
					for(var j:int = 0; j < n; j++){//ELIMINO LOS PUNTOS BASE MENORES AL NUEVO
						a = NodoPendientes(modelApp.arrMinimos.getItemAt(j));
						if(a.ptoInicial['valor'] > objNuevo['valor']){
							ptoElim = modelApp.arrMinimos.removeItemAt(j)['ptoInicial'];
							arrElim.push(ptoElim);
							j--;
							n--;
						} 	
					}
					for each(ptoElim in arrElim){//EN LAS PROYECCIONES DE CADA PUNTO SOBREVIVIENTE ELIMINO LOS PUNTOS ELIMINADOS
						for each(var nodo:NodoPendientes in modelApp.arrMinimos){
							
							for each(var arrPuntos:ArrayCollection in nodo.arrayPosibles){
								var ind:int = arrPuntos.getItemIndex(ptoElim);
								if(ind > -1){
									arrPuntos.removeItemAt(ind);
									if(arrPuntos.length == 0){
										nodo.arrayPosibles.removeItemAt(nodo.arrayPosibles.getItemIndex(arrPuntos));
									}	
								}	
							}	
						}	
						
					}
					
					/*
					INDICADOR MEDIA MOVIL
					
					modelApp.rapida += vela['Close'];
					modelApp.lenta += vela['Close'];
					if(modelApp.arrDataGrafVelas.length > 4){
						modelApp.rapida -= modelApp.arrDataGrafVelas.getItemAt(modelApp.arrDataGrafVelas.length - 5)['Close'];
						vela['rapida'] = modelApp.rapida / 4; 
					}
					
					if(modelApp.arrDataGrafVelas.length > 20){
						modelApp.lenta -= modelApp.arrDataGrafVelas.getItemAt(modelApp.arrDataGrafVelas.length - 21)['Close'];
						vela['lenta'] = modelApp.lenta / 20; 
					}
					
					
					if(velaAnterior['rapida'] < velaAnterior['lenta'] && vela['rapida'] > vela['lenta'] && !vela.hasOwnProperty('orden')){
						if(modelApp.arrDataGrafOrdExec.length > 0){
							if(modelApp.arrDataGrafOrdExec.getItemAt(modelApp.arrDataGrafOrdExec.length - 1)['ganancia'] < 0){
								modelApp.arrDataGrafOrdExec.getItemAt(modelApp.arrDataGrafOrdExec.length - 1)['estado'] = 'Cerrado';
								modelApp.arrDataGrafOrdExec.removeItemAt(modelApp.arrDataGrafOrdExec.length - 1)
							}
								
						}
						vela['orden'] = true;
						fnGeneraOrdenLinea('C');
					}
					
					if(velaAnterior['rapida'] > velaAnterior['lenta'] && vela['rapida'] < vela['lenta'] && !vela.hasOwnProperty('orden')){
						if(modelApp.arrDataGrafOrdExec.length > 0){
							if(modelApp.arrDataGrafOrdExec.getItemAt(modelApp.arrDataGrafOrdExec.length - 1)['ganancia'] < 0){
								modelApp.arrDataGrafOrdExec.getItemAt(modelApp.arrDataGrafOrdExec.length - 1)['estado'] = 'Cerrado';
								modelApp.arrDataGrafOrdExec.removeItemAt(modelApp.arrDataGrafOrdExec.length - 1)
							}
								
						}
						vela['orden'] = true;
						fnGeneraOrdenLinea('V');
					}
					
					
					*/
					
					
					
					
					modelApp.arrDataGrafOrdExec.source.forEach(fnRecalculaOrden3);
					modelApp.arrDataGrafOrdExec.refresh();
					
					
					if(velaAnterior['Open'] < velaAnterior['Close'] && vela['Open'] > vela['Close']){//verde-roja
						
						/*
						INDICADOR MEDIA MOVIL
						
						if(vela['rapida'] < vela['Close'] && vela['Close'] > vela['lenta']){
							fnGeneraOrdenLinea('V');
						}*/
						
						
						
						
						var nivel:int = vela['High'] <= velaAnterior['High'] ? velaAnterior['High'] : vela['High'];
						if(modelApp.objDataNiveles.hasOwnProperty('EURUSD|' + nivel)){
							var i:int = modelApp.arrDataNiveles.getItemIndex(modelApp.objDataNiveles['EURUSD|' + nivel]);
							item = modelApp.arrDataNiveles.getItemAt(i);
							item.mov = 'Resistencia';
							item.cant++;						
							var dist:int = modelApp.arrDataGraf.source[modelApp.arrDataGraf.length - 1]['sec'] - item.arrSec[item.arrSec.length - 1]['sec']; 
							item.arrSec.addItem({sec: modelApp.arrDataGraf.source[modelApp.arrDataGraf.length - 1]['sec'], dist: dist, vela: modelApp.arrDataGrafVelas.length - 1, accion: 'resistencia'});
							modelApp.arrDataNiveles.setItemAt(item, i);
						} else {
							item = {};			
							item.movIni = 'EURUSD|' + nivel;
							item.divisa = 'EURUSD';
							item.mov = 'Resistencia';
							item.cant = 1;
							item.arrSec = new ArrayCollection([{sec: modelApp.arrDataGraf.source[modelApp.arrDataGraf.length - 1]['sec'], dist: 0, vela: modelApp.arrDataGrafVelas.length - 1, accion: 'resistencia'}]);
							modelApp.arrDataNiveles.addItem(item);
							modelApp.objDataNiveles[item.movIni] = item;
						}
						
						
						
						
					} else if(vela['Open'] < vela['Close'] && velaAnterior['Open'] > velaAnterior['Close']){//roja-verde
						
						
						
						/*
						
						INDICADOR MEDIAS
						
						if(vela['rapida'] > vela['Close'] && vela['Close'] < vela['lenta']){
							fnGeneraOrdenLinea('C');
						}*/
						/*nivel = vela['Low'] <= velaAnterior['Low'] ? vela['Low'] : velaAnterior['Low'];  
						if(modelApp.objDataNiveles.hasOwnProperty('EURUSD|' + nivel)){
						i = modelApp.arrDataNiveles.getItemIndex(modelApp.objDataNiveles['EURUSD|' + nivel]);
						item = modelApp.arrDataNiveles.getItemAt(i);
						item.mov = 'Soporte';
						item.cant++;						
						dist = modelApp.arrDataGraf.source[modelApp.arrDataGraf.length - 1]['sec'] - item.arrSec[item.arrSec.length - 1]['sec']; 
						item.arrSec.addItem({sec: modelApp.arrDataGraf.source[modelApp.arrDataGraf.length - 1]['sec'], dist: dist, vela: modelApp.arrDataGrafVelas.length - 1, accion: 'soporte'});
						modelApp.arrDataNiveles.setItemAt(item, i);
						} else {
						item = {};			
						item.movIni = 'EURUSD|' + nivel;
						item.divisa = 'EURUSD';
						item.mov = 'Soporte';
						item.cant = 1;
						item.arrSec = new ArrayCollection([{sec: modelApp.arrDataGraf.source[modelApp.arrDataGraf.length - 1]['sec'], dist: 0, vela: modelApp.arrDataGrafVelas.length - 1, accion: 'soporte'}]);
						modelApp.arrDataNiveles.addItem(item);
						modelApp.objDataNiveles[item.movIni] = item;
						}
						*/
						
						
						objNuevo.vela = vela;
						if(n == 0){
							a = new NodoPendientes();
							a.ptoInicial = objNuevo;
							modelApp.arrMinimos.addItem(a);
							modelApp.objMin[objNuevo.num] = a;
						} else {
							n = modelApp.arrMinimos.length;
							for(j = 0; j < n; j++){//UNA VEZ ELIMINADO DE TODOS LOS ARRAY LOS VALORES MAYORES PROCEDO A INSERTAR EL VALOR NUEVO
								nodo = NodoPendientes(modelApp.arrMinimos.getItemAt(j));
								if(nodo.arrayPosibles.length > 0){
									var m:int = nodo.arrayPosibles.length;
									for(var s:int = 0; s < m; s++){
										arrPuntos = ArrayCollection(nodo.arrayPosibles.getItemAt(s));
										var arrMin:ArrayCollection = new ArrayCollection([nodo.ptoInicial]);
										arrMin.addAll(arrPuntos);	
										var swPerteneceTendencia:Boolean = false;
										for each(var lin:EcuacionRectaVO in modelApp.arrTendencias){
											var res:Number = lin.pendiente * objNuevo['num'] + lin.coefCorte;
											if(objNuevo['valor'] >= res && objNuevo['valor'] - 10 <= res){
												//lin.arrPtos.addItem(objNuevo);COSUME RAM
												swPerteneceTendencia = true;
											}
										}
										
										if(!swPerteneceTendencia){
											var valorAnterior:Object = arrMin.getItemAt(arrMin.length - 1);
											arrMin.addItem(objNuevo);
											//Crea orden y saca proyeccion segun pendiente
											var valorInicial:Object = nodo.ptoInicial;
											modelApp.proyeccionAlcista = (valorInicial['valor'] - valorAnterior['valor']) / (valorInicial['num'] - valorAnterior['num']);
											modelApp.corteMinAlcista = valorAnterior['valor'] - valorAnterior['num'] * modelApp.proyeccionAlcista;
//											if(objNuevo['valor'] >= modelApp.proyeccionAlcista * objNuevo['num'] + modelApp.corteMinAlcista && objNuevo['valor'] - modelApp.proyeccionAlcista <= modelApp.proyeccionAlcista * objNuevo['num'] + modelApp.corteMinAlcista){
											if(objNuevo['valor'] >= modelApp.proyeccionAlcista * objNuevo['num'] + modelApp.corteMinAlcista && objNuevo['valor'] - modelApp.proyeccionAlcista <= modelApp.proyeccionAlcista * objNuevo['num'] + modelApp.corteMinAlcista){
												if(vela['promedio'] >= (vela['Close'] + vela['High']) / 2){
													
													
													
													fnGeneraLineaTendencia_y_orden(j, valorInicial, objNuevo, arrMin);
													
													
													
													nodo.arrayPosibles.removeItemAt(nodo.arrayPosibles.getItemIndex(arrPuntos));
													m--;
													s--;	
												}
												
												
											} else {
												if(objNuevo['valor'] < modelApp.proyeccionAlcista * objNuevo['num'] + modelApp.corteMinAlcista){
													arrMin.removeItemAt(arrMin.getItemIndex(valorAnterior));
													arrPuntos.removeItemAt(0);
													arrPuntos.addItem(objNuevo);
													//nodo.arrayPosibles.removeItemAt(nodo.arrayPosibles.getItemIndex(arrPuntos));
												} else {
													arrMin.removeItemAt(arrMin.length - 1);											
													if(!modelApp.objMin.hasOwnProperty(valorAnterior.num)){
														a = new NodoPendientes();
														a.ptoInicial = valorAnterior;
														a.arrayPosibles.addItem(new ArrayCollection([objNuevo]));
														modelApp.arrMinimos.addItem(a);
														modelApp.objMin[valorAnterior.num] = valorAnterior;
													}
													
													
												}
											}									
										}	
									}		
								} else {
									nodo.arrayPosibles.addItem(new ArrayCollection([objNuevo]));
								}
							}	
						}		
						
					}
					
					var velaAux:Object = modelApp.arrDataGrafVelas.getItemAt(modelApp.arrDataGrafVelas.length - 1);
					var ext:int = 1;
					for each(var ec:EcuacionRectaVO in modelApp.arrTendencias){					
						velaAux[ec.id] = (modelApp.contVela) * ec.pendiente + ec.coefCorte;
						if(velaAux[ec.id] > velaAux['Close'] || ec.ordAsoc['ganancia'] < ec.ordAsoc['sl']){
							if(ec.ordAsoc){
								ec.ordAsoc['estado'] = 'Cerrado';
								ec.resultado = ec.ordAsoc.ganancia; 
								ec.velaSalida = velaAux;
								velaAux.num = modelApp.contVela;
								modelApp.arrDataGrafOrdExec.setItemAt(ec.ordAsoc, modelApp.arrDataGrafOrdExec.getItemIndex(ec.ordAsoc)); 
								modelApp.proyeccionAlcistaBL = false;
								
								
							}
							modelApp.arrTendencias.removeItemAt(modelApp.arrTendencias.getItemIndex(ec));
							var arrTraspaso:Array = modelApp.grVelas.series;
							modelApp.grVelas.series = null;
							arrTraspaso.splice(ext, 1);
							modelApp.grVelas.series = arrTraspaso;
							
						} else {
							if(ec.ordAsoc['ganancia'] > 0){
								if(ec.ordAsoc.sl < ec.ordAsoc['ganancia'] - 30){
									ec.ordAsoc.sl = ec.ordAsoc['ganancia'] - 30;
								}
							}
							
						}
						ext++;
					}
					
					/**************************************************************/
					
					
					
					
					
					
					if(opt == 'S'){
						vela = {Open: obj["movAcumEURUSD"],  High: obj["movAcumEURUSD"], Low: obj["movAcumEURUSD"], Close:obj["movAcumEURUSD"]/*, arrMov: [obj["movAcumEURUSD"]]*/};
						modelApp.arrDataGrafVelas.addItem(vela);	
						modelApp.promedioVela += int(vela.Close);
						modelApp.cantidadTRansVela++;
						
					} else {/*
						SE CREA VELA NUEVA QUE EN EL MOMENTO EN QUE LLEGA UN NUEVO MOVIMIENTO SE REINICIARA PARA QUE ESE MOVIMIENTO SE TOME COMO EL PRIMER TIC Y NO EL CIERRE ANTERIOR; 
						SI LLEGASE A NO HABER MOV EN ESTA VELA ENTONCES SE DEJA COMO ESPACIO Y TENDRIA UNA VELA SIN MOVIMIENNTOS
						*/
						vela = modelApp.arrDataGrafVelas.source[modelApp.arrDataGrafVelas.length - 1];
						vela = {Open: vela["Close"],  High: vela["Close"], Low: vela["Close"], Close: vela["Close"]/*, arrMov: []*/};
						modelApp.arrDataGrafVelas.addItem(vela);	
						vela = null;
					}
					modelApp.contVela++;
					
					
				} else {
					if(serie == 'S'){/************SI HAY MAS DE UN PIP EN EL MISMO SEGUNDO NO SUMO***********************/
						modelApp.codPerIn++;	
					}
					
					if(opt == 'S'){/************ACTUALIZO VELA***********************/
						if(vela == null){
							vela = {Open: obj["movAcumEURUSD"],  High: obj["movAcumEURUSD"], Low: obj["movAcumEURUSD"], Close:obj["movAcumEURUSD"]/*, arrMov: [obj["movAcumEURUSD"]]*/};
							/*for each(ec in modelApp.arrTendencias){ ESTO EVALUABA CADA PIP Y ESO ERA MUCHO PROCESO, ADEMAS ES MAS IMPORTANTE EL CIERRE
							vela[ec.id] = modelApp.contVela * ec.pendiente + ec.coefCorte;
							}*/
							
							
						} else {
							vela = modelApp.arrDataGrafVelas.source[modelApp.arrDataGrafVelas.length - 1];	
						}
						
						vela['Close'] = obj["movAcumEURUSD"];
						modelApp.promedioVela += int(vela.Close);
						modelApp.cantidadTRansVela++;
						//vela['arrMov'].push(obj["movAcumEURUSD"]);
						if(obj["movAcumEURUSD"] > vela['High']){
							vela['High'] = obj["movAcumEURUSD"]; 
						} else if(obj["movAcumEURUSD"] < vela['Low']){
							vela['Low'] = obj["movAcumEURUSD"];
						}
						//trace(vela);
						modelApp.arrDataGrafVelas.setItemAt(vela, modelApp.arrDataGrafVelas.length - 1);
						velaAnterior = modelApp.arrDataGrafVelas.source[modelApp.arrDataGrafVelas.length - 2];
						modelApp.arrDataGrafVelas.setItemAt(vela, modelApp.arrDataGrafVelas.length - 1);
						
						
						if(modelApp.arrDataGrafVelas.length > 4){
							modelApp.rapida -= modelApp.arrDataGrafVelas.getItemAt(modelApp.arrDataGrafVelas.length - 5)['Close'];
							modelApp.rapida += vela['Close'];
							vela['rapida'] = modelApp.rapida / 4;
							modelApp.rapida -= vela['Close'];
							modelApp.rapida += modelApp.arrDataGrafVelas.getItemAt(modelApp.arrDataGrafVelas.length - 5)['Close'];
						}
						
						if(modelApp.arrDataGrafVelas.length > 20){
							modelApp.lenta -= modelApp.arrDataGrafVelas.getItemAt(modelApp.arrDataGrafVelas.length - 21)['Close'];
							modelApp.lenta += vela['Close'];
							vela['lenta'] = modelApp.lenta / 20;
							modelApp.lenta -= vela['Close'];
							modelApp.lenta += modelApp.arrDataGrafVelas.getItemAt(modelApp.arrDataGrafVelas.length - 21)['Close'];
						}
						
						
						if(velaAnterior['rapida'] < velaAnterior['lenta'] && vela['rapida'] > vela['lenta'] && !vela.hasOwnProperty('orden') && modelApp.ordenEnabled){
							if(modelApp.arrDataGrafOrdExec.length > 0){
								if(modelApp.arrDataGrafOrdExec.getItemAt(modelApp.arrDataGrafOrdExec.length - 1)['ganancia'] < 0){
									modelApp.arrDataGrafOrdExec.getItemAt(modelApp.arrDataGrafOrdExec.length - 1)['estado'] = 'Cerrado';
									modelApp.arrDataGrafOrdExec.removeItemAt(modelApp.arrDataGrafOrdExec.length - 1)
								}
								
							}
							vela['orden'] = true;
							fnGeneraOrdenLinea('C');
						}
						
						if(velaAnterior['rapida'] > velaAnterior['lenta'] && vela['rapida'] < vela['lenta'] && !vela.hasOwnProperty('orden') && modelApp.ordenEnabled){
							if(modelApp.arrDataGrafOrdExec.length > 0){
								if(modelApp.arrDataGrafOrdExec.getItemAt(modelApp.arrDataGrafOrdExec.length - 1)['ganancia'] < 0){
									modelApp.arrDataGrafOrdExec.getItemAt(modelApp.arrDataGrafOrdExec.length - 1)['estado'] = 'Cerrado';
									modelApp.arrDataGrafOrdExec.removeItemAt(modelApp.arrDataGrafOrdExec.length - 1)
								}
								
							}
							vela['orden'] = true;
							fnGeneraOrdenLinea('V');
						}
					}
					
					
					
					
				}
				
				modelApp.arrDataGraf.addItem(obj);	
			} catch (error : Error) {
				//  TRACE
				trace("_onDataReceived error:  " + error);
			} 
			//modelApp.arrDataGraf.refresh();
			//modelApp.arrDataGrafVelas.refresh();
			
		}
		
		private function confirmaMensaje(aEvent : *):void{
			
		}
		
	}
}