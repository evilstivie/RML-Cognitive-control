%write down RML and environmental parameters data structure

function arg=param_build_stroop_naive

arg.nsubj=40;
arg.initstate=3;%1=3rd order, 2=2nd order, 3=1st order.
arg.nexcltri=20;%trials to esclude for data analysis
arg.nactions=3;%numb of possible actions by dACC_Action
arg.nactions_boost=10;%numb of possible actions by dACC_Boost

%select monoamine levels
arg.constAct.DAlesion=1;%default=1 (no lesion)
arg.constAct.NElesion=1;%default=1 (no lesion)
arg.constAct.HTlesion=.15;%default=.15 (no lesion)

arg.volnum=[1,3];%min and max trials before a change point in volatility task (SE=3)

%reward mean magnitude and variance by SE
arg.RWM=[0 0 0 0 0 0
         0 0 0 0 0 0
         4 4 4 4 4 4];
     
arg.var=[0 0 0 0 0 0
         0 0 0 0 0 0
         0 0 0 0 0 0];
     
%state-action transitions (4=end of trial)     
arg.trans=[0 0
           0 0
           4 4];
       
%reward prob by SE
arg.RWP=[.0 .0 0 0 0 0 %reward rates at dfferent cond order
	     .0 .0 0 0 0 0
         .97 .97 .97 .97 .97 0];
 
 %number of statistical environments administered
arg.SEN=[4 4 4];%SE*REPS;each SE is 90 trials (e.g. [1 1 1] = 270 trials)
arg.ntrial=90*length(arg.SEN(arg.SEN>0));
arg.chance=0.25;%specify what is the a priori chance level to execute the task optimally (it can refer either to the entire trial or to single steps)
arg.chance2=0;%specify what is the a priori chance level to execute the task optimally 
%(if prob is referred to completing the task, then 0, otherwise it refers to the prob of answering correclty to each state within a trial)

arg.constAct.temp=0.6;%temperature
arg.constAct.k=0.3;%initial kalman gain;
arg.constAct.mu=0.1;
arg.constAct.omega=0;
arg.constAct.alpha=0.3;
arg.constAct.eta=0.15;
arg.constAct.beta=1;
arg.constAct.gamma=0.1;
arg.constAct.classic=0;%if 0=instrumental task, if 1= pavlovian

%prior costs matrix for motor actions
arg.constAct.costs=[5 .5 3
                    5 .5 3
                    5 .5 3];
                
arg.constAct.nstate=3;
arg.constBoost=arg.constAct;
arg.constBoost.costs=zeros(arg.constAct.nstate,arg.nactions_boost);
arg.constBoost.temp=0.3;
arg.constBoost.omega=arg.constAct.HTlesion;%BOOST COST!

%init value weights
arg.W3=zeros(arg.constAct.nstate,arg.nactions);
arg.We3=repmat(1-arg.constBoost.omega*[1:arg.nactions_boost],max(arg.trans(:))-1,1);



% save W3 W3
% save We3 We3
% 
% save arg arg