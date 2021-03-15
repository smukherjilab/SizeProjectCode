
f = @(x) normpdf(x);

N = 2000;
x = slicesample(1,N,'pdf',f,'thin',5,'burnin',1000);

%%
N = 1000;
rows = 30; % size of image, for now a square 
d = rows^2; % dimensions, ie number of pixels
R = 5; % size of object, ie std of Gaussian
A = 1000;  % amplitude, ie scaling factor of Gaussian
W = 25;  % resolution of Gaussian
[D,S] = generate_data(R,A,[rows rows],W,.1);
D = abs(D);
Ninv = inv(eye(rows^2));
% logL = @(s) -(-1/2 * (D - s)' * Ninv * (D-s) - length(s)/2 * log(2*pi));
f = @(D,x,Ninv) mvnpdf(D,x,Ninv);
x = slicesample(S',N,'pdf',f,'thin',5,'burnin',1000);
