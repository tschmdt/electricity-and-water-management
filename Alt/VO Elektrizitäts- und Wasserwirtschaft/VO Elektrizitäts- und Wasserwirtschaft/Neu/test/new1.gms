
Sets
i   Stunden in einer Woche  /1*168/;

Parameters
h_const    konstante Fallhoehe /410/
qp_min      minimaler Turbinendurchfluss /16/
qp_max     maximaler Turbinendurchfluss /40/
qp_pump    Pumpenförderstrom  /35/
;
Scalar
eff_pump /0.92/;
*Wirkungsgrad im Pumpbetrieb

*! Tabelle für stückweise lineare Approximation des Turbinenwirkungsgrades
Table eta_turbine(i,qp_min*100..qp_max*100)  
       16    17    18    19    ...    39    40
1      .     .     .     .     ...     .     .
2      .     .     .     .     ...     .     .
...    .     .     .     .     ...     .     .
168    .     .     .     .     ...     .     .;

Parameters
storage_start /40/
*! Anfangsinhalt des Oberliegers
storage_end /40/
*! Endinhalt des Oberliegers
storage_max /60/
*! maximaler Inhalt des Oberliegers
inflow /2/
*! natürlicher Zufluss in den Oberlieger

Scalar
fee_injection /12/
*! Systemnutzungsentgelt für Einspeisung
fee_withdrawal /20/
*! Systemnutzungsentgelt für Entnahme

Variables
qp(i)    ! Turbinendurchfluss
qpp(i)   ! Pumpenförderstrom
h(i)     ! Höhendifferenz
storage(i)  ! Speicherinhalt

Positive Variables qp, qpp, h, storage;

Equations
objective   ! Ziel: Gewinnmaximierung
constraint1  ! Nebenbedingung: Energiebilanz
constraint2  ! Nebenbedingung: Speicherinhalt

objective .. sum(i, (eta_turbine(i, qp(i)) * (fee_injection - fee_withdrawal) - fee_injection) * (qp(i) - qpp(i) / eff_pump)) =e= z;

constraint1(i) .. qp(i) + qpp(i) =l= inflow;  ! Energiebilanz

constraint2(i)$i.. storage(i-1) + inflow - h(i)/h_const * qp(i) =e= storage(i);  ! Speicherbilanz
constraint2(i=1).. storage_start + inflow - h(i)/h_const * qp(i) =e= storage(i);  ! Anfangsbedingung

Model bidding_curve /all/;
solve bidding_curve using mip maximizing objective;

Display qp.l, qpp.l, h.l, storage.l;
