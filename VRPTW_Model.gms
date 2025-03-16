$call GDXXRW.EXE Data2.xlsx output=Data2.gdx par=s rng=Time!a9:ao10 cdim=1 rdim=0 par=a rng=Time!a1:ao2 cdim=1 rdim=0 par=b rng=Time!a5:ao6 cdim=1 rdim=0 par=d rng=Distance!a1:av42 dim=2


sets
   n set of nodes /0, 1*20/ 
   k set of vehicles /1*3/
;   

alias(n,i,j);


parameter
   d(i,j)         Half-distance matrix   
   a(i)           Start time window at node i
   b(i)           End time window at node i
   s(i)           Service time at node i
   t(i,j)         Travel time between nodes
   d_complete(i,j)   Complete full symmetric matrix
;

$gdxIn Data2.gdx
$load d a b s
$gdxIn

* Completing the half matrix

d_complete(i,j) = d(i,j);
d_complete(j,i)$(not d_complete(j,i)) = d(i,j);

* Display the complete matrix and time windows

Display d_complete, a, b, s;


t(i,j) = d_complete(i,j);
display t;

scalar

CAP     Vehicle capacity        /8/
M       Large number            /10000/;   


*Enter variables here.

binary variable

    x(i,j,k) is 1 if vehicle k drives directly from node i to node j (0 otherwise)
    y(i,k) is 1 if node i is served by vehicle k (0 otherwise)
;
    
Positive variable

   u(i,k)   Position of node i in a tour for vehicle k
   z(i)     Arrival time at node i
;

Variable F Total distance (objective function value);

equation

Of              Minimization of total distance (objective function)
Cover(i)        Every customer is assigned to one vehicle
Capa(k)         The maximum vehicle capacity is met
   
Flow(i,k)       Flow preservation constraint   
Couple(i,k)     Coupling constraint for the variables x and y
   
Subtour(i,j,k)  to avoid subtours
   
tw1(i)          Arrival time is within the time window
tw2(i)          Arrival time is within the time window
Time(i,j,k)     Arrival time calculation
;


*Enter definitions of equations here.

Of..    F =E= sum((i,j,k), d_complete(i,j) * x(i,j,k));  

                                       
Cover(i)$(ord(i) > 1)..                 sum(k, y(i,k)) =E= 1;


Capa(k)..                               sum(i, y(i,k)) =l= CAP;


Flow(i,k)..                             sum(j, x(i,j,k)) =E= sum(j, x(j,i,k) );


Couple(i,k)..                           sum(j, x(j,i,k)) =E= y(i,k);


Subtour(i,j,k)$(ord(i) > 1 and ord(j) > 1)..        u(i,k) - u(j,k) +  card(i) * x(i,j,k) =l= card(i) - 1;

tw1 (i)..                              a(i)=L=Z(i);

tw2(i)..                               z(i)=L=b(i);

Time(i,j,k)$(ord(i)>1 and ord(j)>1 and ord(i) <> ord(j) )..     z(i) + s(i) + t(i,j) - M * (1-x(i,j,k)) =L= z(j) ;
                    
*(absolute value of i) = card(i)

model CVRP /all/ ;


*in our model run, there is no absolute or relative gap
*i.e that there is no (absolute/relative) deviation between the best solution and the optimal solution
*normally, in GAMS the relative gap is 10 % (pre-setting)
*i.e. in long model runs (e.g. PE 02), the model run stops when GAMS finds the first solution whose relative gap is 
*our goal: to find the best possible solution witha a relative gap = 0%

*workaround

option optcr = 0.0 ;

*a vehicle is not allowed to drive from node i to node j, if i and j are identical nodes

x.fx(i,j,k)$(ord(i)=ord(j)) = 0;

*Solve instruction

solve CVRP minimizing F using MIP ;


* Display the results 
display x.l, u.l, y.l, z.l,  F.l;


*Output all variable values.
********************************************************
*****   TEXT FILE       ********************************
********************************************************

file out /VRPTW_Model_Output.txt/;
put out;

* Total distance


put "Total distance: ":30, F.l:8:2 /;
put /;




* Binary Variable x is 1 if vehicle k drives directly from node i to node j (0 otherwise)


put "Assignment of customers to vehicles" /;
put /;


*Header
******************************
put " ":11;
loop(k,
    if(sum((i,j), x.l(i,j,k)) > 0,
            put k.tl:11;
        else
            put " ":11;
    );
);
put /;

loop(i,
    loop(j,
        if(sum(k, x.l(i,j,k)) > 0,
            put i.tl:2, '.', j.tl:2;
            loop(k,
                if(x.l(i,j,k) > 0,
                    put x.l(i,j,k):8:3;  
                else
                    put " ":11;          
                );
            );
            put /;
        );
    );
);
put /;


*Position of a node


put "Position of a node 1 in a tour" /;
put /;

*Header
******************************
put " ":8;
loop(k,
    if(sum(i, u.l(i,k)) > 0,
            put k.tl:11;
        else
            put " ":11;
    );
);
put /;

loop(i,
    if(sum(k, u.l(i,k)) > 0,
        put i.tl:3;
        loop(k,
            if(u.l(i,k) > 0,
                put u.l(i,k):8:3;  
            else
                put " ":11;          
            );
        );
        put /;
    );
);

put /;



*Binary variable y is 1 if node i is served by vehicle k (0 otherwise)


put "Assignment of nodes and vehicles" /;
put /;

*Header
******************************
put " ":8;
loop(k,
    if(sum(i, y.l(i,k)) > 0,
            put k.tl:8;
        else
            put " ":8;
    );
);
put /;

loop(i,     
       put i.tl:3;
       loop(k,
            if(y.l(i,k) > 0,
                put y.l(i,k):8:3;  
            else
                put " ":11;          
            );
        );
        put /;
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

