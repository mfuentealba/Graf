//console.log("Inicio 0.0.2");

var fs = require('fs');


var stream = fs.createWriteStream("./file2.txt");

var arrOrdAct = [];
var arrOrdFin = [];
var objOrdAct = {};
var objOrdFin = {};
var sec = 1;

var iEP = 0;
var jEP = 0;
var fechaEP;
var minEP;
var segEP;
var fechaEP_RESET;
var minEP_RESET;
var segEP_RESET;

function fnLog2(fd, msg){
    fs.readFile('./file.txt', 'utf8', null);
	stream.write(msg);
	stream.end();
}

/*stream.once('open', function(fd) {
  fnLog2(fs, "PRUEBA");
});
*/

var arrSocket = {};
var usuario = 0;
var net = require('net');
var eventos = require('events');
var EmisorEventos = eventos.EventEmitter; 
var ee = new EmisorEventos(); 
var ajusteBreak = 7;
var margenGanancia = 30;
var margenPerdida = -50;
var margenSecundarioGanancia = 20;
var margenSecundarioPerdida = 20;
var rupturaNivel = 2;
var fechaEjecucion = '2016.03.29';
var arrMinimosEURUSD = [];
var arrMaximosEURUSD = [];
var arrMinimosUSDCHF = [];
var arrMaximosUSDCHF = [];
var objMinimosEURUSD = {};
var objMaximosEURUSD = {};
var objMinimosUSDCHF = {};
var objMaximosUSDCHF = {};
var detTendencia = 3;


var bid = [1, 2, 3, 2, 1, 0, 5, 8, 7, 10, 12, 16, 30, 22];
var ask = [5, 6, 7, 6, 5, 4, 9, 12, 11, 14, 16, 20, 34, 26];

var mysql = require('mysql');

var connection = mysql.createPool({
  connectionLimit : 1000,
  host     : '127.0.0.1',
  user     : 'remate',
  password : 'remate',
  database : 'remate'
});

var arrResultEURUSD;
var arrResultUSDCHF;
var posibleNivelEURUSD = {};
var posibleNivelUSDCHF = {};
var segMin = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 1, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59]

var sqlExec = "SELECT `fecha`, max(`precio_bid`) precio_bid, max(`precio_ask`) precio_ask, 'EURUSD' FROM `precios` WHERE `nemo` = 'EURUSD' AND fecha like '" + fechaEjecucion + "%' GROUP BY fecha ORDER BY `precios`.`fecha` ASC"; 
dbExecute(sqlExec, fnEURUSD, []);

var sqlExec = "SELECT `fecha`, max(`precio_bid`) precio_bid, max(`precio_ask`) precio_ask, 'EURUSD' FROM `precios` WHERE `nemo` = 'USDCHF' AND fecha like '" + fechaEjecucion + "%' GROUP BY fecha ORDER BY `precios`.`fecha` ASC"; 
dbExecute(sqlExec, fnUSDCHF, []);

var EURUSD = {};
var USDCHF = {};
function fnEURUSD(err, results, fields, arrParam){
	if(err) {    
		console.log('[ERROR EN CONSULTA]');
	}
	else {    
	console.log('[FIN CONSULTA]');
		if(results.length > 0){
			for(var i = 0; i < results.length; i++){				
				EURUSD[results[i]['fecha']] = results[i];
			}
			
			
			arrResultEURUSD = results;
			if(arrResultEURUSD[0]['fecha'] < arrResultUSDCHF[0]['fecha']){
				//console.log("MANDA EURUSD");
				fechaEP = arrResultEURUSD[0]['fecha'].split(' ')[1];
				minEP = parseInt(fechaEP.split(':')[1]);
				segEP = parseInt(fechaEP.split(':')[2]);				
				fechaEP_RESET = arrResultEURUSD[0]['fecha'].split(' ')[1];
				minEP_RESET = parseInt(fechaEP.split(':')[1]);
				segEP_RESET = parseInt(fechaEP.split(':')[2]);				
			} else {
				//console.log("MANDA USDCHF");
				fechaEP = arrResultUSDCHF[0]['fecha'].split(' ')[1];
				minEP = parseInt(fechaEP.split(':')[1]);
				segEP = parseInt(fechaEP.split(':')[2]);
				fechaEP_RESET = arrResultUSDCHF[0]['fecha'].split(' ')[1];
				minEP_RESET = parseInt(fechaEP.split(':')[1]);
				segEP_RESET = parseInt(fechaEP.split(':')[2]);
			}
		}
	}	
}
function fnUSDCHF(err, results, fields, arrParam){
	if(err) {    
		console.log('[ERROR EN CONSULTA]');
	}
	else {    
	console.log('[FIN CONSULTA]');
		if(results.length > 0){
			for(var i = 0; i < results.length; i++){				
				USDCHF[results[i]['fecha']] = results[i];
			}
			
			
			arrResultUSDCHF = results;
		/*	if(arrResultEURUSD[0]['fecha'] < arrResultUSDCHF[0]['fecha']){
				//console.log("MANDA EURUSD");
				fecha = arrResultEURUSD[0]['fecha'].split(' ')[1];
				min = parseInt(fecha.split(':')[1]);
				seg = parseInt(fecha.split(':')[2]);				
			} else {
				//console.log("MANDA USDCHF");
				fecha = arrResultUSDCHF[0]['fecha'].split(' ')[1];
				min = parseInt(fecha.split(':')[1]);
				seg = parseInt(fecha.split(':')[2]);
			}*/
			////console.log(arrResult);
			/*for(var i = 0; i < results.length; i++){
				arrResult = JSON.stringify(results[i]);
				resultados += '|';
			}*/
		}
	}	
}



function sleep(milliseconds) {
  var start = new Date().getTime();
  for (var i = 0; i < 1e7; i++) {
    if ((new Date().getTime() - start) > milliseconds){
      break;
    }
  }
}



function dbExecute(queryExec, fnCallback, arrParam, arrParamQuery){
	connection.getConnection(function(err,conn){
		if (err) {
			//console.log(err);
			conn.release();
			//console.log({"code" : 100, "status" : "Error in connection database"});
			return;
		}   
		////console.log(conn);
		//console.log('connected as id ' + conn.threadId);

		conn.query(queryExec, arrParamQuery, function(err, results, fields){
				if(fnCallback != null){
					fnCallback(err, results, fields, arrParam);			
				}
				conn.release();

			});

		conn.on('error', function(err) {      
		   //console.log({"code" : 100, "status" : "Error in connection database"});
		   return;     
		});
   });

}

ee.on('datos', function(fecha){
   //console.log(fecha);
});
/*setInterval(function(){
   ee.emit('datos', Date.now());
}, 500); 
*/
function onConnect()
{
    //console.log("Connected to Flash");    
}

function receiveData(socket, d) {
	if(d === "@quit") {
		socket.end('Goodbye!\n');
	}
	else {
		var opt = '' + d;
		var usuario;
		var partida = 0;
		var creador;
		var oponente;
		var finStream;
		var swEURUSD;
		var swUSDCHF;
		socket.arrOpt = arrOpt;
		//arrSocket
		//console.log("********************************************************************");
		//console.log("From Flash = " + d);
		
		var arrOpt = opt.split('|');
		
		console.log(arrOpt);
	 
		//console.log("EJECUTANDO");
		switch(arrOpt[0]){
			case "GP"://Genera PIPs
				RowEURUSD = arrResultEURUSD[0];
				RowEURUSD.sec = 0;
				RowUSDCHF = arrResultUSDCHF[0];
				RowUSDCHF.sec = 0;
				RowEURUSD.tendencia = 'N';
				RowUSDCHF.tendencia = 'N';
				
				RowEURUSD.spreadEURUSD = Math.floor((RowEURUSD.precio_ask - RowEURUSD.precio_bid) * 100000);//Math.floor(RowEURUSD.precio_ask - RowEURUSD.precio_bid) * 10000;
				RowUSDCHF.spreadUSDCHF = Math.floor((RowUSDCHF.precio_ask - RowUSDCHF.precio_bid) * 100000);//Math.floor(RowUSDCHF.precio_ask - RowUSDCHF.precio_bid) * 10000;
				
				//var arrPrueba = 
				
				RowEURUSD.movEURUSD = 0;
				RowUSDCHF.movUSDCHF = 0;
				RowEURUSD.movAcumEURUSD = 0;
				RowUSDCHF.movAcumUSDCHF = 0;
				var fecha;
				var min;
				var seg;
				var res = false;
				if(arrResultEURUSD[0]['fecha'] < arrResultUSDCHF[0]['fecha']){
					//console.log("MANDA EURUSD");
					fecha = arrResultEURUSD[0]['fecha'].split(' ')[1];
					min = parseInt(fecha.split(':')[1]);
					seg = parseInt(fecha.split(':')[2]);				
				} else {
					//console.log("MANDA USDCHF");
					fecha = arrResultUSDCHF[0]['fecha'].split(' ')[1];
					min = parseInt(fecha.split(':')[1]);
					seg = parseInt(fecha.split(':')[2]);
				}
				
				
				
				
				socket.write("RECEP|INI|" + JSON.stringify(RowEURUSD) + "|" + JSON.stringify(RowUSDCHF) +  "|0|" + arrOpt[1], 'utf8');
				var n;
				if(arrResultEURUSD.length > arrResultUSDCHF.length){
					n = arrResultEURUSD.length;					
				} else {
					n = arrResultUSDCHF.length;
				}
				
				
				
				for(i = 1, j = 1, sec = 1; i < arrResultEURUSD.length && j < arrResultUSDCHF.length; i++, j++, sec++){
					
					sleep(100);
					/*fs.appendFile('./file2.txt', JSON.stringify(arrResultEURUSD[i]), function(err) {
						if( err ){
							console.log( err );
						}
						else{
							console.log('Se ha escrito correctamente');
						}
					});*/
					console.log("*************************************************************************");
					console.log("[" + sec + "]");
					if(seg + 1 > 59){
						seg = 0;
						if(min + 1 > 59){
							min = 0;
						} else {
							min++;
						}
					} else {
						seg++;
					}
					arrResultEURUSD[i]['sec'] = sec;
					arrResultUSDCHF[i]['sec'] = sec;
					fecha = arrResultEURUSD[i]['fecha'].split(' ')[1];
					var minN = parseInt(fecha.split(':')[1]);
					var segN = parseInt(fecha.split(':')[2]);
					console.log(min + ":" + seg + " | " + minN + ":" + segN);
					if(min == minN && seg == segN){
					   if(arrResultEURUSD[i - 1].hasOwnProperty('orden') && arrResultEURUSD[i - 1]['orden'] != 'N'){
							arrResultEURUSD[i]['orden'] = arrResultEURUSD[i - 1]['orden'];   
					   }
					   
					   console.log("TIEMPO ENCONTRADO");
					   RowEURUSD = arrResultEURUSD[i];
					   RowEURUSD.divisa = "EURUSD";
					   RowEURUSD.spreadEURUSD = Math.floor((RowEURUSD.precio_ask - RowEURUSD.precio_bid) * 100000);//Math.floor(RowEURUSD.precio_ask - RowEURUSD.precio_bid) * 10000;
					   console.log("SPREAD: " + RowEURUSD.precio_ask + " - " + RowEURUSD.precio_bid);
					   
						RowEURUSD.movAcumEURUSD = 0;
						//arrResult[i] = RowEURUSD;
						
					   arrResultEURUSD[i].movEURUSD = Math.round((arrResultEURUSD[i].precio_bid - arrResultEURUSD[i - 1].precio_bid) * 100000);//bid[i] - bid[i - 1];//Math.round(arrResult[i].precio_bid - arrResult[i - 1].precio_bid, 4);
					   console.log("Math.round((arrResultEURUSD[i].precio_bid - arrResultEURUSD[i - 1].precio_bid) * 100000) -> " + arrResultEURUSD[i].precio_bid + " - " + arrResultEURUSD[i - 1].precio_bid);
					   console.log("MOV ACTUAL: " + arrResultEURUSD[i].movEURUSD);
					   arrResultEURUSD[i].movAcumEURUSD = arrResultEURUSD[i - 1].movAcumEURUSD + arrResultEURUSD[i].movEURUSD//bid[i];//;			   
					   console.log(arrResultEURUSD[i - 1].movAcumEURUSD + " + " + arrResultEURUSD[i].movEURUSD + " " + i)//bid[i];//;			   
					   console.log("MOVACUM ACTUAL: " + arrResultEURUSD[i].movAcumEURUSD);
					   
					   
					   //console.log(JSON.stringify(arrResultEURUSD[i]));
					   
					   ////console.log(echo);
					   //socket.write("RECEP|INI|" + JSON.stringify(echoEURUSD) + "|" + arrOpt[1], 'utf8');
					   
					    console.log("VALIDACION TENDENCIA: arrResultEURUSD[i].movEURUSD = " + arrResultEURUSD[i].movEURUSD + " > 0");
					    if(arrResultEURUSD[i].movEURUSD > 0){//if(arrResultEURUSD[i].precio_bid < RowEURUSD.precio_bid){
						   //sql = "UPDATE `precios_analisis` SET `tendencia`='A' WHERE `fecha`='" . RowEURUSD.fecha . "'";
						    
							RowEURUSD.tendencia = 'A';	
							console.log("1.-RowEURUSD.tendencia: " + RowEURUSD.tendencia);
											
					    } else if(arrResultEURUSD[i].movEURUSD < 0){
							//sql = "UPDATE `precios_analisis` SET `tendencia`='B' WHERE `fecha`='" . RowEURUSD.fecha . "'";
							RowEURUSD.tendencia = 'B';
							console.log("2.-RowEURUSD.tendencia: " + RowEURUSD.tendencia);
					    } else {
							RowEURUSD.tendencia = arrResultEURUSD[i - 1].tendencia;
							console.log("3.-RowEURUSD.tendencia: " + RowEURUSD.tendencia);
					    }
						console.log("VALIDACION: actual -> " + arrResultEURUSD[i].tendencia + ', anterior -> ' + arrResultEURUSD[i - 1].tendencia + ", ROW: " + RowEURUSD.tendencia);
					   if(arrResultEURUSD[i].tendencia != 'N' && arrResultEURUSD[i - 1].tendencia != 'N' && arrResultEURUSD[i].tendencia != arrResultEURUSD[i - 1].tendencia){
							
							clave = arrResultEURUSD[i - 1].movAcumEURUSD; //Math.round(arrResultEURUSD[i].precio_bid, 4);//floor(arrResult[i - 1].precio_bid * 1000) / 1000;
							//clave = Math.round(arrResultEURUSD[i - 1].movAcumEURUSD / 10) * 10;//floor(arrResult[i - 1].precio_bid * 1000) / 1000;
							
						
							console.log(arrResultEURUSD[i - 1].movAcumEURUSD + " " + Math.round(arrResultEURUSD[i - 1].movAcumEURUSD / 10));//floor(arrResult[i - 1].precio_bid * 1000) / 1000;);
							console.log("GUARDANDO POSIBLE NIVEL : " + clave);
							console.log("VALIDACION: actual -> " + arrResultEURUSD[i].tendencia + ', anterior -> ' + arrResultEURUSD[i - 1].tendencia + ", ROW: " + RowEURUSD.tendencia);
							if(arrResultEURUSD[i].tendencia == 'A'){
								objMinimosEURUSD[sec] = arrMinimosEURUSD.length;
								arrMinimosEURUSD[arrMinimosEURUSD.length] = {'sec': sec, 'pip': arrResultEURUSD[i - 1].movAcumEURUSD};
								
							} else {
								objMaximosEURUSD[sec] = arrMaximosEURUSD.length;
								arrMaximosEURUSD[arrMaximosEURUSD.length] = {'sec': sec, 'pip': arrResultEURUSD[i - 1].movAcumEURUSD};
							}
							if(posibleNivelEURUSD.hasOwnProperty(clave)){
								
								posibleNivelEURUSD[clave]['puntos'][posibleNivelEURUSD[clave]['puntos'].length] = i;
								posibleNivelEURUSD[clave]['cantidadPtos'] += 1;
								socket.write("RECEP|NIVELEURUSD|" + JSON.stringify(arrResultEURUSD[i - 1]) +  "|" + arrResultEURUSD[i].tendencia + "|" + JSON.stringify(posibleNivelEURUSD[clave]) + '|' + arrOpt[1], 'utf8');
								//sleep(10000000);
							} else {
								
								posibleNivelEURUSD[clave] = {'clave': 'EURUSD_' + clave, puntos: [], rebote: 0, cantidadPtos: 1, cantidadCruce: 0};
								posibleNivelEURUSD[clave]['puntos'][0] = i;
							}
							
						} else if(arrResultEURUSD[i].tendencia != 'N' && arrResultEURUSD[i - 1].tendencia != 'N'){		
							//sleep(10000);
							console.log("POSIBLE ORDEN CON TENDENCIA: " + arrResultEURUSD[i].tendencia);
							var res = fnOrden(arrResultEURUSD, arrResultEURUSD[i], posibleNivelEURUSD, arrResultEURUSD[i].tendencia == 'A' ? 'ALZA' : 'BAJA', i, 'EURUSD', arrOpt[1], min, seg, arrResultEURUSD[i].tendencia == 'A' ? 'C' : 'V', arrResultEURUSD[i].tendencia, socket, sec, arrResultEURUSD[i].tendencia == 'A' ? arrMinimosEURUSD : arrMaximosEURUSD);
							
						}
						swEURUSD = true;
						
					} else {
						RowEURUSD.movEURUSD = 0;
						console.log("TIEMPO REPETIDO");
						i--;
						swEURUSD = false;
						//socket.write("RECEP|INI|" + JSON.stringify(echo) + "|" + arrOpt[1], 'utf8');
					}
					//console.log(RowUSDCHF.precio_ask + " - " + RowUSDCHF.precio_bid);
					//console.log(echoEURUSD.spread);
					fecha = arrResultUSDCHF[j]['fecha'].split(' ')[1];
					var minN = parseInt(fecha.split(':')[1]);
					var segN = parseInt(fecha.split(':')[2]);
					console.log(min + ":" + seg + " | " + minN + ":" + segN);
					if(min == minN && seg == segN){
					   if(arrResultUSDCHF[j - 1].hasOwnProperty('orden') && arrResultUSDCHF[j - 1]['orden'] != 'N'){
							arrResultUSDCHF[j]['orden'] = arrResultUSDCHF[j - 1]['orden'];   
					   }
					   
					   console.log("TIEMPO ENCONTRADO");
					   RowUSDCHF = arrResultUSDCHF[j];
					   RowUSDCHF.divisa = "USDCHF";
					   RowUSDCHF.spreadUSDCHF = Math.floor((RowUSDCHF.precio_ask - RowUSDCHF.precio_bid) * 100000);//Math.floor(RowUSDCHF.precio_ask - RowUSDCHF.precio_bid) * 10000;
					   console.log("SPREAD: " + RowUSDCHF.precio_ask + " - " + RowUSDCHF.precio_bid);
					   
						RowUSDCHF.movAcumUSDCHF = 0;
						//arrResult[i] = RowUSDCHF;
						
					   arrResultUSDCHF[j].movUSDCHF = Math.round((arrResultUSDCHF[j].precio_bid - arrResultUSDCHF[j - 1].precio_bid) * 100000);//bid[i] - bid[i - 1];//Math.round(arrResult[i].precio_bid - arrResult[i - 1].precio_bid, 4);
					   console.log("Math.round((arrResultUSDCHF[j].precio_bid - arrResultUSDCHF[i - 1].precio_bid) * 100000) -> " + arrResultUSDCHF[j].precio_bid + " - " + arrResultUSDCHF[j - 1].precio_bid);
					   console.log("MOV ACTUAL: " + arrResultUSDCHF[j].movUSDCHF);
					   arrResultUSDCHF[j].movAcumUSDCHF = arrResultUSDCHF[j - 1].movAcumUSDCHF + arrResultUSDCHF[j].movUSDCHF//bid[i];//;			   
					   console.log(arrResultUSDCHF[j - 1].movAcumUSDCHF + " + " + arrResultUSDCHF[j].movUSDCHF + " " + j)//bid[i];//;			   
					   console.log("MOVACUM ACTUAL: " + arrResultUSDCHF[j].movAcumUSDCHF);
					   
					   
					   //console.log(JSON.stringify(arrResultUSDCHF[i]));
					   
					   ////console.log(echo);
					   //socket.write("RECEP|INI|" + JSON.stringify(echoUSDCHF) + "|" + arrOpt[1], 'utf8');
					   
					    console.log("VALIDACION TENDENCIA: arrResultUSDCHF[j].movUSDCHF = " + arrResultUSDCHF[j].movUSDCHF + " > 0");
					    if(arrResultUSDCHF[j].movUSDCHF > 0){//if(arrResultUSDCHF[i].precio_bid < RowUSDCHF.precio_bid){
						   //sql = "UPDATE `precios_analisis` SET `tendencia`='A' WHERE `fecha`='" . RowUSDCHF.fecha . "'";
						    
							RowUSDCHF.tendencia = 'A';	
							console.log("1.-RowUSDCHF.tendencia: " + RowUSDCHF.tendencia);
											
					    } else if(arrResultUSDCHF[j].movUSDCHF < 0){
							//sql = "UPDATE `precios_analisis` SET `tendencia`='B' WHERE `fecha`='" . RowUSDCHF.fecha . "'";
							RowUSDCHF.tendencia = 'B';
							console.log("2.-RowUSDCHF.tendencia: " + RowUSDCHF.tendencia);
					    } else {
							RowUSDCHF.tendencia = arrResultUSDCHF[j - 1].tendencia;
							console.log("3.-RowUSDCHF.tendencia: " + RowUSDCHF.tendencia);
					    }
						console.log("VALIDACION: actual -> " + arrResultUSDCHF[j].tendencia + ', anterior -> ' + arrResultUSDCHF[j - 1].tendencia + ", ROW: " + RowUSDCHF.tendencia);
					   if(arrResultUSDCHF[j].tendencia != 'N' && arrResultUSDCHF[j - 1].tendencia != 'N' && arrResultUSDCHF[j].tendencia != arrResultUSDCHF[j - 1].tendencia){
							
							clave = arrResultUSDCHF[j - 1].movAcumUSDCHF; //Math.round(arrResultUSDCHF[i].precio_bid, 4);//floor(arrResult[i - 1].precio_bid * 1000) / 1000;
							//clave = Math.round(arrResultUSDCHF[j - 1].movAcumUSDCHF / 10) * 10
							if(arrResultUSDCHF[j].tendencia == 'A'){
								objMinimosUSDCHF[sec] = arrMinimosUSDCHF.length;
								arrMinimosUSDCHF[arrMinimosUSDCHF.length] = {'sec': sec, 'pip': arrResultUSDCHF[j - 1].movAcumUSDCHF};
								
							} else {
								objMaximosUSDCHF[sec] = arrMaximosUSDCHF.length;
								arrMaximosUSDCHF[arrMaximosUSDCHF.length] = {'sec': sec, 'pip': arrResultUSDCHF[j - 1].movAcumUSDCHF};
							}
							
							console.log("GUARDANDO POSIBLE NIVEL : " + clave);
							console.log("VALIDACION: actual -> " + arrResultUSDCHF[j].tendencia + ', anterior -> ' + arrResultUSDCHF[j - 1].tendencia + ", ROW: " + RowUSDCHF.tendencia);
							
							if(posibleNivelUSDCHF.hasOwnProperty(clave)){
								posibleNivelUSDCHF[clave]['puntos'][posibleNivelUSDCHF[clave]['puntos'].length] = j;
								posibleNivelUSDCHF[clave]['cantidadPtos'] += 1;
								socket.write("RECEP|NIVELUSDCHF|" + JSON.stringify(arrResultUSDCHF[j - 1]) +  "|" + arrResultUSDCHF[j].tendencia + "|" + JSON.stringify(posibleNivelUSDCHF[clave]) + '|' + arrOpt[1], 'utf8');
								//sleep(10000000);
							} else {
								
								posibleNivelUSDCHF[clave] = {'clave': 'USDCHF_' + clave, puntos: [], rebote: 0, cantidadPtos: 1, cantidadCruce: 0};
								posibleNivelUSDCHF[clave]['puntos'][0] = j;
							}
							
						} else if(arrResultUSDCHF[j].tendencia != 'N' && arrResultUSDCHF[j - 1].tendencia != 'N'){		
							//sleep(10000);
							console.log("POSIBLE ORDEN CON TENDENCIA: " + arrResultUSDCHF[j].tendencia);
							var res = fnOrden(arrResultUSDCHF, arrResultUSDCHF[j], posibleNivelUSDCHF, arrResultUSDCHF[j].tendencia == 'A' ? 'ALZA' : 'BAJA', j, 'USDCHF', arrOpt[1], min, seg, arrResultUSDCHF[j].tendencia == 'A' ? 'C' : 'V', arrResultUSDCHF[j].tendencia, socket, sec, arrResultEURUSD[i].tendencia == 'A' ? arrMinimosUSDCHF : arrMaximosUSDCHF);
							
						}
						swUSDCHF = true;
						
					} else {
						RowUSDCHF.movUSDCHF = 0;
						console.log("TIEMPO REPETIDO");
						j--;
						//socket.write("RECEP|INI|" + JSON.stringify(echo) + "|" + arrOpt[1], 'utf8');
						swUSDCHF = false;
					}
					//console.log(RowUSDCHF.precio_ask + " - " + RowUSDCHF.precio_bid);
					//console.log(echoEURUSD.spread);
					//console.log(RowEURUSD.precio_ask + " - " + RowEURUSD.precio_bid);
					//console.log(echoUSDCHF.spread);
					//console.log(i + " " + j);
					
					
					
					RowEURUSD.fechaEURUSD = RowEURUSD.fecha.split(" ")[0] + ' ' + RowEURUSD.fecha.split(" ")[1].split(':')[0] + ":" + min + ":" + seg;
					RowUSDCHF.fechaUSDCHF = RowUSDCHF.fecha.split(" ")[0] + ' ' + RowUSDCHF.fecha.split(" ")[1].split(':')[0] + ":" + min + ":" + seg;
					//if(swUSDCHF || swEURUSD){
						socket.write("RECEP|INI|" + JSON.stringify(RowEURUSD) + "|" + JSON.stringify(RowUSDCHF) +  "|" + sec + "|" + arrOpt[1], 'utf8');
					//}
					
					//console.log("Cant Orden: " + arrOrdAct.length);
					if(arrOrdAct.length > 0){
						
						var signo;					
						var r;
						var index;
						var arr;
						for(var z = 0; z < arrOrdAct.length; z++){
							console.log(arrOrdAct[z]);
							
							
							if(arrOrdAct[z]['orden'] == 'V'){
								signo = -1;
							} else {
								signo = 1;
							}
							
							console.log("signo: " + signo)
							if(arrOrdAct[z]['divisa'] == 'EURUSD'){
								r = RowEURUSD;
								index = i;
								arr = arrResultEURUSD;
							} else if(arrOrdAct[z]['divisa'] == 'USDCHF'){
								r = RowUSDCHF;
								index = j;
								arr = arrResultUSDCHF;
							}
							arrOrdAct[z]['ganancia'] += arr[index]['mov' + arrOrdAct[z]['divisa']] * (arrOrdAct[z]['orden'] == 'C' ? 1 : -1);
							
							if(arrOrdAct[z]['ganancia'] >= arrOrdAct[z]['margenGanancia']){
								arrOrdAct[z]['margenPerdida'] = arrOrdAct[z]['margenGanancia'] - margenSecundarioPerdida;
								arrOrdAct[z]['margenGanancia'] += margenSecundarioGanancia;								
								/*if(arrOrdAct[z][cerrar]){
									socket.write("RECEP|CLOSEORD" + arrOrdAct[z]['divisa'] + "|" + JSON.stringify(arrOrdAct[z]) + "|" + arrOpt[1], 'utf8');
									arrOrdFin[arrOrdFin.length] = arrOrdAct[z];
									objOrdAct[arrOrdAct[z]['divisa'] + '|' + arrOrdAct[z]['orden']] = -1;									
									arrOrdAct = fnElimElemento(arrOrdAct, z);	
									
								}*/								
								
								//sleep(10000);
							} else if(arrOrdAct[z]['ganancia'] <= arrOrdAct[z]['margenPerdida']){
								
								arrOrdAct[z]['fechaCierre'] =  arrOrdAct[z].fecha.split(" ")[0] + ' ' + arrOrdAct[z].fecha.split(" ")[1].split(':')[0] + ":" + min + ":" + seg;
								socket.write("RECEP|CLOSEORD" + arrOrdAct[z]['divisa'] + "|" + JSON.stringify(arrOrdAct[z]) + "|" + arrOpt[1], 'utf8');
								
								arrOrdFin[arrOrdFin.length] = arrOrdAct[z];
								//objOrdAct[arrOrdAct[z]['divisa'] + '|' + arrOrdAct[z]['orden']] = -1;
								
								arrOrdAct = fnElimElemento(arrOrdAct, z);
								//sleep(10000);
							}
						}
						
					}
					/*//console.log(echoEURUSD.difAcumEURUSD);
					//console.log(echoEURUSD.spread);
					//console.log(echoUSDCHF.difAcumUSDCHF);
					//console.log(echoUSDCHF.spread);*/
					//console.log((echoEURUSD.difAcumEURUSD - echoEURUSD.spread) + (echoUSDCHF.difAcumUSDCHF - echoUSDCHF.spread));
					if(res){
						//sleep(100000);
						//res = false;
					}
					if((RowEURUSD.movAcumEURUSD - RowEURUSD.spreadEURUSD) + (RowUSDCHF.movAcumUSDCHF - RowUSDCHF.spreadEURUSD) > 0){
						//sleep(100000);
						
						socket.write("RECEP|ORD|" + JSON.stringify(arrResultEURUSD[i]) + "|" + JSON.stringify(arrResultUSDCHF[j]) +  "|" + arrOpt[1], 'utf8');
					}
				  // sleep(1);
				   //sleep(100);
				}				
				console.log(posibleNivelEURUSD);
				fs.appendFile('./file' + fechaEjecucion + '.txt', JSON.stringify(arrOrdFin), function(err) {
					if( err ){
						console.log( err );
					}
					else{
						console.log('Se ha escrito correctamente');
					}
				});
			break;
			case "EP2"://Envia PIP
				sec++;
				
				RowEURUSD = arrResultEURUSD[iEP];
				RowEURUSD.sec = sec;
				RowUSDCHF = arrResultUSDCHF[jEP];
				RowUSDCHF.sec = sec;
				/*RowEURUSD.tendencia = 'N';
				RowUSDCHF.tendencia = 'N';*/
				RowEURUSD.precio_bidEURUSD = RowEURUSD.precio_bid;
				RowEURUSD.precio_bidUSDCHF = RowUSDCHF.precio_bid;
				RowUSDCHF.precio_bidUSDCHF = RowUSDCHF.precio_bid;
				RowEURUSD.spreadEURUSD = Math.floor((RowEURUSD.precio_ask - RowEURUSD.precio_bid) * 100000);//Math.floor(RowEURUSD.precio_ask - RowEURUSD.precio_bid) * 10000;
				RowUSDCHF.spreadUSDCHF = Math.floor((RowUSDCHF.precio_ask - RowUSDCHF.precio_bid) * 100000);//Math.floor(RowUSDCHF.precio_ask - RowUSDCHF.precio_bid) * 10000;
				
				//var arrPrueba = 
				
				RowEURUSD.movEURUSD = 0;
				RowUSDCHF.movUSDCHF = 0;
				RowEURUSD.movAcumEURUSD = 0;
				RowUSDCHF.movAcumUSDCHF = 0;
				console.log("*************************************************************************");
				console.log("[" + sec + "]");
				
				console.log(iEP);
				
				arrResultEURUSD[iEP]['sec'] = sec;
				arrResultUSDCHF[jEP]['sec'] = sec;
				fecha = arrResultEURUSD[iEP]['fecha'].split(' ')[1];
				var minN = parseInt(fecha.split(':')[1]);
				var segN = parseInt(fecha.split(':')[2]);
				console.log(minEP + ":" + segEP + " | " + minN + ":" + segN);
				if(minEP == minN && segEP == segN){
					console.log(arrResultEURUSD[iEP]);					
					RowEURUSD = arrResultEURUSD[iEP];
					RowEURUSD.divisa = "EURUSD";															
					RowEURUSD.precio_bidEURUSD = RowEURUSD.precio_bid;
					
					swEURUSD = true;
					iEP++;
				} else {
					console.log("TIEMPO REPETIDO");	
					console.log(arrResultEURUSD[iEP]);
					RowEURUSD.movEURUSD = 0;
									
					swEURUSD = false;					
				}
				fecha = arrResultUSDCHF[jEP]['fecha'].split(' ')[1];
				var minN = parseInt(fecha.split(':')[1]);
				var segN = parseInt(fecha.split(':')[2]);
				console.log(minEP + ":" + segEP + " | " + minN + ":" + segN);
				if(minEP == minN && segEP == segN){
								   
					console.log("TIEMPO ENCONTRADO");
					RowUSDCHF = arrResultUSDCHF[jEP];
					RowUSDCHF.divisa = "USDCHF";
					
					swUSDCHF = true;
					jEP++;
					
				} else {
					console.log("TIEMPO REPETIDO");	
					console.log(arrResultUSDCHF[jEP]);
					RowUSDCHF.movUSDCHF = 0;
								
					swUSDCHF = false;
				}
				RowEURUSD.fechaEURUSD = RowEURUSD.fecha.split(" ")[0] + ' ' + RowEURUSD.fecha.split(" ")[1].split(':')[0] + ":" + minEP + ":" + segEP;
				RowUSDCHF.fechaUSDCHF = RowUSDCHF.fecha.split(" ")[0] + ' ' + RowUSDCHF.fecha.split(" ")[1].split(':')[0] + ":" + minEP + ":" + segEP;
				if(segEP + 1 > 59){
					segEP = 0;
					if(minEP + 1 > 59){
						minEP = 0;
					} else {
						minEP++;
					}
				} else {
					segEP++;
				}
				RowEURUSD.precio_bidUSDCHF = RowUSDCHF.precio_bid;
				//if(swUSDCHF || swEURUSD){
					socket.write("RECEP|INIPIP|" + JSON.stringify(RowEURUSD) + "|" + JSON.stringify(RowUSDCHF) +  "|" + sec + "|" + arrOpt[1], 'utf8');
				//}
				
				//console.log("Cant Orden: " + arrOrdAct.length);
				
				
			break;
			case "EP"://Envia PIP
				console.log(arrOpt);
				var valorVela = arrOpt[1];
				console.log(valorVela);
				for(var cont = 0; iEP < arrResultEURUSD.length && jEP < arrResultUSDCHF.length && cont < valorVela; iEP++, jEP++, sec++, cont++){
					console.log('cont' + cont);
					sleep(1);
					RowEURUSD = arrResultEURUSD[iEP];
					RowEURUSD.sec = sec;
					RowUSDCHF = arrResultUSDCHF[jEP];
					RowUSDCHF.sec = sec;
					/*RowEURUSD.tendencia = 'N';
					RowUSDCHF.tendencia = 'N';*/
					RowEURUSD.precio_bidEURUSD = RowEURUSD.precio_bid;
					RowEURUSD.precio_bidUSDCHF = RowUSDCHF.precio_bid;
					RowUSDCHF.precio_bidUSDCHF = RowUSDCHF.precio_bid;
					RowEURUSD.spreadEURUSD = Math.floor((RowEURUSD.precio_ask - RowEURUSD.precio_bid) * 100000);//Math.floor(RowEURUSD.precio_ask - RowEURUSD.precio_bid) * 10000;				
					RowEURUSD.spreadUSDCHF = Math.floor((RowUSDCHF.precio_ask - RowUSDCHF.precio_bid) * 100000);//Math.floor(RowUSDCHF.precio_ask - RowUSDCHF.precio_bid) *
					RowUSDCHF.spreadUSDCHF = Math.floor((RowUSDCHF.precio_ask - RowUSDCHF.precio_bid) * 100000);//Math.floor(RowUSDCHF.precio_ask - RowUSDCHF.precio_bid) * 10000;
					
					//var arrPrueba = 
					
					RowEURUSD.movEURUSD = 0;
					RowUSDCHF.movUSDCHF = 0;
					RowEURUSD.movAcumEURUSD = 0;
					RowUSDCHF.movAcumUSDCHF = 0;
					console.log("*************************************************************************");
					console.log("[" + sec + "]");
					
					//console.log(iEP);
					
					arrResultEURUSD[iEP]['sec'] = sec;
					arrResultUSDCHF[jEP]['sec'] = sec;
					fecha = arrResultEURUSD[iEP]['fecha'].split(' ')[1];
					var minN = parseInt(fecha.split(':')[1]);
					var segN = parseInt(fecha.split(':')[2]);
					console.log(minEP + ":" + segEP + " | " + minN + ":" + segN);
					if(minEP == minN && segEP == segN){
						//console.log(arrResultEURUSD[iEP]);					
						RowEURUSD = arrResultEURUSD[iEP];
						RowEURUSD.divisa = "EURUSD";															
						RowEURUSD.precio_bidEURUSD = RowEURUSD.precio_bid;
						
						swEURUSD = true;
						
					} else {
						console.log("TIEMPO REPETIDO");	
						//console.log(arrResultEURUSD[iEP]);
						RowEURUSD.movEURUSD = 0;
						iEP--;				
						swEURUSD = false;					
					}
					fecha = arrResultUSDCHF[jEP]['fecha'].split(' ')[1];
					var minN = parseInt(fecha.split(':')[1]);
					var segN = parseInt(fecha.split(':')[2]);
					console.log(minEP + ":" + segEP + " | " + minN + ":" + segN);
					if(minEP == minN && segEP == segN){
									   
						console.log("TIEMPO ENCONTRADO");
						RowUSDCHF = arrResultUSDCHF[jEP];
						RowUSDCHF.divisa = "USDCHF";
						
						swUSDCHF = true;
						
						
					} else {
						console.log("TIEMPO REPETIDO");	
						console.log(arrResultUSDCHF[jEP]);
						RowUSDCHF.movUSDCHF = 0;
						jEP--;			
						swUSDCHF = false;
					}
					RowEURUSD.fechaEURUSD = RowEURUSD.fecha.split(" ")[0] + ' ' + RowEURUSD.fecha.split(" ")[1].split(':')[0] + ":" + minEP + ":" + segEP;
					RowUSDCHF.fechaUSDCHF = RowUSDCHF.fecha.split(" ")[0] + ' ' + RowUSDCHF.fecha.split(" ")[1].split(':')[0] + ":" + minEP + ":" + segEP;
					if(segEP + 1 > 59){
						segEP = 0;
						if(minEP + 1 > 59){
							minEP = 0;
						} else {
							minEP++;
						}
					} else {
						segEP++;
					}
					RowEURUSD.precio_bidUSDCHF = RowUSDCHF.precio_bid;
					//if(swUSDCHF || swEURUSD){
						socket.write("RECEP|INIPIP|" + JSON.stringify(RowEURUSD) + "|" + JSON.stringify(RowUSDCHF) +  "|" + sec + "|" + arrOpt[2], 'utf8');
					//}
					
					//console.log("Cant Orden: " + arrOrdAct.length);
				}
				
				
				
			break;
			case "RESET":
				fechaEP = fechaEP_RESET;
				minEP = minEP_RESET;
				segEP = segEP_RESET;
				iEP = 0;
				sec = 1;
				jEP = 0;

			break;
		}
		
	}	
}

function fnElimElemento(arrOrdAct, z){
	var arr = [];
	for(var i = 0; i < z; i++){
		objOrdAct[arrOrdAct[i]['divisa'] + '|' + arrOrdAct[i]['orden']] = arr.length;
		arr[arr.length] = arrOrdAct[i];
		
	}
	for(var i = z + 1; i < arrOrdAct.length; i++){
		arr[arr.length] = arrOrdAct[i];
	}
	return arr;
}



function closeSocket(socket) {
	//console.log('***************************************');
	//console.log('ingresando en closeSocket');//53820010
	
	
}

function onClose(socket)
{
	//console.log("ingresando en onClose");
}

function onError()
{
    //console.log("SE DESCONECTO");
}


function fnLog(err){
	if( err ){
		console.log( err );
	}
	else{
		console.log('Se ha escrito correctamente');
	}
}

function fnOrden(arrResult, row, posibleNivel, movimiento, i, divisa, cierreMsg, min, seg, tipoOrden, tendencia, socket, sec, arrExtremos){
	console.log(movimiento);
	//fs.appendFile('./file2.txt', movimiento + "", fnLog);
	var res = false;
	//stream.once('open', function(fd) {  fnLog2(fs, movimiento);});
	//var diferencia = (row.precio_bid - arrResult[i - 1].precio_bid) * 100000;
	console.log("dif: "  + row['mov' + divisa]);
	//fs.appendFile('./file2.txt', "dif: " + diferencia + " | mov: " + row.mov, fnLog);
	//stream.once('open', function(fd) {  fnLog2(fs, "dif: " + diferencia + " | mov: " + row.mov);});
	var limite = false;
	var nivelCruzado = false;
	row.contbreak = 0;
	var signo;
	var arrClaves = [];
	var objClaves = {};
	
	if(row['mov' + divisa] < 0){
		signo = -1;
	} else {
		signo = 1;
	}
	var claveCruce;
	for(var s = 0; s < row['mov' + divisa] * signo; s++){
		console.log("CLAVE : " + (row['movAcum' + divisa] - row['mov' + divisa]));
		//fs.appendFile('./file2.txt', "CLAVE : " + ((arrResult[i - 1].precio_bid * 100000 + s) / 100000) + " | movAcum: " + row.movAcum, fnLog);
		//stream.once('open', function(fd) {  fnLog2(fs,"CLAVE : " + ((arrResult[i - 1].precio_bid * 100000 + s) / 100000) + " | movAcum: " + row.movAcum);});
		clave = row['movAcum' + divisa] - row['mov' + divisa] + s * signo;//Math.round((arrResult[i - 1].precio_bid * 100000 + (s * signo)) / 100000, 4);//floor(arrResult[i - 1].precio_bid * 1000) / 1000;
		console.log("BUSCANDO NIVEL...");
		//fs.appendFile('./file2.txt', "BUSCANDO NIVEL...", fnLog);
		//stream.once('open', function(fd) {  fnLog2(fs,"BUSCANDO NIVEL...");});
		console.log("Posible nivel: " + clave);
		//stream.once('open', function(fd) {  fnLog2(fs,"Posible nivel: " + clave);});
		//fs.appendFile('./file2.txt', "Posible nivel: " + clave, fnLog);
		//console.log(posibleNivel);
		//fs.appendFile('./file2.txt', posibleNivel, fnLog);
		//stream.once('open', function(fd) {  fnLog2(fs,posibleNivel);});
		
		if(posibleNivel.hasOwnProperty(clave)){
			console.log("**NIVEL encontrado**VALIDADO: " + posibleNivel[clave]['cantidadPtos']);
			//sleep(10000);
			//fs.appendFile('./file2.txt', "NIVEL encontrado", fnLog);
			//stream.once('open', function(fd) {  fnLog2(fs,"NIVEL encontrado");});
			
			if(limite){
				row.contbreak += 1;				
			}
			if(posibleNivel[clave]['cantidadPtos'] - posibleNivel[clave]['cantidadCruce'] > rupturaNivel){
				
				limite = true;	
				claveCruce = clave;
				
			}
			if(!objClaves.hasOwnProperty(clave)){
				objClaves[clave] = arrClaves.length;
				arrClaves[arrClaves.length] = clave;
			}
			
		} else {
			
			if(limite || (arrResult[i - 1].hasOwnProperty("contbreak") && arrResult[i - 1].contbreak != 0)){
				console.log("NIVEL CRUZADO");
				
				nivelCruzado = true;
				//fs.appendFile('./file2.txt', "NIVEL CRUZADO", fnLog);
				//stream.once('open', function(fd) {  fnLog2(fs,"NIVEL CRUZADO");});
				row.contbreak += 1;
				console.log('row.contbreak: ' + row.contbreak + ' > ' + " ajusteBreak: " + (ajusteBreak * signo));
				//sleep(10000)
			} else {
				console.log("NIVEL NO encontrado");
				//fs.appendFile('./file2.txt', "NIVEL NO encontrado", fnLog);
				//stream.once('open', function(fd) {  fnLog2(fs,"NIVEL NO encontrado");});
			} 
		}
		
		//fs.appendFile('./file2.txt', 'row.contbreak: ' + row.contbreak + ' > ' + " ajusteBreak: " + ajusteBreak, fnLog);
		//stream.once('open', function(fd) {  fnLog2(fs,'row.contbreak: ' + row.contbreak + ' > ' + " ajusteBreak: " + ajusteBreak);});
		console.log('row.contbreak: ' + row.contbreak + ' > ' + " ajusteBreak: " + (ajusteBreak * signo));
		
		var validOrder = true;
		if(objOrdAct.hasOwnProperty(divisa + '|' + tipoOrden) && objOrdAct[divisa + '|' + tipoOrden] != -1){
			validOrder = false;
		}
		
		var tendenciaCorrecta = true;
		
		
		
		if(row.contbreak > ajusteBreak && validOrder && nivelCruzado){
			
			if(arrExtremos.length > 4){
				//pri = arrExtremos[arrExtremos.length - detTendencia - 1]['pip'];
				var arrRes = [];
				console.log(arrExtremos.length - detTendencia - 1);
				for(var f = arrExtremos.length - detTendencia - 1; f < arrExtremos.length; f++){
					console.log(arrExtremos[f]['pip'] + '-' + arrExtremos[f - 1]['pip'] + ' > 0');
					if(arrExtremos[f]['pip'] - arrExtremos[f - 1]['pip'] > 0){
						arrRes[arrRes.length] = 'C';
					} else if(arrExtremos[f]['pip'] - arrExtremos[f - 1]['pip'] < 0){
						arrRes[arrRes.length] = 'V';
					}
				}
				
				if(arrRes.length > 2){
					for(var f = 1; f < arrRes.length; f++){
						if(arrRes[f - 1] != arrRes[f]){
							tendenciaCorrecta = false;
							break;
						}
					}
				} else {
					tendenciaCorrecta = false;
				}
				
				
			} else {
				tendenciaCorrecta = false;
			}
			
			console.log(arrExtremos);
			console.log(arrRes);
			
			
			if(tendenciaCorrecta && tipoOrden == arrRes[0]){
				console.log("EJECUTA ORDEN");
				//stream.once('open', function(fd) {  fnLog2(fs,"Romipo Nivel");});
				//fs.appendFile('./file2.txt', "Romipo Nivel", fnLog);
				row.orden = tipoOrden;
				row.id = sec;
				
				
				row['ganancia'] = -row['spread' + row['divisa']];
				row['margenGanancia'] = margenGanancia;
				row['margenPerdida'] = margenPerdida;
				row.fechaTrans = row.fecha.split(" ")[0] + ' ' + row.fecha.split(" ")[1].split(':')[0] + ":" + min + ":" + seg;
				row.id = sec;
				objOrdAct[divisa + '|' + tipoOrden] = arrOrdAct.length;			
				arrOrdAct[arrOrdAct.length] = row;					
				for(x = 0; x < arrClaves.length; x++){
					posibleNivel[arrClaves[x]]['cantidadCruce']++;
					socket.write("RECEP|NIVEL" + divisa + "|" + JSON.stringify(row) +  "|" + row.tendencia + "|" + JSON.stringify(posibleNivel[claveCruce]) + '|' + cierreMsg, 'utf8');
				}
				
				socket.write("RECEP|EXECORD" + divisa + "|" + JSON.stringify(row) +  "|" + cierreMsg, 'utf8');
				
				console.log(posibleNivel);
				/*sleep(100000000);
				exit();*/
				/*fs.appendFile('./file2.txt', JSON.stringify(posibleNivel), function(err) {
					if( err ){
						console.log( err );
					}
					else{
						console.log('Se ha escrito correctamente');
					}
				});*/
				res = true;
				
				break;
			
			}
			
		}
	}
	return res;
}

function newSocket(socket) {
	//console.log("/************************************************************/");
	//console.log('ingresando en newSocket');
	//socket.id = '0';
	//console.log('Welcome to the Telnet server!\n');
	
	socket.on('data', function(data) {
		receiveData(socket, data);
	})
	socket.on('end', function() {
		closeSocket(socket);
	})
	socket.on("close", function(){
		onClose(socket);
	});
	socket.on('error', function(err) {
		//console.log('[ERROR DE SOCKET]');
	})
	
	socket.on('disconnect', function(err) {
		//console.log('[ERROR DE SOCKET FINAL....DESCONEXION]');
	})
	
	socket.addListener('build', function() {
		//console.log('[HOLA]');
	})
	
	////console.log(socket);
	socket.nombre = 'U' + usuario;
	//ee.on('build', saludo);
	ee.emit('build');
	/*socket.ee = new EmisorEventos();
	socket.ee.on('build',  function() {
		//console.log('[HOLA]');
	});
	ee.parent = socket;*/
	arrSocket['U' + (usuario++)] = socket;
	
	
	
	
	
	////console.log(socket.nombre + '\n');
}



function saludo(socket){
	//console.log(this);//.parent.nombre);
	////console.log(arrSocket);
	////console.log(socket);
}


var server = net.createServer(newSocket);

server.listen(9004);
