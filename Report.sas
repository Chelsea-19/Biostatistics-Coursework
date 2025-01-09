/* Import the data */
proc import datafile="/home/u63515878/Database.xlsx" 
    out=health_data
    dbms=xlsx 
    replace;
    getnames=yes;
run;

proc print data=health(obs=10); 
run;

/* Data Processing */
data health;
    set health_data;
    MWDPree = input(MWDPre, best32.);
run;

/* Check for missing values */
proc means data=health nmiss; 
run;

/* Fill the Missing Values */
proc stdize data=health out=health1 reponly method=mean;
   var Sedentarytime MWDPree; 
run;

/* Correlation Analysis */
proc corr data=health1;
    var Sex Age Height Bodyweight BMI Smoking Alcholdrinking Habit;
run;

/* Define the Research Variable*/
data health1;
    set health1;
    MWD_change = MWDPree - MWDPost;
run;

/* Ordinary Linear Regression Model */
proc reg data=health1;
    model MWD_change = Sex Age Height Bodyweight BMI Smoking Alcholdrinking Habit;
    output out=health2 predicted=reg_pred; 
run;


/* Generalized Linear Model */
proc glm data=health1;
    model MWD_change = Sex Age Height Bodyweight BMI Smoking Habit; 
    output out=health3 predicted=glm_pred; 
run;

/* Evaluate Ordinary Linear Regression Model Performance */
proc means data=health2;
    var reg_pred MWD_change;
run;

/* Evaluate Generalized Linear Model Performance */
proc means data=health3;
    var glm_pred MWD_change; 
run;

/* Compare Model Performance */
proc sgplot data=health2;
    scatter x=reg_pred y=MWD_change / markerattrs=(symbol=circlefilled color=blue);
    title 'Ordinary Linear Regression Model Prediction Results'; 
run;

proc sgplot data=health3;
    scatter x=glm_pred y=MWD_change / markerattrs=(symbol=circlefilled color=red);
    title 'Generalized Linear Model Prediction Results'; 
run;