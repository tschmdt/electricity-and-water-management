Sets
t /1*768/
;

Parameters
$include Spot.txt
$include GasPreis.txt
$include Co2Preis.txt

*Speicher
GMax_Speicher Installierte Leistung d SpeicherKW  /300/
PMax_Speicher Installierte Pumpleistung d SpeicherKW/300/
MaxVolume_Speicher Max Speichervolumen  / 2000/
Vol_Start Speichervolumen zur Zeit 0 / 1500/
Vol_Ende Speichervolumen am Ende d Optimierungshorizontes / 1000/
Inflow Zufluss in den Speicher je Stunde / 10/
P_eta Wirkungsgrad Pumpe/ 0.75/

*Gas und Dampf Kraftwerk
MaxLeistungGuD  Installierte Leistung des GasKW   /500/
eff_GuD  Wirkungsgrad GasKW /0.6/
Erzeugungskosten_GuD(t) Erzeugngskosten des GuDs je Stunde
*Aufgabe 1b
Startkosten_GuD Startkosten GasKW/10000/
MinLast_GuD  MinLlast_GuD GasKW/0.4/

*Aufgabe 2
*Gasturbine
MaxLeistungGasTurbine Installierte Leistung einer Gasturbine /300/
Erzeugungskosten_GasTurbine Erzeugungskosten Gasturbine /70/

MaxLeistungLW Installierte Leistung einer Gasturbine /250/

;

Erzeugungskosten_GuD(t)= GasPreis(t)/eff_GuD+0.2*Co2Preis(t)/eff_GuD

Variables
Gewinn
;

Positive Variables
*Speicherkraftwerk
GenSpeicher(t)   Erzeugung Speicher
GenPumpe(t) Erzeugung Pumpe
Volume_Speicher(t)  Speichervolumen im Zeitpunkt t

*GuD
Erzeugung_GuD(t) Erzeugung des GuD im Zeipunkt t
*Aufgabe 1b
Startkosten_GasKW(t)   Startkosten GasKW
ON(t)   Betriebszustand GasKW

*Aufgabe 2
Erzeugung_GT(t) Erzeugung der Gasturbine im Zeipunkt t
Erzeugung_LW(t) Erzeugung Laufwasserkraftwerk im Zeitpunkt t
;


Equations
*Zielfunktion
g_Profit   Erloesgleichung
*Speicher
g_MaxSpeicher    max Erzeugung des Speichers
g_Speicherinhalt   Speicherinhaltsgleichung
g_StartSpeicherinhalt    Startbedingung Speicher
g_MaxSpeicherinhalt     Begrenzung d Speichers
g_EndSpeicherinhalt Enbedingung Speicher
g_MaxPumpe  Maximale Pumpleistung

*GuD
g_MaxLeistungGuD  Gas KW kann max installierte Leistung erzeugen
*Aufgabe 1b
g_Startkosten   Startkosten GasKW
g_MinGeneration  Mindestlast GasKW
g_Online      Betriebszustand GasKW

*Aufgabe 2
g_MaxLeistungGT die Gasturbine kann maximal die installierte Leistung erzeugen
g_MaxLeistungLW das Laufwasserkraftwerk kann maximal die installierte Leistung erzeugen


;


g_Profit .. Gewinn =e= sum(t,Spot(t)*( GenSpeicher(t)-GenPumpe(t)) +(Spot(t)-Erzeugungskosten_GuD(t))*Erzeugung_GuD(t)- Startkosten_GasKW(t) + (Spot(t)-Erzeugungskosten_GasTurbine)*Erzeugung_GT(t) +Spot(t)*Erzeugung_LW(t) )  ;

*Speicher
g_MaxSpeicher(t) .. GenSpeicher(t) =l=  GMax_Speicher;
g_MaxSpeicherinhalt(t) ..       Volume_Speicher(t)=l= MaxVolume_Speicher;
g_Speicherinhalt(t)$(ord(t)>1) ..     Volume_Speicher(t)=e=Volume_Speicher(t-1)+Inflow-GenSpeicher(t)+  GenPumpe(t)*P_eta   ;
g_StartSpeicherinhalt(t)$(Ord(t)=1)  ..    Volume_Speicher(t) =e=     Vol_Start;
g_EndSpeicherinhalt(t)$(Ord(t)=768) ..        Volume_Speicher(t) =e=     Vol_Ende;
g_MaxPumpe(t) ..           GenPumpe(t) =l=  PMax_Speicher;

*GuD Aufgabe 1 b
g_MaxLeistungGuD(t) .. Erzeugung_GuD(t) =l=  MaxLeistungGuD*ON(t);
g_Startkosten(t) .. Startkosten_GasKW(t) =g= Startkosten_GuD*(ON(t)-ON(t-1));
g_MinGeneration(t) .. Erzeugung_GuD(t) =g=  MinLast_GuD*MaxLeistungGuD*ON(t);
g_Online(t) .. ON(t)=l=1;

*Aufgabe 2
g_MaxLeistungGT(t) ..    Erzeugung_GT(t) =l=   MaxLeistungGasTurbine;
g_MaxLeistungLW(t)  ..    Erzeugung_LW(t) =l=   MaxLeistungLW;


Model Fundamentalmodell /all/ 
gams Fundamentalmodell gdx=default
;

Solve Fundamentalmodell using LP maximizing Gewinn ;
execute_unload  'Ergebnis_Aufgabe2'

file results2  /Aufgabe_2.txt/;
*results3.pw = 1000;
put results2;
put 'Gesamt Gewinn (Mio):':20:20 (Gewinn.l/1000000) :20:6  /
put't':20:0,'Spot':20:2,'SpeicherStand':20:0,'Turbine':20:0,'Pumpe':20:0,'ErzKosten':20:0,'StartKosten':20:0,'Erzeugung GuD':20:0, 'Erzeugung GT':20:0, 'Erzeugung LW'20:0/
loop(t,put , ord(t):20:0, Spot(t):20:2, Volume_Speicher.l(t):20:0,GenSpeicher.l(t):20:0, GenPumpe.l(t):20:0, Erzeugungskosten_GuD(t):20:0, Startkosten_GasKW.l(t):20:3, Erzeugung_GuD.l(t):20:0,Erzeugung_GT.l(t):20:0,Erzeugung_LW.l(t):20:0 /);



