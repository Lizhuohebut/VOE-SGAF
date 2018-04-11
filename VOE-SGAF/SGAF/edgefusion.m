function Sint=edgefusion(magnitude,G)     
        MC=magnitude.*G;
        MCN=sum(MC(:));
        magvalue=sum(magnitude(:));
        MCT=MCN/magvalue;
        Gvalue=sum(G(:));
        MCS=MCN/Gvalue;       
        Sint=(MCT*magnitude+MCS*G)/(MCT+MCS);
end