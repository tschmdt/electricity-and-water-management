Set t /1*769/;

Parameters
$include StundenStromPreise.txt
$include CO2Preis.txt
$include GasPreis.txt

*speicher
P_eta Wirkungsgrad Turbine /0.75/
Pmax_T maximale Leistung Turbine MW /300/
Pmax_Pumpe maximale Leistung Pumpe /300/
Fmax_OB maximale Füllstand Oberbecken  /2000/
Fbeginn_OB Start Füllstand Oberbecken  /1500/
P_zu_OB Zufluss OB MWh /10/
Fend_OB End Füllstand Oberbecken GWh /1000/

*GuD
Pmax_gud maximale Leistung GuD / 500/
P_eta_gud Wirkungsgrad GuD /0.6/
Erzeugungskosten_GuD(t) Erzeugngskosten des GuDs je Stunde
;

Erzeugungskosten_GuD(t)= GasPreis(t)/P_eta_gud + 0.2 * CO2Preis(t)/P_eta_gud;

Variable
Gewinn;

Positive Variable
*speicher
GenSpeicher(t)
GenPumpe(t)
Fuellstand(t)
*GuD
Erzeugung_GuD(t)
Startkosten_GasKW(t)   Startkosten GasKW
;

Fuellstand.fx(t)$(ord(t)=1) = Fbeginn_OB;

Equations
*speicher
e_Profit 
e_MaxSpeicher
e_Speicherinhalt
e_MaxSpeicherinhalt
e_EndSpeicherinhalt
e_MaxPumpe
*GuD
*e_MaxLeistungGuD
;

e_Profit.. Gewinn =e= sum(t,(GenSpeicher(t)- GenPumpe(t))*Spot(t) +(Spot(t)-Erzeugungskosten_GuD(t))*Erzeugung_GuD(t));

e_MaxSpeicher(t).. GenSpeicher(t) =l= Pmax_T;
e_MaxSpeicherinhalt(t)..    Fuellstand(t) =l= Fmax_OB;
e_Speicherinhalt(t)$(ord(t)>1)..    Fuellstand(t) =e= Fuellstand(t-1) + P_zu_OB -GenSpeicher(t) + GenPumpe(t) *P_eta;
e_EndSpeicherinhalt(t)$(ord(t)=card(t)).. Fuellstand(t) =e= Fend_OB;
e_MaxPumpe(t).. GenPumpe(t) =l= Pmax_Pumpe;



Model Fundamentalmodell /all/
gams PumpspeicherKW gdx=default;

solve Fundamentalmodell using LP maximizing Gewinn;

execute_unload  'Ergebnis'


file results1a  /Pump_GuD.txt/;
*results3.pw = 1000;
put results1a;
put't':20:0,'Spot':20:2,'SpeicherStand':20:0,'Turbine':20:0,'Pumpe':20:0,'ErzKosten':20:0,'StartKosten':20:0,'Gen GuD':20:0/
loop(t,put , ord(t):20:0, Spot(t):20:2, Fuellstand.l(t):20:0,GenSpeicher.l(t):20:0, GenPumpe.l(t):20:0, Erzeugungskosten_GuD(t):20:0, Erzeugung_GuD.l(t):20:0 /);

