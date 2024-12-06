$eolCom #

Sets
  i Inhaltsstoffe   /Energie, Protein, Calzium/,
  j Produkte      /Hafer, Eier, Milch, Rosinen /;

Parameters
        b(i) Anforderungen an den Inhalt des Mueslis
            /
            Energie     10467
            Protein     70
            Calzium     1000
            /
        p(j) Preis
            /
            Hafer      0.004    
            Eier       0.0042    
            Milch      0.001   
            Rosinen    0.0098
            /;

Table a(i,j) Koeffizientenmatrix
                        Hafer       Eier        Milch       Rosinen
            Energie     15.49116    6.447672    2.805156    12.5281          
            Protein     0.1253      0.13        0.033       0.031   
            Calzium     0.54        0.5         1.2         0.5    
            ;
        
Variables
            y(j) Menge an verwendeten Produkten
            z    Kosten;
            
Positive Variables
            y;
            

Equations
          Zielfunktion  Bezeichner der Zielfunktion
          Nebenbdg(i)   Bezeichner der Restriktionen i  ;
          Zielfunktion ..      z =e= sum(j, p(j) * y(j))      ;
          Nebenbdg(i) ..       sum(j, a(i,j) * y(j)) =g= b(i) ;
          
Model Muesli /all/  ;

Solve Muesli using LP minimizing z  ;

file results /Output.txt/;
    put results/;
    put z.l:>8:2;
    loop(j, put y.l(j):>8:2;);
       


