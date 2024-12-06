
set t /1* 769/
;

Parameters
$include StundenStromPreise.txt


variable Z;
positive variable turbine(t)
positive variable pumpe(t)
positive variable speicher(t)
;

equations
e_cost
e_speicheranfang
e_speicherende
e_speicher(t)
e_speichermax(t)
e_leistung_turbine(t)
e_leistung_pumpe(t)
;

e_cost .. Z =e=  sum(t$(ord(t)>1),turbine(t)*Spot(t)-pumpe(t)*Spot(t));
e_speicheranfang .. speicher('1') =e= 1500;
e_speicherende .. speicher('769') =e= 1000;
e_speicher(t)$(ord(t)>1) .. speicher(t) =e= speicher(t-1) + 10 - turbine(t) + 0.75*pumpe(t);
e_speichermax(t) .. speicher(t) =l= 2000;
e_leistung_turbine(t) .. turbine(t) =l= 300;
e_leistung_pumpe(t) .. pumpe(t) =l= 300;




model Pumpspeicher /all/;

solve Pumpspeicher using lp maximizing Z;

file results1  /speichereinsatz.txt/;

put results1;
put 'Gesamt Gewinn (Mio):':20:20 (Z.l/1000000) :20:6  /
put't':12:3,'Spot':12:3,'SpeicherStand':12:3,'Gen Speicher':12:3,'Pumpe':12:3/
loop(t,put , ord(t):12:3, Spot(t):12:3,
         speicher.l(t):12:3,turbine.l(t):12:3, pumpe.l(t):12:3 /);

