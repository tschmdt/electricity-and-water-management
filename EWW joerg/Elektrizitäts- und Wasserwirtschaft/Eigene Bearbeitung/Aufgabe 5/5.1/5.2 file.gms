$eolCom #

Sets
 n            Index Stützstellen für Modellierung Turbinen-Wirkungsgrad            /n0* n20/
 t            Zeitpunkt bzw. Stunde                                                /t1*t168/
 t_start(t)      Zeitpunkt Start                                                      /t1/
 t_ende(t)       Zeitpunkt Ende                                                       /t168/
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
 Netzk_ein    Netzentgelte für Einspeisung [Euro pro MWH]                             /  12/
 Netzk_ent    Netzentgelte für Entnahme    [Euro pro MWH]                             /  20/
;

Parameters
 Preis    (t)  Prognose des Spot-Markt-Preis in der Stunde von t-1 bis t (Preis innerhalb einer Stunde)
 Q_Stuetz (n)  Stützstellen (verschiedene Durchflüsse) für die Leistungskennlinie
 P_Stuetz (n)  Zugehörige Leistungen an den Stützstellen für die Leistungskennlinie
 ;

* Einlesen der prognostitierten Strompreise aus dem .xlsx-File
$CALL   GDXXRW.EXE  Input-Output_Kurzfristig.xlsx Par=Preis rng=Input!A3:B170 Cdim=0 Rdim=1 Trace = 3
$GDXIN  Input-Output_Kurzfristig
$LOAD   Preis
$GDXIN
;

* Äquidistante Stützstellen von Q und zugehörige Leistungen P der Leistungskennlinie
 Q_Stuetz(n)                            = (ord(n)-1)/(card(n)-1)*Q_max; #nachfragen warum ord(n)-1 bzw. card(n)-1 Antwort: Start mit n=0 und 21 Schritte deshalb 
 P_Stuetz(n)$(Q_Stuetz(n)/Q_max>0.095)  =  H*Q_Stuetz(n)*9.81/1000*(Q_Stuetz(n)/Q_max-0.095)/(0.18+0.63*(Q_Stuetz(n)/Q_max-0.095)+0.31*(Q_Stuetz(n)/Q_max-0.095)**2); #Leistung in MW
 P_Stuetz(n)$(Q_Stuetz(n)/Q_max<0.095)  =  0;

Variables
 v_Erloes                Erlös [EUR]
 v_Angebotene_Leistung(t)   Angebotene Leistung [MW]
;
Positive variables 
 v_Inh            (t  )  Betriebsinhalt des Speichers (Oberlieger) zum Zeitpunkt t [hm3]
 v_P_Turb         (t  )  Abgegebene Leistung im Turbinenbetrieb des Kraftwerkes in der Stunde von t-1 bis t [MW]
 v_P_Pump         (t  )  Aufgenommene Leistung im Pumpbetrieb des Kraftwerkes in der Stunde von t-1 bis t [MW]
 v_Q_Turb         (t  )  Summierte Turbinendurchflüsse der Maschinensätze des Kraftwerkes in der Stunde von t-1 bis t [m3 pro s]
 v_Q_Pump         (t  )  Summierte Pumpenförderströme der Maschinensätze des Kraftwerkes in der Stunde von t-1 bis t [m3 pro s]
;
SOS2 Variables
lambda            (t, n  )  SOS2 variablen  entsprechen Gewichtungsfaktoren der Konvexkombinationen der Stutzstellen
;

Integer Variable
iv_Pump_on(t)
iv_Turb_on(t)
;

*Box Constraints
v_Inh.fx(t_ende(t)) = I_Start;
v_Inh.up(t) = I_max;
iv_Turb_on.up(t) = Anzahl_MS;
iv_Pump_on.up(t) = Anzahl_MS;

Equations
e_Erloes
*e_Speicher_Start
*e_Speicher_Ende
*e_Speicher_Max
e_Betriebsinhalt
e_Turbinenbetrieb_Durchfluss
e_Turbinenbetrieb_Leistung
e_Maschinensatzbedingung
e_Max_Turbinendurchfluss
e_Min_Turbinendurchfluss
*e_Pumpmaschinensatz
e_Pumbenbetrieb_Durchfluss
e_Pumpenbetrieb_Leistung
*e_Turbinenmaschinensatz
e_Angebotene_Leistung
;

e_Erloes .. v_Erloes =e= Sum(t, Preis(t) * v_P_Turb(t) - Preis(t) * v_P_Pump(t) - Netzk_ent * v_P_Pump(t) - Netzk_ein * v_P_Turb(t));

*Speicher:

*e_Speicher_Start(t) .. v_Inh('t1') =e= I_Start; #in [hm3]

*e_Speicher_Ende(t) .. v_Inh('t168') =e= I_Start; #in [hm3]

*e_Speicher_Max(t) .. v_Inh(t) =l= I_max; # in [hm3]

e_Betriebsinhalt(t) .. v_Inh(t) - v_Inh(t-1) - I_Start$(t_start(t)) =e= (3600 / (10**6)) * (Dargebot - v_Q_Turb(t) + v_Q_Pump(t)); # hm^3 =  m^3 / s -> 10^6 m^3 = 3600 * m^3 / h * 1h

*Turbine:

e_Turbinenbetrieb_Durchfluss(t) .. v_Q_Turb(t) =e= Sum(n, lambda(t, n) * Q_Stuetz(n));

e_Turbinenbetrieb_Leistung(t) .. v_P_Turb(t) =e= Sum(n, lambda(t, n) * P_Stuetz(n));

e_Max_Turbinendurchfluss(t) .. v_Q_Turb(t) =l= Q_max *  iv_Turb_on(t);

e_Min_Turbinendurchfluss(t) .. v_Q_Turb(t) =g= Q_min *  iv_Turb_on(t);

*e_Turbinenmaschinensatz(t) .. iv_Turb_on(t) =l= Anzahl_MS;

e_Maschinensatzbedingung(t) .. Sum(n,lambda(t,n)) =e= iv_Turb_on(t);

*Pumpe:

e_Pumbenbetrieb_Durchfluss(t) .. v_Q_Pump(t) =e= Q_pump * iv_Pump_on(t);
* e_pot = m*g*h = roh * V * g * h für die Leistung Energie nach Zeit ableiten p_mech = roh * Q * g * h mit [roh] = 1000 kg/m^3; [Q] = m^3/s; [g] = m/s^2; [h] = m
* p_mech in p_el: dafür p_el = p_mech/eta_pump mit p_el in MW, dafür p_el/10^6
e_Pumpenbetrieb_Leistung(t) ..  v_P_Pump(t) =e= (1000*v_Q_Pump(t)*9.81*H)/(1000000*eta_pump);

*e_Pumpmaschinensatz(t) .. iv_Pump_on(t) =l= Anzahl_MS;

*Zusatzaufgabe:

e_Angebotene_Leistung(t) .. v_Angebotene_Leistung(t) =e= v_P_Turb(t) - v_P_Pump(t);





model Aufgabenstellung /all/

* Wähle passenden Solver
Option MIP = CPLEX;

solve Aufgabenstellung using MIP maximising v_Erloes;

* Output als gdx-File (funktioniert nur, wenn Lösung schon vorhanden)
execute_unload "results.gdx" v_P_Turb.L v_P_Pump.L v_Q_Turb.L v_Q_Pump.L v_Inh.L v_Erloes.L
* Output in xlsx-File
execute 'gdxxrw.exe  results.gdx o=Input-Output_Kurzfristig.xlsx squeeze=N var=v_Inh.L rng=Output!C3 rdim=1 cdim=0'
execute 'gdxxrw.exe  results.gdx o=Input-Output_Kurzfristig.xlsx squeeze=N var=v_P_Pump.L  rng=Output!B3 rdim=1 cdim=0'
execute 'gdxxrw.exe  results.gdx o=Input-Output_Kurzfristig.xlsx squeeze=N var=v_P_Turb.L  rng=Output!A3 rdim=1 cdim=0'
execute 'gdxxrw.exe  results.gdx o=Input-Output_Kurzfristig.xlsx squeeze=N var=v_Erloes.L rng=Output!G1 rdim=0 cdim=0'

*Anlegen des .txt Files Output
File Results
/Output.txt/
;
*Alle weitere 'put' geht in Result
put Results;

*'Gesamt Kosten (Mio):':20:20 reserviert 20 Zeichen mit 20 Dezimalstellen für den Ausgabetext, Slash macht neue Zeile
*put 'Kosten (Mio):':20:20, (v_kosten.l/1000000) :20:6  /
put 'Preis [EUR pro MWh':12:3,'Angebotene Leistung in MW':28:3/
loop(t,put , v_Erloes.l:12:3, v_Angebotene_Leistung.m(t):12:3/);
