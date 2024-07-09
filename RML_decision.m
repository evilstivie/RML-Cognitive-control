%main call to RML functions for decision-making

function [b,res]=RML_decision(s,arg,AccAct,AccBoost)

b=action(AccBoost,s,[1:arg.nactions_boost],1);%boost selection


if arg.constAct.classic==0%if instrumental
    res=action(AccAct,s,[1:arg.nactions],b);%action selection
else%if pavlovian
    res=1;
end

end