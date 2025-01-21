Sets
t Zeitschritte                                         /t1*t8760/
i Iterationen für SLP-Verfahren                        /i1*i5   /
j Iterationen für Pegelberechnung aus Energieinhalt    /j1*j30  /
k Index der Koeffezienten der Energieinhaltskurve      /k1*k6   /
;

Scalars
 Peg_min            Absenkziel Speicher [m]                                             / 1665/
 Peg_max            Stauziel Speicher [m]                                               / 1767/
 H_Bezug            Bezugshorizont Energieinhalt [m]                                    /  872/
 E_max              Maximaler Energieinhalt (potentielle Energie) des Speichers [MWh] 
 etaTurb            Gesamtwirkungsgrad im Turbinenbetrieb [1]                           /0.875/
 Qmax_Turb          Maximaler Durchfluss im Turbinenbetrieb [m3 pro s]                  / 52.0/
 Peg_Untergrenze    Untergrenze Pegelstand für das Bisektionsverfahren [m]
 Peg_Obergrenze     Obergrenze Pegelstand für das Bisektionsverfahren [m] 
 E_approx           Energieinhalt für das Bisektionsverfahren [MWh]
 
*Pruefung
H_Dargebot Höhe des Dargebots im Nachbartal [m] /1596.5/
Netzkosten Systemnutzungsentgelte im Strombezugsfall 24 [Euro pro MWh] /24/
etaPump Gesamtwirkungsgrad Pumpe /0.8/
;


Parameter  p_Preis(t) Stundenpreis im Zeitraum im Intervall von t-1 bis t [EUR pro MWh];
$CALL  GDXXRW.EXE  Input-Output_Langfristig.xlsx Par=p_Preis rng=Input!A3 Cdim=0 Rdim=1 Trace = 3
$GDXIN Input-Output_Langfristig
$LOAD  p_Preis
$GDXIN
display p_Preis;

Parameter  Dar(t)     Natürlicher Zufluss von t-1 bis t [m3 pro s];
$CALL   GDXXRW.EXE  Input-Output_Langfristig.xlsx Par=Dar rng=Input!C3 Cdim=0 Rdim=1 Trace = 3
$GDXIN  Input-Output_Langfristig
$LOAD   Dar
$GDXIN
display Dar;

Parameters
 E_alt(t)             Energieinhalte aus der vorangegangenen Iteration [MWh] 
 Peg_alt(t)           Pegelstand aus der vorangegangenen Iteration [m]
 Steigung_alt(t)      Steigung der Fallhöhen bzgl. Energieinhalt aus der vorangegangenen Iteration [m pro MWh]
 Koeff(k)             Koeffezienten der Energieinhaltskurve [1]
  /
  k1   115.7511
  k2   -1.14234
  k3   0.3398127
  k4   -0.003401161
  k5   0.00000986934
  k6   0.00000001431875
  /
;

E_max = 9.81/3.6*sum(k,Koeff(k)*(Peg_max-Peg_min)**ord(k));

Variables
 v_Erloes            Gesamterlös [EUR]
;
Positive Variables
 v_Fallhoehe(t)      Fallhöhe zum Zeitpunkt t [m]
 v_EnInh(t)          Energienhalt (brutto) zum Zeitpunkt t [MWh]
 v_P_Turb(t)         Turbinenleistung im Zeitraum von t-1 bis t [MW]
 
*Pruefung
v_Pump(t) Pumpleistung [MW]
*v_Pumphoehe(t) Pumphöhe in [m]
;

v_EnInh.up(t) = E_max;

Equations
 e_Erloes            Gesamterlös (Zielfunktion)
 e_Energieinhalt(t)  Energieinhaltsbilanz des Speichers
 e_PTurb_max(t)      Begrenzung der Turbinenleistung (implizit durch Durchfluss-Obergrenze)
 e_Fallhoehe(t)      Fallhöhe der Turbine (SLP-Approximation aus Energieinhalt)
 
*Pruefung
*e_Pumphoehe(t) Wie hoch muss gepumpt werden
e_Pumpen(t)         Gleichung zur Bestimmung der Pumpleistung

;

 e_Erloes           .. v_Erloes                 =e= sum(t,(p_Preis(t)-16)*v_P_Turb(t)-v_Pump(t)*Netzkosten-v_Pump(t)*p_Preis(t));
 e_Fallhoehe(t)     .. v_Fallhoehe(t)           =e= Peg_alt(t)+Steigung_alt(t)*(v_EnInh(t)-E_alt(t))-H_Bezug;
 e_Energieinhalt(t) .. v_EnInh(t)-v_EnInh(t--1) =e= Dar(t)*v_Fallhoehe(t)*9.81/1000-v_P_Turb(t)/etaTurb;
 e_PTurb_max(t)     .. v_P_Turb(t)              =l= Qmax_Turb*v_Fallhoehe(t)*9.81/1000*etaTurb;
 
*Pruefung
*e_Pumphoehe(t) .. v_Pumphoehe(t) =e=  v_Fallhoehe(t) + H_Bezug - H_Dargebot;
e_Pumpen(t) .. v_Pump(t) =e= (0.24* Dar(t) * 9.81 * 1000 * (v_Fallhoehe(t)+H_Bezug-H_Dargebot))/(1000000/etaPump);

Model Aufgabenstellung /all/

*************************
**** SLP-ALGORITHMUS ****
*************************

* INITALISIERUNG:
loop(t,v_EnInh.l(t) = 9.81/3.6*sum(k,Koeff(k)*((Peg_max-Peg_min)/2)**ord(k)))

* ITERATIONEN:
loop(i,
* I. Ermittlung der Parameter für die (i+1)-te Itertion:
  loop(t,
**** Energieinhalte der i-ten Iteration
     E_alt(t) = v_EnInh.l(t);
**** Pegelstand der i-ten Iteration (Ermittlung mittels Bisektionsverfahren)
     Peg_Untergrenze = Peg_min; Peg_Obergrenze = Peg_max;
     Loop(j,
         Peg_alt(t) = (Peg_Untergrenze+Peg_Obergrenze)/2;
         E_approx = 9.81/3.6*sum(k,Koeff(k)*(Peg_alt(t)-Peg_min)**ord(k));
         if(E_approx>E_alt(t), Peg_Obergrenze=Peg_alt(t));
         if(E_approx<E_alt(t), Peg_Untergrenze=Peg_alt(t));
     );
**** Ableitung des Pegelstands nach dem Energieinhalt an der Stelle des optimalen Energieinhaltes der i-ten Iteration (Ermittlung mittels Umkehrregel)
     Steigung_alt(t) = 1/(9.81/3.6*sum(k,ord(k)*Koeff(k)*(Peg_alt(t)-Peg_min)**(ord(k)-1)));
  );
* II. Lösen des linearen Problems:
 solve Aufgabenstellung using LP maximizing v_Erloes;
 );

****************************

execute_unload "results2.gdx" v_EnInh.L e_Energieinhalt.M
execute 'gdxxrw.exe  results2.gdx o=Input-Output_Langfristig.xlsx squeeze=N Equ=e_Energieinhalt.M   rng=Output!B3 rdim=1 cdim=0'
execute 'gdxxrw.exe  results2.gdx o=Input-Output_Langfristig.xlsx squeeze=N var=v_EnInh.L  rng=Output!A3 rdim=1 cdim=0'

