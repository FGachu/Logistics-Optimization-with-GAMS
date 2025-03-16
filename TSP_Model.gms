$call gdxxrw.exe Data1.xlsx output=Data1.gdx par=d rng=Distance!a1:av42 dim=2 par=a rng=Time!a1:ao2 cdim=1 rdim=0 par=b rng=Time!a5:ao6 cdim=1 rdim=0 par=s rng=Time!a9:ao10 cdim=1 rdim=0 
    

set v /0*40/;


alias(v, i, j);


parameter
   d(i,j)         Half-distance matrix   
   a(i)           Start time window at node i
   b(i)           End time window at node i
   s(i)           Service time at node i
   t(i,j)         Travel time between nodes
   d_complete(i,j)   Complete full symmetric matrix
   ;
    

scalar
    g       Average speed in kph      /50/,
    M       Large number             /10000/
;


$gdxIn Data1.gdx
$load d a b s
$gdxIn


* Completing the half matrix

d_complete(i,j) = d(i,j);
d_complete(j,i)$(not d_complete(j,i)) = d(i,j);

* Display the complete matrix and time windows
display d_complete, a, b, s;


* Calculating travel times between two nodes in minutes
t(i,j) = d_complete(i,j) * 60 / g;


*Enter the variables here.

binary variable x(i,j) is 1 if the arc from node i to node j is part of the tour (0 otherwise);
Positive Variable u(i) position of a node 1 in a tour
                  z(i) arrival time at node i
                  ;

Variable F;

equations

OF              Distance minimization (objective function)
nb1(j)          every node has only one predecessor node
nb2(j)          every node has only one successor node
nb3(i,j)        Subtour elimination constraint
tw1(i)          arrival time is within the time window
tw2(i)          arrival time is within the time window
Time(i,j)       arrival time calculation
;


*Enter OF, nb1(j) and nb2(j) here.

OF..      F =E= sum((i,j), d_complete(i,j) * x(i,j) );


nb1(j)..  sum(i, x(i,j)) =E= 1;


nb2(j)..  sum(i, x(j,i)) =E= 1;


nb3(i,j)$(ord(i)>1 and ord(j)>1 and ord(i)<> ord(j)).. u(i) - u(j) + (card(V)-1)*x(i,j) =L= card(V)-2 ;


Time(i,j)$(ord(i)>1 and ord(j)>1 and ord(i) <> ord(j) )..    z(i) + s(i) + t(i,j) - M * (1 - x(i,j)) =L= z(j);


tw1(i)..       a(i) =L= z(i);


tw2(i)..       z(i) =L= b(i);


*solve

model TSP /all/ ;
solve TSP minimizing F using MIP ;


* Display the results

display F.L, x.L, u.L, z.L ;


*Output all variable values.

********************************************************
*****   TEXT FILE       ********************************
********************************************************

file out /TSP_Model_Output.txt/;
put out;


* Total distance

put "Total distance: ":30, F.l:8:2 /;
put /;



* Binary Variable x is 1 if the arc from node i to node j is part of the tour (0 otherwise)

put "Order in which the customers have to be delivered" /;
put /;


*Header
******************************
put " ":8;
loop(j,
    put j.tl:11;  
);
put /;

* Rows for all nodes
loop(i,
    put i.tl:4; 
    loop(j,
        if(x.l(i,j) > 0,
            put x.l(i,j):8:3; 
        else
            put " ":11;  
        );
    );
    put /;  
);

put /;


*  The position of a node i in a tour


put "Position of each node in the tour" /;
put /;

put "Node":8, "Position":15 /;  
loop(i$(u.l(i) > 0),
    put i.tl:8, u.l(i):<15:2 /;  
);


* Arrival time

put / "Arrival time at nodes:" /;
put /;
put "Node":8, "Arrival time":15 /;

loop(i$(z.l(i) > 0),
    put i.tl:8, z.l(i):<15:2 /;
);
putclose;

$exit


