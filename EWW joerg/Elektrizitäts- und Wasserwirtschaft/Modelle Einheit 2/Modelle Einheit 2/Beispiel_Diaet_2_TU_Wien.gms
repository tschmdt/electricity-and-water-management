

set x /1*4/;

parameter
Energieinhalt (x)
/
1        15.4912
2        6.4477
3        2.8052
4        12.5281

/

Protein (x)
/
1        0.1253
2        0.1300
3        0.0330
4        0.0310

/
Calcium (x)
/
1        0.5400
2        0.5000
3        1.2000
4        0.5000

/

Preis(x)
/
1        0.0040
2        0.0042
3        0.0010
4        0.0098

/
;

variable zz;
positive variable v_Menge(x);
integer variable v_int_ei;

equation
cost Zielfunktional
NB_Energie
NB_Protein
NB_Calzium
NB_Einseitigkeit(x)
NB_GenugMilch
NB_Int_Ei
;

cost .. zz =e= sum(x,v_Menge(x)*Preis(x));
NB_Energie .. sum(x,v_Menge(x)*Energieinhalt(x)) =g= 10467;
NB_Protein .. sum(x,v_Menge(x)*Protein(x)) =g= 70;
NB_Calzium .. sum(x,v_Menge(x)*Calcium(x)) =g= 1000;
NB_Einseitigkeit(x) .. v_Menge(x) =g=  50;
NB_GenugMilch .. sum(x$(ord(x)=1),v_Menge(x))*3 =l= sum(x$(ord(x)=3),v_Menge(x));
NB_Int_Ei .. v_int_ei*60 =e= v_Menge('2');
*NB_GenugMilch ..v_Menge('1')*3 =l= v_Menge('3');

model Diaet /cost,NB_Energie,NB_Protein,NB_Calzium/;
*model Diaet /cost,NB_Energie,NB_Protein,NB_Calzium,NB_GenugMilch/;
*model Diaet /cost,NB_Energie,NB_Protein,NB_Calzium,NB_GenugMilch,NB_Int_Ei/;
*model Diaet /cost,NB_Energie,NB_Protein,NB_Calzium,NB_Einseitigkeit,NB_GenugMilch,NB_Int_Ei/;

solve Diaet using mip minizing zz;

file results Ergebnis /Output1.txt/;

put results/;

         put zz.l :>8:2;
         put /;
         loop(x,
                 put v_Menge.l(x) :>8:2;
                 put /;
         );
;

