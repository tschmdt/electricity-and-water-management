Sets
 n    Index der Stützstellen für die Modellierung des Turbinen-Wirkungsgrades      /n0* n20/
 t    Zeitpunkt bzw. Stunde                                                        /t1*t168/
;

alias(t,tt)
;

Scalars
 Anzahl_MS    Anzahl der Maschinensätze [1]                                           /   2/
 H            Fall- bzw. Förderhöhe (als konstant angenommen) [m]                     / 410/
 Q_min        Minimaler Turbinendurchfluss eines Maschinensatzes [m3 pro s]           /  16/
 Q_max        Maximaler Turbinendurchfluss eines Maschinensatzes [m3 pro s]           /  40/
 Q_pump       Förderstrom eines Maschinensatzes Pumpe [m3 pro s]                      /  35/
 eta_pump     Hydraulischer Wirkungsgrad im Pumpbetrieb [1]                           /0.92/
 I_max        Maximaler Betriebsinhalt des Oberliegers [hm3]                          /  60/
 I_Start      Anfangs- und Endbedingung für den Betriebsinhalt des Oberliegers [hm3]  /  40/
 Dargebot     Natürlicher Zufluss des Oberliegers [m3 pro s]                          /   2/
 Gebuehr_Ein  Einspeisegebühr [€ pro MWh]                                             /  12/
 Gebuehr_Ent  Entnahmegebühr [€ pro MWh]                                              /  20/

*Pruefung 2
 alpha        Reibungskoeffizient                                                     /0.004804688/
;

Parameters
 Preis    (t)  Prognose des Spot-Markt-Preis in der Stunde von t-1 bis t
 Q_Stuetz (n)  Stützstellen (verschiedene Durchflüsse) für die Leistungskennlinie
 P_Stuetz (n)  Zugehörige Leistungen an den Stützstellen für die Leistungskennlinie
 
*Pruefung 2
 Q_vStuetz(n)  Stützstellen für die Verlustleistungskennlinien (doppelt so viel Durchfluss)
 P_vStuetz (n) Zugehörige Verlustleistungen an den Stützstellen für die Leistungskennlinie
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


*Pruefung 2
* Ein gemeinsam genutzter Triebwasserwerg. Dh Summe der SO2 Variablen ist 1 und der maximale Durchfluss ist 2*Q_max oder?
 Q_vStuetz(n)                            = (ord(n)-1)/(card(n)-1)*(2*Q_max);
 P_vStuetz(n)$(Q_vStuetz(n)/(2*Q_max)>0.095)  =  9.81/1000*alpha*Q_vStuetz(n)**3;
 P_vStuetz(n)$(Q_vStuetz(n)/(2*Q_max)<0.095)  =  0;

Variables
 v_Erloes                Erlös [EUR]
;
Positive variables 
 v_Inh            (t  )  Betriebsinhalt des Speichers (Oberlieger) zum Zeitpunkt t [hm3]
 v_P_Turb         (t  )  Abgegebene Leistung im Turbinenbetrieb des Kraftwerkes in der Stunde von t-1 bis t [MW]
 v_P_Pump         (t  )  Aufgenommene Leistung im Pumpbetrieb des Kraftwerkes in der Stunde von t-1 bis t [MW]
 v_Q_Turb         (t  )  Summierte Turbinendurchflüsse der Maschinensätze des Kraftwerkes in der Stunde von t-1 bis t [m3 pro s]
 v_Q_Pump         (t  )  Summierte Pumpenförderströme der Maschinensätze des Kraftwerkes in der Stunde von t-1 bis t [m3 pro s]

*Pruefung 2
 v_Pv_Turb        (t  )  Verlustleistung des Kraftwerks im Turbinenbetrieb in der Stunde t-1 bis t [MW]
;
SOS2 variables
 v_stuetze (t,n)  SOS2-Variablen
 
*Pruefung 2
v_lambda_Verlust (t,n)  SOS2-Variablen zur linearen Approximation der Verlustleistung
;
Integer variables
 v_MS_Pumpe (t) Maschinensätze Pumpe Anzahl
 v_MS_Turbine (t) Maschinensätze Turbine Anzahl
;

Equations
g_Profit   Erloesgleichung
g_Speicherinhalt Speicherinhaltsgleichung
g_EndSpeicherinhalt Endbedingung Speicher
g_MaxSpeicherinhalt Begrenzung Speicher
g_Turbine_Durchfluss_Min Minimaler Turbinendurchfluss
g_Turbine_Durchfluss_Max Maximaler Turbinendurchfluss
g_Pumpe_Durchfluss Pumpendurchfluss
g_Max_MS_Pumpe Maximale Anzahl der Maschinensätze im Pumpbetrieb
g_Max_MS_Turbine Maximale Anzahl der Maschinensätze im Turbinenbetrieb
g_Linearisierung_1 Linearisieren
g_Linearisierung_2 Linearisieren
g_Linearisierung_3 Linearisieren
g_Pumpe_Leistung Pumpenleistung
g_BiddingCurve_Turbine    (t,tt) Bidding-Curve im Turbinenbetrieb monoton
g_BiddingCurve_Pumpe      (t,tt) Bidding-Curve im Pumpbetrieb monoton

*Pruefung 2
g_Reibungsverluste        (t)    Reibungsverluste im Triebwasserweg
g_Triebwasserdurchfluss   (t)    Durchfluss im Triebwasserweg
g_Verlust_SummenLambda    (t)    Summe der Gewichte entspricht 1
;

*Teil a

*g_Profit .. v_Erloes =e= sum(t, (Preis(t) - Gebuehr_Ein) * v_P_Turb(t) - (Preis(t) + Gebuehr_Ent) * v_P_Pump(t));

g_Turbine_Durchfluss_Min(t) .. v_Q_Turb(t) =g= v_MS_Turbine(t) * Q_min;
g_Turbine_Durchfluss_Max(t) .. v_Q_Turb(t) =l= v_MS_Turbine(t) * Q_max;
g_Pumpe_Durchfluss(t) .. v_Q_Pump(t) =e= v_MS_Pumpe(t) * Q_pump;

g_Speicherinhalt(t) .. v_Inh(t) * 1000000=e= v_Inh(t-1) * 1000000 + I_Start$(Ord(t)=1) * 1000000 + Dargebot * 3600 - v_Q_Turb(t) * 3600 +  v_Q_Pump(t) * 3600;
g_EndSpeicherinhalt(t)$(Ord(t)=168) .. v_Inh(t) =e= I_Start;
g_MaxSpeicherinhalt(t) .. v_Inh(t) =l= I_max;

* Box Constraints
* Alternativ zu Nebenbedingungen bei Equations
* v_Inh.up      (t)         = I_max;
* v_Inh.fx      (t_ende)    = I_Start;

g_Max_MS_Pumpe(t) .. v_MS_Pumpe(t) =l= Anzahl_MS;
g_Max_MS_Turbine(t) .. v_MS_Turbine(t) =l= Anzahl_MS;

g_Linearisierung_1(t) .. v_P_Turb(t)  =e= sum(n, v_stuetze(t,n) * P_Stuetz(n));
g_Linearisierung_2(t) .. v_Q_Turb(t)  =e= sum(n, v_stuetze(t,n) * Q_Stuetz(n));
g_Linearisierung_3(t) .. v_MS_Turbine(t) =e= sum(n,v_stuetze(t,n));

g_Pumpe_Leistung(t) .. v_P_Pump(t) =e= 9.81 / 1000 * v_Q_Pump(t) / eta_pump * H;

*Teil b

g_BiddingCurve_Turbine(t,tt) .. v_P_Turb(t) =g= v_P_Turb(tt)$(Preis(t)>Preis(tt));
g_BiddingCurve_Pumpe(t,tt)   .. v_P_Pump(t) =g= v_P_Pump(tt)$(Preis(t)<Preis(tt));

*Pruefung 2
* Verlustleistung der Turbine
g_Profit                     .. v_Erloes =e= sum(t,(Preis(t)-12)*(v_P_Turb(t)-v_Pv_Turb(t))-(Preis(t)+20)*(v_P_Pump(t)));

g_Reibungsverluste(t)        .. v_Pv_Turb(t) =e= sum(n,v_lambda_Verlust(t,n)*P_vStuetz(n));
g_Triebwasserdurchfluss(t)   .. v_Q_Turb(t) =e= sum(n,v_lambda_Verlust(t,n)*Q_vStuetz(n));
g_Verlust_SummenLambda(t)    .. sum(n,v_lambda_Verlust(t,n)) =e= 1;

Model STHP /all/;

* Wähle passenden Solver
Option MIP = CPLEX;

Solve STHP using MIP maximizing v_Erloes;

* Output als gdx-File (funktioniert nur, wenn Lösung schon vorhanden)
execute_unload "results.gdx" v_P_Turb.L v_P_Pump.L v_Q_Turb.L v_Q_Pump.L v_Inh.L v_Erloes.L
* Output in xlsx-File
execute 'gdxxrw.exe  results.gdx o=Input-Output_Kurzfristig.xlsx squeeze=N var=v_Inh.L rng=Output!C3 rdim=1 cdim=0'
execute 'gdxxrw.exe  results.gdx o=Input-Output_Kurzfristig.xlsx squeeze=N var=v_P_Pump.L  rng=Output!B3 rdim=1 cdim=0'
execute 'gdxxrw.exe  results.gdx o=Input-Output_Kurzfristig.xlsx squeeze=N var=v_P_Turb.L  rng=Output!A3 rdim=1 cdim=0'
execute 'gdxxrw.exe  results.gdx o=Input-Output_Kurzfristig.xlsx squeeze=N var=v_Erloes.L rng=Output!G1 rdim=0 cdim=0'
