$eolCom #

Set t Stunden
/1*768/;
Parameters Preis(t)
$include Spot.txt
;
Parameters GasPreis(t)
$include GasPreis.txt
;
Parameters Co2Preis(t)
$include Co2Preis.txt
;
Parameters Demand(t)
$include Demand.txt
;

*Parameter können abhängig von anderen Größen z.B. Zeit sein, werden aber nicht variiert vom Solver
Parameters
*Pumpspeicherkraftwerk:
p_Max_Turbinenleistung Max Turbninenleistung in MW /300/
p_Max_Pumpleistung Max Pumpleistung in MW /300/
p_Zufluss Natuerlicher p_Zufluss in MW pro h /10/
p_eta_P Wirkungsgrad Pumpe /0.75/
p_eta_T Wirkungsgrad Turbine /1/
p_Start_Fuellstand Fuellstand Oberbecken zu Beginn in MWh /1500/
p_Ende_Fuellstand Fuellstand Oberbecken am Ende in MWh /1000/
p_Max_Speicherinhalt Maximaler Speicherinhalt Oberbecken in MWh /2000/
*GuD:
p_P_Max_GuD Maximale Leistung elektrisce in MW /500/
p_eta_GuD Wirkungsgrad Gaskraftwerk /0.6/
p_erzeugungskosten_GuD(t) Erzeugungskosten Gaskraftwerk
p_startkosten_GuD Startkosten Gud in EUR pro Start /10000/
*Gasturbine:
p_P_Gt Maximale Leistung Gasturbine in MW /300/
p_c_Gt Erzeugungskosten Gasturbine in EUR pro MWh /70/
*Laufwasserkraftwerk:
p_P_LK Erzeugung Laufwasserkraftwerk in MW /250/
p_c_LK Erzeugungskosten Laufwasserkraftwerk in EUR pro MWh /0/
;

*Variablen werden von Solver variiert um optimalen Gewinn zu modellieren
Variables
v_gewinn Gewinn
;
Positive Variables 
*Pumpspeicherkraftwerk:
pv_pumpen(t) Pumpleistung
pv_turbinieren(t) Turbinenleistung
pv_fuellstand(t) Füllstand Oberbecken
*GuD:
pv_gud_erzeugung(t) Gaskraftwerkserzeugung
pv_start_gud(t) Gibt wechsel zwischen Aus und An an => Startkosten
bv_zustand_gud(t) Zustand GuD (Ein oder Aus)
*Gasturbine:
pv_gasturbinieren(t) Turbinenleistung Gaskraftwerk
*Laufwasserkraftwerk
pv_wasserturbinieren(t) Erzeugung Laufwasserkraftwerk
;



Equations
e_Gewinn
*Pumpspeicherkraftwerk:
e_p_Max_Speicherinhalt(t)
e_pv_fuellstand(t)
e_p_Max_Turbinenleistung(t)
e_p_Max_Pumpleistung(t)
e_fuellstand_start
e_fuellstand_ende
*GuD:
e_max_erzeugung_GuD(t)
e_mindestlast_GuD(t)
e_anfahren_GuD(t)
e_linearisierung(t)
*Gasturbine:
e_erzeugung_Gt(t)
*Laufwasserkraftwerk
e_erzeugung_Lk(t)
;

e_Gewinn .. v_gewinn =e= Sum(t,pv_turbinieren(t) * Preis(t) - pv_pumpen(t) * Preis(t) + pv_gud_erzeugung(t) * Preis(t) - pv_gud_erzeugung(t) * p_erzeugungskosten_GuD(t) - pv_start_gud(t)
+ pv_gasturbinieren(t) * Preis(t) - pv_gasturbinieren(t) * p_c_Gt + pv_wasserturbinieren(t) * Preis(t) - pv_wasserturbinieren(t) * p_c_LK);

*Pumpspeicherkraftwerk:

e_p_Max_Speicherinhalt(t) .. pv_fuellstand(t) =l= p_Max_Speicherinhalt;

e_p_Max_Turbinenleistung(t) .. pv_turbinieren(t) =l= p_Max_Turbinenleistung;

e_p_Max_Pumpleistung(t) .. pv_pumpen(t) =l= p_Max_Pumpleistung;

e_pv_fuellstand(t)$(ord(t)>1) .. pv_fuellstand(t) =e= pv_fuellstand(t-1) - pv_turbinieren(t) / p_eta_T + pv_pumpen(t) * p_eta_P + p_Zufluss;

e_fuellstand_start .. pv_fuellstand('1') =e= p_Start_Fuellstand;

e_fuellstand_ende .. pv_fuellstand('768') =e= p_Ende_Fuellstand;

*GuD:

p_erzeugungskosten_GuD(t) = GasPreis(t) / p_eta_GuD + 0.2 *(Co2Preis(t) / p_eta_GuD);

e_max_erzeugung_GuD(t) .. pv_gud_erzeugung(t) =l= bv_zustand_gud(t) * p_P_Max_GuD;

e_mindestlast_GuD(t) .. pv_gud_erzeugung(t) =g= bv_zustand_gud(t) * p_P_Max_GuD * 0.4;

e_anfahren_GuD(t) .. pv_start_gud(t) =g= p_startkosten_GuD * (bv_zustand_gud(t-1) - bv_zustand_gud(t)); #Hier unerwarteterweiße größer gleich statt ist gleich - Mail an Frau Stöcker #Außerdem Reihenfolge bv-zustand_gud(t) anders als erwartet

e_linearisierung(t) .. bv_zustand_gud(t) =l= 1;

*Gasturbine:

e_erzeugung_Gt(t) .. pv_gasturbinieren(t) =l= p_P_Gt;

*Laufwasserkraftwerk:

e_erzeugung_Lk(t) .. pv_wasserturbinieren(t) =l= p_P_LK;

model Pumpspeicherkraftwerk /all/;
solve Pumpspeicherkraftwerk using mip maximizing v_gewinn;

*Anlegen des .txt Files Output
File Results
/Output.txt/
;
*Alle weitere 'put' geht in Result
put Results;

*'Gesamt Gewinn (Mio):':20:20 reserviert 20 Zeichen mit 20 Dezimalstellen für den Ausgabetext, Slash macht neue Zeile
put 'Gesamt Gewinn (Mio):':20:20, (v_gewinn.l/1000000) :20:6  /
put't':12:3,'Spot':12:3,'SpeicherStand':12:3,'Turbiene':12:3,'Pumpe':12:3,'GuD_Erzeugung':12:3,'Startkosten':12:3, 'Gasturbine':12:3,'Laufwasserkw':12:3/
loop(t,put , ord(t):12:3, Preis(t):12:3,
         pv_fuellstand.l(t):12:3,pv_turbinieren.l(t):12:3, pv_pumpen.l(t):12:3, pv_gud_erzeugung.l(t):12:3,e_anfahren_GuD.l(t):12:3, e_erzeugung_Gt.l(t), e_erzeugung_Lk.l(t) /);



 