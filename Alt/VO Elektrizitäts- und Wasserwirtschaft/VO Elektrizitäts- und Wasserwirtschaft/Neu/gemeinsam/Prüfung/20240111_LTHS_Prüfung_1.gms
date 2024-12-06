$eolCom #

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
 Netzkosten         Systemnutzungsentgeld in [Euro pro MWh]                             /16/
 
 E_max_winter       Maximaler Energieinhalt (potentielle Energie) des Speichers [MWh] im Winter
 Peg_max_winter     Stauziel Speicher [m] im Winter                                      / 1762/
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
 E_alt(t)             Energieinhalte aus der vorangegangenen Iteration  [MWh] 
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

E_max_winter = 9.81/3.6*sum(k,Koeff(k)*(Peg_max_winter-Peg_min)**ord(k));

#ExampleEquation$(50 <= t and t <= 100) =e= 0;

Variables
 v_Erloes            Gesamterlös [EUR]
;
Positive Variables
 v_EnInh(t)          Energienhalt zum Zeitpunkt t [MWh]
 v_Turb(t)           Turbinenleistung zum Zeitpunkt t [MW]
 v_Pegel(t)          Pegelstand in [m]
 v_Fallhoehe(t)
;

*Box Constraint
v_EnInh.up(t) = E_max;
v_EnInh.up(t)$(ord(t)>745 and (ord(t)<5088)) = E_max_winter;
#Aufgabe 1 Absenkung Stauziel



    



display E_max;
display E_max_winter;

#ExampleEquation$(50 <= t and t <= 100) =e= 0;

Equations
 e_Erloes
 e_Pegelstand(t)
 e_Energieinhalt(t)  Energieinhaltsbilanz des Speichers
 e_Fallhoehe(t)
 e_Turbinieren(t)
# e_Energieinhalt_winter(t)  Zweite Lösung Aufgabe 1
;

e_Erloes .. v_Erloes =e= Sum(t, p_Preis(t) * v_Turb(t) - v_Turb(t) * Netzkosten);

e_Pegelstand(t) .. v_Pegel(t) =e=  Peg_alt(t) + Steigung_alt(t) * (v_EnInh(t)- E_alt(t));

e_Fallhoehe(t) .. v_Fallhoehe(t) =e= v_Pegel(t) - H_Bezug;

e_Energieinhalt(t) .. v_EnInh(t) =e= v_EnInh(t--1) + ((Dar(t) * 9.81 * 1000 * v_Fallhoehe(t))/1000000)*1 - (v_Turb(t) / etaTurb)*1;
#Mal 1 steht für mal 1 Stunde um auf MWh zu kommen
#Bei 15-min Intervallen muss mit 0,25h multiplitziert werden

e_Turbinieren(t) .. v_Turb(t) =l=  (Qmax_Turb * 9.81 * 1000 * v_Fallhoehe(t))/1000000;

#e_Energieinhalt_winter(t) .. v_EnInh(t)$(ord(t)>745 and(ord(t)<5088)) =l= E_max_winter;
#Zweite Lösung Aufgabe 1








Model Aufgabenstellung /all/

*************************
**** SLP-ALGORITHMUS ****
*************************

* INITALISIERUNG:
loop(t,v_EnInh.l(t) = 9.81/3.6*sum(k,Koeff(k)*((Peg_max-Peg_min)/2)**ord(k)))
#Zu jedem t wird der Energieinhalt in der Mitte der Pegelständen mit der Summe über alle k's berechnet

* ITERATIONEN:
loop(i,
* I. Ermittlung der Parameter für die (i+1)-te Itertion:
  loop(t,
**** Energieinhalte der i-ten Iteration
     E_alt(t) = v_EnInh.l(t);
     #Hier wird der Energieinhalt in der Mitte der Pegelstände für jedes t in E_alt(t) gespeichert
**** Fallhöhe der i-ten Iteration (Ermittlung mittels Bisektionsverfahren)
     Peg_Untergrenze = Peg_min; Peg_Obergrenze = Peg_max;
     #Hier wird der Min Max Pegelstand erstmals zugewiesen
     Loop(j,
         Peg_alt(t) = (Peg_Untergrenze+Peg_Obergrenze)/2;
#Der vorhergehende Pegelstand wird hier im ersten Durchlauf als Mitte zwischen Min Max festgelegt,
#dann je nach Richtung nach oben oder unten angenähert an den Tatsächlichen Pegelstand
         E_approx = 9.81/3.6*sum(k,Koeff(k)*(Peg_alt(t)-Peg_min)**ord(k));
#Hier wird der approximierte Energieinhalt mit dem Pegelstand MItteangenäherten Pegelstand berechnet
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

