SET t /1*769/;

Parameters
$include StundenStromPreise.txt
;

variable zz;
positive variable turbine(t);
positive variable pumpe(t);
positive variable speicher(t)
;

Equations
Gewinn
speicheranfang
speicherende
e_speicher(t)
speichermax(t)
leistung_turbine(t)
leistung_pumpe(t)
;

Gewinn.. zz =e= sum(t,turbine(t)*Spot(t)-pumpe(t)*Spot(t));
speicheranfang.. speicher('1') =e= 1500;
speicherende.. speicher('769') =e= 1000;
e_speicher(t)$(ord(t)>1) .. speicher(t) =e= speicher(t-1)+10-turbine(t)+pumpe(t)*0.75;
speichermax(t).. speicher(t) =l= 2000;
leistung_turbine(t).. turbine(t)=l= 300;
leistung_pumpe(t)..  pumpe(t)=l= 300;


model Pump /all/;
solve Pump using lp maximizing zz;
*gams Pump gdx=default;

file results1  /Speicherfahrplan.txt/;

*put'Gesamt Gewinn (mio):':':20:20 (Gewinn.l/1000000) :20:6 /
*put 't':12:3, 'Spot':12:3,'Speicherstand' :12:3, 'gen'

