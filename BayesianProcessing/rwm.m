function [x,p_x] = rwm(prior,pdf,T,d)
% Random walk metro alg

q = @(C,d) mvnrnd(zeros(1,d),C);
C = (2.38/sqrt(d))^2 * eye(d);
x = NaN(T,d); p_x = NaN(T,1);
x(1,1:d) = prior(1,d);
p_x(1) = pdf(x(1,1:d));
% p_x(1) = pdf(x(1,1:d)');

for t=2:T
    xp = x(t-1, 1:d) + q(C,d);
    p_xp = pdf(xp);
    p_acc = min(1,p_xp/p_x(t-1));
    if p_acc > rand
        x(t,1:d) = xp; p_x(t) = p_xp;
    else
        x(t,1:d) = x(t-1,1:d); p_x(t) = p_x(t-1);
    end
        
end
end