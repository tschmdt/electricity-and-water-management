*Lerninhalte
*Balancegleichung - Temporale Verknüpfung in linearen Modellen
*Widersprüchliche Optimierungsschritte - Modell ist infeasible

set i /1*3/
set j /1*7/
set d /1*6/
set l /1*1/

parameter
Transportkosten(i,j)
/
1        .        1        9.5
2        .        1        2.1
3        .        1        4.2
1        .        2        7.5
2        .        2        5.8
3        .        2        0.2
1        .        3        3.7
2        .        3        8.8
3        .        3        4.6
1        .        4        0.1
2        .        4        5.2
3        .        4        6.5
1        .        5        3.8
2        .        5        4.2
3        .        5        5.4
1        .        6        3.4
2        .        6        9.6
3        .        6        0.7
1        .        7        0.3
2        .        7        9.1
3        .        7        1.3

/
Transportkosten_P_L(i,l) /
1        .        1        3.4
2        .        1        2.9
3        .        1        3.8

/
Transportkosten_L_V(j,l) /
1        .        1        9.6
2        .        1        8.3
3        .        1        7.3
4        .        1        8.0
5        .        1        5
6        .        1        6.3
7        .        1        7.5

/
Produktion(d,i)
/
1.1        12
1.2        12
1.3        15
2.1        12
2.2        12
2.3        15
3.1        12
3.2        12
3.3        15
4.1        0
4.2        12
4.3        15
5.1        12
5.2        12
5.3        15
6.1        12
6.2        12
6.3        15

/

Verbrauch(j)
/
1        4
2        6
3        2
4        8
5        3
6        7
7        5
/

positive variable Menge(d,i,j);
positive variable Menge_P_L(d,i,l);
positive variable Menge_L_V(d,j,l);
variable zz;
integer variable int_container(d,j);
positive variable Lager(d,l);
variable AenderungLager(d,i);

equations
cost
e_SumProduktion (d,i)
e_SumVerbrauch (d,j)
e_balLager(d,l)
*e_SumTransZumLager(d,l)
e_Mindesttransport(d)
e_Mindesttransport_1(d)
e_Container(d,j)
;


cost .. zz =e= sum((d,i,j), Menge(d,i,j)*Transportkosten(i,j))
                 +sum((d,i,l), Menge_P_L(d,i,l)*Transportkosten_P_L(i,l))
                 +sum((d,j,l), Menge_L_V(d,j,l)*Transportkosten_L_V(j,l))
                 +sum((d,l),Lager(d,l)*0);
e_SumProduktion(d,i) .. sum(j, Menge(d,i,j)) + sum(l, Menge_P_L(d,i,l)) =l=  Produktion(d,i);
e_SumVerbrauch(d,j) .. sum(i, Menge(d,i,j)) + sum(l, Menge_L_V(d,j,l)) =e=  Verbrauch(j);
e_balLager(d,l)  .. Lager(d,l) =e=  Lager(d-1,l) + sum(i,Menge_P_L(d,i,l)) - sum(j,Menge_L_V(d,j,l));
e_Mindesttransport(d) .. Menge(d,'1','4') =g= 2;
e_Mindesttransport_1(d)$(Ord(d)<4 or (Ord(d)>4)) .. Menge(d,'1','4') =g= 2;
e_Container(d,j) .. Menge(d,'3',j) =e= int_container(d,j)*5;

*model Transport /cost,e_SumProduktion,e_SumVerbrauch/;
*model Transport /cost,e_SumProduktion,e_SumVerbrauch,e_Mindesttransport/;
*model Transport /cost,e_SumProduktion,e_SumVerbrauch,e_Container,e_Mindesttransport/;

model Transport /cost,e_SumProduktion,e_SumVerbrauch,e_balLager,e_Container,e_Mindesttransport_1/;
*model Transport /cost,e_SumProduktion,e_SumVerbrauch,e_balLager,e_Container/;
*solve Transport using lp minimizing zz;
solve Transport using mip minimizing zz;


file results1 Ergebnis /Output1.txt/;


put results1/;

         put zz.l :>8:4; put /;
         loop(d,
                put(
                 sum((i,j), Menge.l(d,i,j)*Transportkosten(i,j))
                 +sum((i,l), Menge_P_L.l(d,i,l)*Transportkosten_P_L(i,l))
                 +sum((j,l), Menge_L_V.l(d,j,l)*Transportkosten_L_V(j,l))
                 +sum((l),Lager.l(d,l)*0)
                 )
                 put /;
         );
         loop(d,
         loop(i,
                loop(j,
                      put Menge.l(d,i,j) :>8:2;
                )
                put /;
         )
         put /;
         )

         loop(d,
         loop(l,
                 put Lager.l(d,l) :>8:2;
                put /;
         )
         put / ;
         )

         loop(d,
         loop(l,
                loop(i,
                      put Menge_P_L.l(d,i,l) :>8:2;
                 )
                put /;
         )
         put /;
         )

         loop(d,
         loop(l,
                loop(j,
                      put Menge_L_V.l(d,j,l) :>8:2;
                 )
                put /;
         )
         put /;
         )
;


