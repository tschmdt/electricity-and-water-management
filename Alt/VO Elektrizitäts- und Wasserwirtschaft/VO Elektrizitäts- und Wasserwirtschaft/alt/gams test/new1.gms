$eolCom #
# definiert # als Kommentaroperator

$onText
Kommentar
$offText

set x /1*2/ #set sagt index 1 bis 2
;
set y /1*2/
;

Variable
zz
;
positive variable ort(x,y)
;
integer variable v_intX1Y1
;

Parameter   #erster Position, zweiter Wert
a(x,y)/
1.1 1
1.2 1
2.1 1
2.2 1
/
;

Equations
cost
Grenze1(x,y)
Grenze3
IntOrtX1Y1(x,y)
;

$onText
=e= entspricht = ... equal
=l= entspricht kleiner, low
$offText

cost .. zz =e= sum((x,y), ort(x,y));    
#Grenze1 .. x =l= 1;    
#Grenze2 .. y =l= 1;
Grenze1(x,y) .. ort(x,y) =l= 1;
IntOrtX1Y1(x,y) .. ort('1','1') =e= v_intX1Y1;

Grenze3 .. sum((x,y), ort(x,y)*a(x,y)) =l= 1;

model position /cost, Grenze1, Grenze3, IntOrtX1Y1/;   

solve position using mip maximize zz;

$onText
file results /Output.txt/;
put results/;

    put zz.l:>8:2;
    loop(x,
    loop(y,
            put ort.l(x,y):>8:2;
    )
    )
$offText