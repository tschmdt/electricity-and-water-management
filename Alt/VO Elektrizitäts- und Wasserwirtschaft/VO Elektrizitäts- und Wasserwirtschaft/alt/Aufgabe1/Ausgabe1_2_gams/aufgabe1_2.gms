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
            Zielfunktion  
            Nebenbdg1(i)      Nebenbedingung Inhalt
            Nebenbdg2         Nebenbedingung 3xMilch wie Haferflocken Aufgabe 1_2
            Nebenbdg3         Ei nur im Stück von 60g Aufgabe 1_3
            Nebenbdg31        Ei min. 60g da Nebenbdg 4 min. 50g vorsieht
            Nebenbdg4(j)      Alle Zutaten min 50g Aufgabe 1_4
            ;
            Zielfunktion ..   z =e= sum(j, p(j) * y(j))      ;
            Nebenbdg1(i) ..   sum(j, a(i,j) * y(j)) =g= b(i) ;
            Nebenbdg2 ..      y('Milch') =g= 3*y('Hafer');  #Aufgabe 1_2
            Nebenbdg3 ..      y('Eier') =e= 60*div(y('Eier'),60); #Aufgabe 1_3 div = Ganzzahldivision
            Nebenbdg31 ..     y('Eier') =g= 60; #Aufgabe 1_3
            Nebenbdg4(j) ..  y(j) =g= 50; #Aufgabe 1_4    
            
          
Model Muesli /all/  ;

Solve Muesli using NLP minimizing z  ;  #NLP benutzt da div in Nebenbdg3 keine konstanten Werte hat bei Berechnung

file results /Output.txt/;
    put results/;
    put z.l:>8:2//;
    loop(j, put y.l(j):>8:2 /;);
       


