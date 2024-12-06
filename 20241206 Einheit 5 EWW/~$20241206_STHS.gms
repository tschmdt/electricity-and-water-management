Sets
 n            Index Stützstellen für Modellierung Turbinen-Wirkungsgrad            /n0* n20/
 t            Zeitpunkt bzw. Stunde                                                /t1*t168/
;

Scalars
 Anzahl_MS    Anzahl der Maschinensätze [1]                                           /   2/
 H            Fall- bzw. Förderhöhe (als konstant angenommen) [m]                      / 410/
 Q_min        Minimaler Turbinendurchfluss eines Maschinensatzes [m3 pro s]           /  16/
 Q_max        Maximaler Turbinendurchfluss eines Maschinensatzes [m3 pro s]           /  40/
 Q_pump       Förderstrom eines Maschinensatzes  [m3 pro s]                           /  35/
 eta_pump     Hydraulischer Wirkungsgrad im Pumpbetrieb [1]                           /0.92/
 I_max        Maximaler Betriebsinhalt des Oberliegers [hm3]                          /  60/
 I_Start      Anfangs- und Endbedingung für den Betriebsinhalt des Oberliegers [hm3]  /  40/
 Dargebot     Natürlicher Zufluss des Oberliegers [m3 pro s]                          /   2/
;

Parameters
 Preis    (t)  Prognose des Spot-Markt-Preis in der Stunde von t-1 bis t
 Q_Stuetz (n)  Stützstellen (verschiedene Durchflüsse) für die Leistungskennlinie
 P_Stuetz (n)  Zugehörige Leistungen an den Stützstellen für die Leistungskennlinie
 ;

* Einlesen der prognostitierten Strompreise aus dem .xlsx-File
$CALL   GDXXRW.EXE  20241206_Input-Output_STHS.xlsx Par=Preis rng=Input!A3:B170 Cdim=0 Rdim=1 Trace = 3
$GDXIN  20241206_Input-Output_STHS
$LOAD   Preis
$GDXIN
;

* Äquidistante Stützstellen von Q und zugehörige Leistungen P der Leistungskennlinie
 Q_Stuetz(n)                            = (ord(n)-1)/(card(n)-1)*Q_max;
 P_Stuetz(n)$(Q_Stuetz(n)/Q_max>0.095)  =  H*Q_Stuetz(n)*9.81/1000*(Q_Stuetz(n)/Q_max-0.095)/(0.18+0.63*(Q_Stuetz(n)/Q_max-0.095)+0.31*(Q_Stuetz(n)/Q_max-0.095)**2);
 P_Stuetz(n)$(Q_Stuetz(n)/Q_max<0.095)  =  0;

Variables
 v_Erloes                Erlös [EUR]
 v_Preis_m
;
Positive variables 
 v_Inh            (t  )  Betriebsinhalt des Speichers (Oberlieger) zum Zeitpunkt t [hm3]
 v_P_Turb         (t  )  Abgegebene Leistung im Turbinenbetrieb des Kraftwerkes in der Stunde von t-1 bis t [MW]
 v_P_Pump         (t  )  Aufgenommene Leistung im Pumpbetrieb des Kraftwerkes in der Stunde von t-1 bis t [MW]
 v_Q_Turb         (t  )  Summierte Turbinendurchflüsse der Maschinensätze des Kraftwerkes in der Stunde von t-1 bis t [m3 pro s]
 v_Q_Pump         (t  )  Summierte Pumpenförderströme der Maschinensätze des Kraftwerkes in der Stunde von t-1 bis t [m3 pro s]
;

SOS2 Variable
v_lambda_Turbine (t,n)  SOS2-Variablen zur linearen Approximation der Leistungs-Kennlinie im Turbinenbetrieb 
;

Integer Variable
v_on_Pump        (t  )  Anzahl Maschinensätze im Turbinenbetrieb 
v_on_Turb        (t  )  Anzahl Maschinensätze im Pumpbetrieb



* Zielfunktion
g_Erloes             .. v_Erloes =e= sum(t,(Preis(t)-12)*v_P_Turb(t)-(Preis(t)+20)*v_P_Pump(t));



* Wähle passenden Solver
Option MIP = CPLEX;

* Output als gdx-File (funktioniert nur, wenn Lösung schon vorhanden)
execute_unload "results.gdx" v_P_Turb.L v_P_Pump.L v_Q_Turb.L v_Q_Pump.L v_Inh.L v_Erloes.L
* Output in xlsx-File
execute 'gdxxrw.exe  results.gdx o=20241206_Input-Output_STHS.xlsx squeeze=N var=v_Inh.L rng=Output!C3 rdim=1 cdim=0'
execute 'gdxxrw.exe  results.gdx o=20241206_Input-Output_STHS.xlsx squeeze=N var=v_P_Pump.L  rng=Output!B3 rdim=1 cdim=0'
execute 'gdxxrw.exe  results.gdx o=20241206_Input-Output_STHS.xlsx squeeze=N var=v_P_Turb.L  rng=Output!A3 rdim=1 cdim=0'
execute 'gdxxrw.exe  results.gdx o=20241206_Input-Output_STHS.xlsx squeeze=N var=v_Erloes.L rng=Output!G1 rdim=0 cdim=0'
