domain = -10:0.02:10-0.01;

prior = @(N,d) unifrnd(-10,10,N,1);
pdf = @(x) normpdf(x,2,3);

figure(); hold on;
% scatter(domain,prior(1000,1),50,'filled','k');
plot(domain,pdf(domain),'Color','red'); 
% legend({'prior','pdf'});

%%
[x,p_x] = rwm(prior,pdf,1000,1);

%% okay that first toy model is working so try more dims
d = 3;
N = 1000;
prior = @(N,d) unifrnd(-10,10,N,d);
As = [0 1 2];
Rs = [2 3 4];
pdf = @(x) mvnpdf(x,As,Rs);

[x,p_x] = rwm(prior,pdf,N,d);

figure(); hold on;
for i=1:d
plot(x(:,i),p_x);
end
%% now try our likelihood
N = 500;
R = 5;
A = 1000;

Rs = unifrnd(2,10,N,1);
As = unifrnd(A-100,A+100,N,1);
rows = 30;
W = 25;
[D,S] = generate_data(R,A,[rows rows],W);
d = numel(D);
D = abs(D(:))';
%%
Ninv = inv(eye(rows^2));
logL = @(D,s,Ninv) -(-1/2 * (D - s)' * Ninv * (D-s) - length(s)/2 * log(2*pi));
%%
pdf = @(s) -(-1/2 * (D' - s')' .* Ninv .* (D'-s') - length(s)/2 .* log(2*pi));
% pdf = @(s) mvnpdf(D,place_gaussian(zeros(rows),W,Rs,As,1,'mc',1),Ninv);
% prior = @(A,R) A*place_gaussian(zeros(dims),W,R,1,'flat');%@(N,d) unifrnd(0,10,N,d)';% .* unifrnd(9000,11000,N,d)';
% prior = @(N,d) place_gaussian(zeros(rows),W,Rs,As,1,'mc',N)';
prior = @(N,d) place_gaussian(zeros(rows),W,Rs,As,1,'mc',N)';%[ones([N,1]).*unifrnd(2,10,N,1),ones([N,1]).*unifrnd(999,1001,N,1)];
    
%%
tic;

[x,p_x] = rwm(prior,pdf,N,d);
toc
figure(); 
