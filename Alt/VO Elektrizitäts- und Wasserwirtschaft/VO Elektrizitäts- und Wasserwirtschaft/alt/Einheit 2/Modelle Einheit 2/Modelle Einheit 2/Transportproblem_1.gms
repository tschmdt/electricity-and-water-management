set i /1*3/
set j /1*7/

parameter
Transportkosten(i,j)
/
1        .        1        =        9.5
2        .        1        =        2.1
3        .        1        =        4.2
1        .        2        =        7.5
2        .        2        =        5.8
3        .        2        =        0.2
1        .        3        =        3.7
2        .        3        =        8.8
3        .        3        =        4.6
1        .        4        =        0.1
2        .        4        =        5.2
3        .        4        =        6.5
1        .        5        =        3.8
2        .        5        =        4.2
3        .        5        =        5.4
1        .        6        =        3.4
2        .        6        =        9.6
3        .        6        =        0.7
1        .        7        =        0.3
2        .        7        =        9.1
3        .        7        =        1.3

/

Produktion(i)
/
1        10
2        10
3        15
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

positive variable Menge(i,j);
variable zz;
integer variable int_container_5(j);


equations
cost
e_SumProduktion (i)
e_SumVerbrauch (j)
e_Mindesttransport
e_Container(j)
;


cost .. zz =e= sum((i,j), Menge(i,j)*Transportkosten(i,j));
e_SumProduktion(i) .. sum(j, Menge(i,j)) =e=  Produktion(i);
e_SumVerbrauch(j) .. sum(i, Menge(i,j)) =e=  Verbrauch(j);
e_Mindesttransport .. Menge('1','4') =g= 2;
e_Container(j) .. Menge('3',j) =e= int_container_5(j)*5;


*model Transport /cost,e_SumProduktion,e_SumVerbrauch/;
*model Transport /cost,e_SumProduktion,e_SumVerbrauch,e_Mindesttransport/;
model Transport /cost,e_SumProduktion,e_SumVerbrauch,e_Container,e_Mindesttransport/;


*solve Transport using lp minimizing zz;
solve Transport using mip minimizing zz;


file results1 Ergebnis /Output1.txt/;


put results1/;

         put zz.l :>8:2; put /;
         loop(i,
                loop(j,
                      put Menge.l(i,j) :>8:2;
                )
                put /;
         )
;


$gdxout results_gdx;
execute_unload  'results_gdx' , zz, Menge, int_container_5, cost, e_SumProduktion, e_SumVerbrauch, e_Mindesttransport, e_Container ;