Set t Stunden
/1*769/
;
Parameters Preis(t)
$include StundenStromPreise.txt
$include GasPreis.txt
$include Co2Preis.txt
;

Parameters
*Pumpspeicherkraftwerk
GMax_Speicher Installierte Leistung des SpeicherKW  /300/
PMax_Speicher Installierte Pumpleistung des SpeicherKW/300/
MaxVolume_Speicher Max Speichervolumen  / 2000/
Vol_Start Speichervolumen zur Zeit 0 / 1500/
Vol_Ende Speichervolumen am Ende d Optimierungshorizontes / 1000/
Inflow Zufluss in den Speicher je Stunde / 10/
P_eta Wirkungsgrad Pumpe/ 0.75/

*GuD
MaxPGuD Installierte Leistung GuD /500/
GuD_eta Wirkungsgrad GuD /0.6/
GuD_cost(t) Erzeugungskosten GuD
;
GuD_cost(t)=  GasPreis(t)/GuD_eta+0.2*Co2Preis(t)/GuD_eta
;

Variables
v_gewinn
;

Positive Variables
*Pumpspeicherkraftwerk
GenSpeicher(t)   Erzeugung Speicher
GenPumpe(t) Erzeugung Pumpe
Volume_Speicher(t)  Speichervolumen im Zeitpunkt t
ON(t) betriebszustand GuD

*GuD
GenGuD(t) Erzuegung GuD

Equations
*Zielfunktion
e_gewinn

*Pumpspeicherkraftwerk
e_MaxSpeicher(t)   max Erzeugung des Speichers
e_Speicherinhalt(t)  Speicherinhaltsgleichung

e_MaxSpeicherinhalt    Begrenzung d Speichers
e_EndSpeicherinhalt Enbedingung Speicher
e_MaxPumpe  Maximale Pumpleistung

*GuD
e_MaxPGuD(t)    Gas KW kann max installierte Leistung erzeugen
*e_mindLastGuD(t) Mindestlast GuD

;

*Speicher
e_maxSpeicher(t) .. GenSpeicher(t) =l= GMax_Speicher;
e_MaxSpeicherinhalt(t) .. Volume_Speicher(t) =l= MaxVolume_Speicher;
e_Speicherinhalt(t)$(ord(t)>1) .. Volume_Speicher(t)=e=Volume_Speicher(t-1)+Inflow-GenSpeicher(t)+  GenPumpe(t)*P_eta   ;
*g_StartSpeicherinhalt(t)$(Ord(t)=1)  ..    Volume_Speicher(t) =e=     Vol_Start;
e_EndSpeicherinhalt(t) $(Ord(t)=card(t)) ..   Volume_Speicher(t) =e=     Vol_Ende;
e_MaxPumpe(t)..  GenPumpe(t) =l= PMax_Speicher;

*GuD
e_gewinn .. v_gewinn =e= sum(t,Spot(t)*(GenSpeicher(t)-GenPumpe(t))+(Spot(t)-GuD_cost(t)*GenGuD(t)))
;
e_MaxPGuD(t) ..  GenGuD(t) =l=  ON(t) * MaxPGuD
;


model GuD_Fundamentalmodell /all/
;
solve GuD_Fundamentalmodell using LP maximiting v_gewinn

*Anlegen des .txt Files Output
File Results
/Output.txt/
;
*Alle weitere 'put' geht in Result
put Results;

