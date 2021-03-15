

%% lets get this MCMC stuff rolling
% first we'll try uniform prior with gaussian posterior:

N = 100000; % number of samples
d = 3;  % dimensions; d-variate distribution
% define prior
% an Nxd matrix where each row 1<i<N is a sample of the d-variate dist.
prior = @(N,d) unifrnd(-10, 10, N, d);   
% assemble posterior
% an Nx1 vector that assigns probabilities to each set of d variables
As = [0 1 2]; 
Rs = [2 3 4];
pdf = @(x) mvnpdf(x,As,Rs);

% sample the posterior 
[x,p_x] = rwm(prior,pdf,N,d);

figure(); hold on;
for i=1:d
scatter(x(:,i),p_x,45,'filled');
xline(As(i),'LineWidth',3);
end

%% extension to images

N = 1000;
rows = 30; % size of image, for now a square 
d = rows^2; % dimensions, ie number of pixels
R = 5; % size of object, ie std of Gaussian
A = 1000;  % amplitude, ie scaling factor of Gaussian
W = 25;  % resolution of Gaussian
[D,S] = generate_data(R,A,[rows rows],W,.1);

R_samples = unifrnd(R-2,R+2,[N,1]);
A_samples = unifrnd(A-50,A+50,[N,1]);

% generate prior
prior = zeros([N,d]);
for i=1:N
    prior(i,:) = place_gaussian(zeros([rows,rows]),...
        W, R_samples(i), A_samples(i), 1, 'flat');
end

% assemble posterior
pdf = @(s) mvnpdf(D,s,inv(eye(rows^2)));

[x,p_x] = rwm(prior,pdf,N,d);
