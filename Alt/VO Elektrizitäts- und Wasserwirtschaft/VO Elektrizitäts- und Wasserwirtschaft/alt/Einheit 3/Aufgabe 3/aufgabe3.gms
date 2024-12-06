$eolCom #

Sets
    t Zeitintervalle /1*769/;
 

Parameters    
$include StundenStromPreise.txt #Spot(t)
;


Variables
    
    g       Gewinn
    ;
    
Positive Variable
    f(t)    Füllstand
    pl(t)   Pumpleistung
    tl(t)   Turbinierleistung
    ;




Equations
    Gewinnfunktion
    Pumpleistung
    Turbinierleistung
    Fuellstand_max
    Fuellstand_ende
    Fuellstand_start
    Fuellstand2
    ;
    
    Gewinnfunktion ..               g =e= sum(t$(ord(t)>1), tl(t)*Spot(t)-pl(t)*Spot(t));
    Pumpleistung(t) ..              pl(t) =l= 300;
    Turbinierleistung(t) ..         tl(t) =l= 300;
    
    Fuellstand_max(t) ..            f(t) =l= 2000;
    Fuellstand_ende ..              f('769') =e= 1000;
    Fuellstand_start ..             f('1') =e= 1500;
    Fuellstand2(t)$(ord(t) > 1)..  f(t) =e= f(t-1)+10+0.75*pl(t)-tl(t); 
    
    
    
    
    

Model Pumpspeicherkraftwerk /all/;

Solve Pumpspeicherkraftwerk using LP maximizing g;


file results /Output.txt/;
    put results/;
    put 'Umsatz:',g.l:>15:2//;
    put 'h','    Fuellstand','    Turbinierleistung','    Pumpleistung' /;
    loop(t, put t.tl:0, '  ',f.l(t):>8:2 ,'           ',tl.l(t):>8:2,'        ',pl.l(t):>8:2/;)
    

    