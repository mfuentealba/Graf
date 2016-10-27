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
	import mx.managers.PopUpManager;
	import mx.rpc.Responder;
	import mx.rpc.events.ResultEvent;
	
	import servicios.DelegadoNode;
	
	import spark.components.Application;
	import spark.components.Button;
	
	import vo.EcuacionRectaVO;
	
	
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
					if(obj.sl > obj['ganancia']){
						obj.estado = 'Cerrado';
					}
					if(obj.tp < obj['ganancia']){
						obj.estado = 'Cerrado';
					}
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
					
					modelApp.arrDataGrafPR.addItem(obj);
					modelApp.objDataGrafPR[obj['sec']] = {pos: modelApp.arrDataGrafPR.source.length - 1, obj: obj};
					
					
					
					if(modelApp.arrDataGrafVelas.length > 360){
						//modelApp.arrDataGraf = new ArrayCollection();
						
						modelApp.arrDataGrafVelas.source.splice(0, 1);
						
					}
					fnProc.call(this, obj, arrParam[4], arrParam[5]);
					modelApp.arrDataGrafOrdExec.source.forEach(fnRecalculaOrden);
					modelApp.arrDataGrafOrdExec.refresh();
					
					
					
					
					
					
					
					//trace(obj.dif)
					break;
				
				
				case 'INIPIPREFRESH':
					obj = com.adobe.serialization.json.JSON.decode(arrParam[2]);
					
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
			
			vela = {Open: 0,  High: 0, Low: 0, Close:0, arrMov: []};
			modelApp.arrDataGrafVelas.addItem(vela);
			vela = {Open: 0,  High: 0, Low: 0, Close:0, arrMov: []};
			modelApp.arrDataGrafVelas.addItem(vela);
			modelApp.arrDataGraf.addItem(obj);
			
			
			fnProc = fnSec;
			//modelApp.codPerIn++;
		}
		
		private function fnSec(obj:Object, opt:String, serie:String):void{
			
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
				/****************************************-NIVELES-**********************************/
				vela = modelApp.arrDataGrafVelas.source[modelApp.arrDataGrafVelas.length - 1];
				var velaAnterior:Object = modelApp.arrDataGrafVelas.source[modelApp.arrDataGrafVelas.length - 2];
				
				var item:Object;
				
				
				if(modelApp.proyeccionAlcistaBL){
					if(vela['Close'] + 10 < modelApp.proyeccionAlcista * (modelApp.arrDataGrafVelas.length - 1) + modelApp.corteMinAlcista && vela['arrMov'].length > 0){
						//cerrar Orden
						trace("Cerrar Orden");
						modelApp.arrDataGrafOrdExec.source.forEach(Callback.create(fnRecalculaOrden2, 'C'));
						modelApp.proyeccionAlcistaBL = false;
					}
				}
				
				
				if(modelApp.proyeccionBajistaBL){
					if(vela['close'] - 10 > modelApp.proyeccionBajista * (modelApp.arrDataGrafVelas.length - 1) + modelApp.corteMinBajista && vela['arrMov'].length > 0){
						//cerrar Orden
						trace("Cerrar Orden");
						modelApp.arrDataGrafOrdExec.source.forEach(Callback.create(fnRecalculaOrden2, 'V'));
						modelApp.proyeccionBajistaBL = false;
					}
				}
				
				
				
				
				if(velaAnterior['Open'] < velaAnterior['Close'] && vela['Open'] > vela['Close']){//verde-roja
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
					/*if((vela['High'] - vela['Low']) > (velaAnterior['High'] - velaAnterior['Low'])){
					modelApp.arrMinimos.addItem(vela);	
					}*/
					objNuevo = {num: vela['High'] > velaAnterior['High'] ? modelApp.arrDataGrafVelas.length - 1 : modelApp.arrDataGrafVelas.length - 2,  valor: vela['High'] > velaAnterior['High'] ? vela['High'] : velaAnterior['High']};
					if(modelApp.arrMaximos.length > 0){
						valorAnterior = modelApp.arrMaximos.getItemAt(modelApp.arrMaximos.length - 1);
						if(objNuevo['valor'] < valorAnterior['valor']){
							modelApp.arrMaximos.addItem(objNuevo);
							//Crea orden y saca proyeccion segun pendiente
							aux = modelApp.proyeccionBajista;
							modelApp.proyeccionBajista = (valorAnterior['valor'] - objNuevo['valor']) / (valorAnterior['num'] - objNuevo['num']);
							if(!modelApp.proyeccionBajistaBL && modelApp.proyeccionBajista < -2){
								modelApp.proyeccionBajistaBL = true;
								
								modelApp.corteMinBajista = objNuevo['valor'] - objNuevo['num'] * modelApp.proyeccionBajista;
								
								obj = modelApp.arrDataGraf.source[modelApp.arrDataGraf.length - 1];
								item2 = {};
								
								item2 = {};
								item2.fecha = obj.fechaTrans;
								item2.ganancia = -obj.spreadEURUSD;
								item2.sl = -100;
								item2.tp = 500;
								item2.spread = -obj.spreadEURUSD;
								item2.pip = 0;
								item2.num = 'EURUSD|' + obj['id']; 
								item2.divisa = 'EURUSD';
								item2.tipo = 'V';
								item2.movIni = obj["movAcumEURUSD"];
								item2.estado = "Abierta";
								modelApp.totalOperaciones = (int(modelApp.totalOperaciones) + item2.ganancia) + '';
								i = modelApp.arrDataGrafOrdExec.source.push(item2);
								modelApp.objDataGrafOrdExec[item2.num] = i - 1;
								modelApp.arrDataGrafOrdExec.refresh();
							} else {
								modelApp.proyeccionBajista = aux;
							}
						} else {
							modelApp.arrMaximos.setItemAt(objNuevo, modelApp.arrMaximos.length - 1);
						}
					} else {
						modelApp.arrMaximos.addItem(objNuevo);	
					}
					
									
					
				} else if(vela['Open'] < vela['Close'] && velaAnterior['Open'] > velaAnterior['Close']){//roja-verde
					nivel = vela['Low'] <= velaAnterior['Low'] ? vela['Low'] : velaAnterior['Low'];  
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
					/*if((vela['High'] - vela['Low']) > (velaAnterior['High'] - velaAnterior['Low'])){
					modelApp.arrMaximos.addItem(vela);	
					}*/
					var objNuevo:Object = {num: vela['Close'] < velaAnterior['Close'] ? modelApp.arrDataGrafVelas.length - 1 : modelApp.arrDataGrafVelas.length - 2,  valor: vela['Close'] < velaAnterior['Close'] ? vela['Close'] : velaAnterior['Close']};
					if(modelApp.arrMinimos.length > 0){
						var swPerteneceTendencia:Boolean = false;
						for each(var lin:EcuacionRectaVO in modelApp.arrTendencias){
							var res:Number = lin.pendiente * objNuevo['num'] + lin.coefCorte;
							if(objNuevo['valor'] >= res && objNuevo['valor'] - 10 <= res){
								lin.arrPtos.addItem(objNuevo);
								swPerteneceTendencia = true;
							}
						}
						
						if(!swPerteneceTendencia){
							var valorAnterior:Object = modelApp.arrMinimos.getItemAt(modelApp.arrMinimos.length - 1);
							modelApp.arrMinimos.addItem(objNuevo);
							//Crea orden y saca proyeccion segun pendiente
							if(modelApp.arrMinimos.length > 2){
								var valorInicial:Object = modelApp.arrMinimos.getItemAt(modelApp.arrMinimos.length - 3);
								aux = modelApp.proyeccionAlcista;
								modelApp.proyeccionAlcista = (valorInicial['valor'] - valorAnterior['valor']) / (valorInicial['num'] - valorAnterior['num']);
								modelApp.corteMinAlcista = valorAnterior['valor'] - valorAnterior['num'] * modelApp.proyeccionAlcista;
								if(objNuevo['valor'] >= modelApp.proyeccionAlcista * objNuevo['num'] + modelApp.corteMinAlcista && objNuevo['valor'] - 10 <= modelApp.proyeccionAlcista * objNuevo['num'] + modelApp.corteMinAlcista){
									var linea:EcuacionRectaVO = new EcuacionRectaVO();
									linea.pendiente = modelApp.proyeccionAlcista;
									linea.coefCorte = modelApp.corteMinAlcista;
									modelApp.arrMinimos.removeItemAt(modelApp.arrMinimos.getItemIndex(valorInicial));
									modelApp.arrMinimos.removeItemAt(modelApp.arrMinimos.getItemIndex(valorAnterior));
									modelApp.arrMinimos.removeItemAt(modelApp.arrMinimos.getItemIndex(objNuevo));
									modelApp.arrTendencias.addItem(linea);
									var serieLinea:LineSeries = new LineSeries();
									
									if(!modelApp.proyeccionAlcistaBL && modelApp.proyeccionAlcista > 2){
										
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
										i = modelApp.arrDataGrafOrdExec.source.push(item2);
										modelApp.objDataGrafOrdExec[item2.num] = i - 1;
										modelApp.arrDataGrafOrdExec.refresh();
									} else {
										if(objNuevo['valor'] < modelApp.proyeccionAlcista * objNuevo['num'] + modelApp.corteMinAlcista){
											if(objNuevo['valor'] < valorInicial['valor']){
												modelApp.arrMinimos.removeItemAt(modelApp.arrMinimos.getItemIndex(valorInicial));
												modelApp.arrMinimos.removeItemAt(modelApp.arrMinimos.getItemIndex(valorAnterior));
											} else {
												modelApp.arrMinimos.removeItemAt(modelApp.arrMinimos.getItemIndex(valorAnterior));
											}
										} else {
											modelApp.proyeccionAlcista = aux;
										}
										
										
									}		
								}
							}
							
							var aux:Number = modelApp.proyeccionAlcista;
							modelApp.proyeccionAlcista = (valorAnterior['valor'] - objNuevo['valor']) / (valorAnterior['num'] - objNuevo['num']);
								
						}
						
						
						/*if(objNuevo['valor'] > valorAnterior['valor']){
							
							
								 
							
						} else {
							modelApp.arrMinimos.setItemAt(objNuevo, modelApp.arrMinimos.length - 1);
						}*/
					} else {
						modelApp.arrMinimos.addItem(objNuevo);	
					}
					
					
				}
				if(opt == 'S'){
					vela = {Open: obj["movAcumEURUSD"],  High: obj["movAcumEURUSD"], Low: obj["movAcumEURUSD"], Close:obj["movAcumEURUSD"], arrMov: [obj["movAcumEURUSD"]]};
					modelApp.arrDataGrafVelas.addItem(vela);	
				} else {/*
					SE CREA VELA NUEVA QUE EN EL MOMENTO EN QUE LLEGA UN NUEVO MOVIMIENTO SE REINICIARA PARA QUE ESE MOVIMIENTO SE TOME COMO EL PRIMER TIC Y NO EL CIERRE ANTERIOR; 
					SI LLEGASE A NO HABER MOV EN ESTA VELA ENTONCES SE DEJA COMO ESPACIO Y TENDRIA UNA VELA SIN MOVIMIENNTOS
					*/
					vela = modelApp.arrDataGrafVelas.source[modelApp.arrDataGrafVelas.length - 1];
					vela = {Open: vela["Close"],  High: vela["Close"], Low: vela["Close"], Close: vela["Close"], arrMov: []};
					modelApp.arrDataGrafVelas.addItem(vela);	
					vela = null;
				}
				
			} else {
				if(serie == 'S'){/************SI HAY MAS DE UN PIP EN EL MISMO SEGUNDO NO SUMO***********************/
					modelApp.codPerIn++;	
				}
				
				if(opt == 'S'){/************ACTUALIZO VELA***********************/
					if(vela == null){
						vela = {Open: obj["movAcumEURUSD"],  High: obj["movAcumEURUSD"], Low: obj["movAcumEURUSD"], Close:obj["movAcumEURUSD"], arrMov: [obj["movAcumEURUSD"]]};
						modelApp.arrDataGrafVelas.setItemAt(vela, modelApp.arrDataGrafVelas.length - 1);
					} else {
						vela = modelApp.arrDataGrafVelas.source[modelApp.arrDataGrafVelas.length - 1];	
					}
					
					vela['Close'] = obj["movAcumEURUSD"];
					vela['arrMov'].push(obj["movAcumEURUSD"]);
					if(obj["movAcumEURUSD"] > vela['High']){
						vela['High'] = obj["movAcumEURUSD"]; 
					} else if(obj["movAcumEURUSD"] < vela['Low']){
						vela['Low'] = obj["movAcumEURUSD"];
					}
					//trace(vela);
					modelApp.arrDataGrafVelas.setItemAt(vela, modelApp.arrDataGrafVelas.length - 1); 
				}
				
			}
			
			modelApp.arrDataGraf.addItem(obj);
			//modelApp.arrDataGraf.refresh();
			//modelApp.arrDataGrafVelas.refresh();
			
		}
		
		private function confirmaMensaje(aEvent : *):void{
			
		}
		
	}
}