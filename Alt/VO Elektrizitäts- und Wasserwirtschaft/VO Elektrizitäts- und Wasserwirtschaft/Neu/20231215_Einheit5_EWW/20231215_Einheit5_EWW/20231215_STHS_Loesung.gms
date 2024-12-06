Sets
 n            Index Stützstellen für Modellierung Turbinen-Wirkungsgrad            /n0* n20/
 t            Zeitpunkt bzw. Stunde                                                /t1*t168/
 t_start (t)  Erste Stunde                                                         /     t1/
 t_ende  (t)  Letzte Stunde                                                        /   t168/
;

Scalars
 Anzahl_MS    Anzahl der Maschinensätze [1]                                           /   2/
 H            Fall- bzw. Förderhöhe (als konstant angenommen)[m]                      / 410/
 Q_min        Minimaler Turbinendurchfluss eines Maschinensatzes [m3 pro s]           /  16/
 Q_max        Maximaler Turbinendurchfluss eines Maschinensatzes [m3 pro s]           /  40/
 Q_pump       Förderstrom eines Maschinensatzes  [m3 pro s]                           /  35/
 eta_pump     Hydraulischer Wirkungsgrad im Pumpbetrieb [1]                           /0.92/
 I_max        Maximaler Betriebsinhalt des Oberliegers [hm3]                          /  60/
 I_Start      Anfangs- und Endbedingung für den Betriebsinhalt des Oberliegers [hm3]  /  40/
 Dargebot     Natürlicher Zufluss des Oberliegers [m3 pro s]                          /   2/
;

Parameters
 Preis    (t)  Prognose des Spot-Markt-Preis in der Stunde von t-1 bis t [EUR pro MWh]
 Q_Stuetz (n)  Stützstellen (verschiedene Durchflüsse) für die Leistungskennlinie [m3 pro s]
 P_Stuetz (n)  Zugehörige Leistungen an den Stützstellen für die Leistungskennlinie [MW]
 ;

* Einlesen der prognostitierten Strompreise aus dem .xlsx-File
$CALL   GDXXRW.EXE  Input-Output_Kurzfristig.xlsx Par=Preis rng=Input!A3:B170 Cdim=0 Rdim=1 Trace = 3
$GDXIN  Input-Output_Kurzfristig
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
SOS2 variables
 v_lambda_Turbine (t,n)  SOS2-Variablen zur linearen Approximation der Leistungs-Kennlinie im Turbinenbetrieb  [1]
;
Integer variables
 v_on_Pump        (t  )  Anzahl Maschinensätze im Turbinenbetrieb [1]
 v_on_Turb        (t  )  Anzahl Maschinensätze im Pumpbetrieb [1]
;

* Box Constraints
 v_Inh.up     (t)         = I_max;
 v_Inh.fx     (t_ende)    = I_Start;
 v_on_Turb.up (t)         = Anzahl_MS;
 v_on_Pump.up (t)         = Anzahl_MS;

Equations
 g_Erloes                         Gesamterlös (Zielfunktion)
 g_BetriebsinhaltSpeicher  (t)    Speicherbilanzgleichung
 g_Turbinen_Leistung       (t)    Abgegebene Leistung im Turbinenbetrieb des Kraftwerkes
 g_Turbinen_Durchfluss     (t)    Summierte Turbinendurchflüsse der Maschinensätze des Kraftwerkes
 g_Turbinen_SummeLambda    (t)    Summe Gewichte der P-Q-Kurve-Approximation entspricht Anzahl Maschinensätze im Turbinenbetrieb
 g_Pumpen_Leistung         (t)    Aufgenommene Leistung im Pumpbetrieb des Kraftwerkes
 g_Pumpen_Foerderstrom     (t)    Summierte Pumpenförderströme der Maschinensätze des Kraftwerkes
 g_MinTurbinenDurchfluss   (t)    Minimaler Turbinendurchfluss
 g_Preis_marg              (t)    Marginal Preis
;

* Zielfunktion--> am besten immer damit starten
 g_Erloes                     .. v_Erloes =e= sum(t,(Preis(t)-12)*v_P_Turb(t)-(Preis(t)+20)*v_P_Pump(t));

* Speicherinhalt
 g_BetriebsinhaltSpeicher(t)  .. (v_Inh(t)-v_Inh(t-1)-I_Start$t_start(t))*1000000 =e= 3600*(Dargebot-v_Q_Turb(t)+v_Q_Pump(t));

* Leistungen und VDurchflüsse im Turbinenbetrieb--> hier wird die Verknüpfung von Zielf und Speicherin definiert
 g_Turbinen_Leistung(t)       .. v_P_Turb(t)  =e= sum(n,v_lambda_Turbine(t,n)*P_Stuetz(n));
 g_Turbinen_Durchfluss(t)     .. v_Q_Turb(t)  =e= sum(n,v_lambda_Turbine(t,n)*Q_Stuetz(n));
 g_Turbinen_SummeLambda(t)    .. v_on_Turb(t) =e= sum(n,v_lambda_Turbine(t,n));
 g_MinTurbinenDurchfluss(t)   .. v_Q_Turb(t)  =g= v_on_Turb(t)*Q_min;
 
* Leistungen und Förderströme im Pumpbetrieb
 g_Pumpen_Leistung(t)         .. v_P_Pump(t) =e= 9.81/1000*v_Q_Pump(t)/eta_pump*H ;
 g_Pumpen_Foerderstrom(t)     .. v_Q_Pump(t) =e= v_on_Pump(t)*Q_pump;
 
g_Preis_marg(t)               .. v_Preis_m =e= (Preis(t)-12)*v_P_Turb(t);
model Aufgabenstellung /all/

* Wähle passenden Solver
Option MIP = CPLEX;
solve Aufgabenstellung using MIP maximising v_Erloes;

execute_unload "results.gdx" v_P_Turb.L v_P_Pump.L v_Q_Turb.L v_Q_Pump.L v_Inh.L v_Erloes.L
execute 'gdxxrw.exe  results.gdx o=Input-Output_Kurzfristig.xlsx squeeze=N var=v_Inh.L rng=Output!C3 rdim=1 cdim=0'
execute 'gdxxrw.exe  results.gdx o=Input-Output_Kurzfristig.xlsx squeeze=N var=v_P_Pump.L  rng=Output!B3 rdim=1 cdim=0'
execute 'gdxxrw.exe  results.gdx o=Input-Output_Kurzfristig.xlsx squeeze=N var=v_P_Turb.L  rng=Output!A3 rdim=1 cdim=0'
execute 'gdxxrw.exe  results.gdx o=Input-Output_Kurzfristig.xlsx squeeze=N var=v_Erloes.L rng=Output!G1 rdim=0 cdim=0'
