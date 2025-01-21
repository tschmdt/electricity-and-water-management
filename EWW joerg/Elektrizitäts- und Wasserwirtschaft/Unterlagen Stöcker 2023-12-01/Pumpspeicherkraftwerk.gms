Sets
t /1*768/
;

Parameters
$include Spot.txt

*Speicher
GMax_Speicher Installierte Leistung d SpeicherKW  /300/
PMax_Speicher Installierte Pumpleistung d SpeicherKW/300/
MaxVolume_Speicher Max Speichervolumen  / 2000/
Vol_Start Speichervolumen zur Zeit 0 / 1500/
Vol_Ende Speichervolumen am Ende d Optimierungshorizontes / 1000/
Inflow Zufluss in den Speicher je Stunde / 10/
P_eta Wirkungsgrad Pumpe/ 0.75/
;


Variables
Gewinn
;

Positive Variables
GenSpeicher(t)   Erzeugung Speicher
GenPumpe(t) Erzeugung Pumpe
Volume_Speicher(t)  Speichervolumen im Zeitpunkt t
;


Equations
g_Profit   Erloesgleichung
g_MaxSpeicher    max Erzeugung des Speichers
g_Speicherinhalt   Speicherinhaltsgleichung
g_StartSpeicherinhalt    Startbedingung Speicher
g_MaxSpeicherinhalt     Begrenzung d Speichers
g_EndSpeicherinhalt Enbedingung Speicher
g_MaxPumpe  Maximale Pumpleistung
;


g_Profit .. Gewinn =e= sum(t,Spot(t)*( GenSpeicher(t)-GenPumpe(t))  )  ;

g_MaxSpeicher(t) .. GenSpeicher(t) =l=  GMax_Speicher;
g_MaxSpeicherinhalt(t) ..       Volume_Speicher(t)=l= MaxVolume_Speicher;
g_Speicherinhalt(t)$(ord(t)>1) ..     Volume_Speicher(t)=e=Volume_Speicher(t-1)+Inflow-GenSpeicher(t)+  GenPumpe(t)*P_eta   ;
g_StartSpeicherinhalt(t)$(Ord(t)=1)  ..    Volume_Speicher(t) =e=     Vol_Start;
g_EndSpeicherinhalt(t)$(Ord(t)=768) ..        Volume_Speicher(t) =e=     Vol_Ende;
g_MaxPumpe(t) ..           GenPumpe(t) =l=  PMax_Speicher;



Model Fundamentalmodell /all/ 
gams Fundamentalmodell gdx=default
;

Solve Fundamentalmodell using LP maximizing Gewinn ;

execute_unload  'Ergebnis'


file results1  /speichereinsatz.txt/;
*results3.pw = 1000;
put results1;
put 'Gesamt Gewinn (Mio):':20:20 (Gewinn.l/1000000) :20:6  /
put't':12:3,'Spot':12:3,'SpeicherStand':12:3,'Gen Speicher':12:3,'Pumpe':12:3/
loop(t,put , ord(t):12:3, Spot(t):12:3, Volume_Speicher.l(t):12:3,GenSpeicher.l(t):12:3, GenPumpe.l(t):12:3 /);



