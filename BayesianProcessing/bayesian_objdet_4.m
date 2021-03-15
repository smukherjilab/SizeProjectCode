
% script to tinker 
% Set up some parameters.
backgroundGrayLevel = 0;
numberOfGaussians = 1;

sigma = 6;
W = 75.*ones([numberOfGaussians,1]);
A = 2000;
rows = 150;
columns = 150;
grayImage = backgroundGrayLevel * ones(rows, columns);
noiseS = 1;
for k = 1 : numberOfGaussians
    g = fspecial('gaussian',W(k),sigma(k));
    randR = randi(rows-W(k)+1, [1 numberOfGaussians]);
    randC = randi(columns-W(k)+1, [1 numberOfGaussians]);
    
  grayImage(randR(k):randR(k)+W(k)-1, randC(k):randC(k)+W(k)-1) = ...
    grayImage(randR(k):randR(k)+W(k)-1, randC(k):randC(k)+W(k)-1) + ...
    g;
end
grayImage = grayImage*A;
noise = normrnd(0,noiseS,[rows columns]);
noisyImage = grayImage + noise;

figure();
subplot(1,2,1); imshow(grayImage,[]); title('pure signal');
subplot(1,2,2); imshow(noisyImage,[]); title('noisy signal')


%% multiv gaussian likelihood
N = noiseS^2 * eye(rows^2); % covariance matrix Sigma
Ninv = inv(N);
%%
% L = mvnpdf(grayImage+noise,grayImage,N);
% L = mvnpdf(abs(noisyImage(:)),grayImage(:),N);
% figure, h=scatter3(noisyImage(:,1),noisyImage(:,2),L,100,'filled');
logL = @(D,s,Ninv) -(-1/2 * (D - s)' * Ninv * (D-s) - length(s)/2 * log(2*pi));
sparselogL = @(D,s,Ninv) -(-1/2 * (D - s)' * Ninv * (D-s) - length(s)/2 * log(2*pi));
logL(abs(noisyImage(:)),grayImage(:),Ninv);

Arange = [A-10,A+10];
Srange = [sigma-1,sigma+1];
num_samples = 20000;
sa = {};
N = 1^2 * eye(rows^2);
X = zeros([rows,1]);
Y = zeros([rows,1]);
alllogL = zeros([num_samples,1]);
Ls = zeros([rows,1]);
As = zeros([num_samples,1]);
Ss = zeros([num_samples,1]);
for i=1:rows
    X(i) = noisyImage(i,1);
    Y(i) = noisyImage(i,2);
end
maxI = Inf;
ind = 0;
allimgs = [];
count = 0;
tic;
s = lhsu([A-10,sigma-1],[A+10,sigma+1],num_samples);
for i=1:num_samples
    
    % construct this prior
    this_A = s(i,1);
    this_S = s(i,2);
    this_img = this_A*place_gaussian(zeros([rows,columns]),W,this_S,numberOfGaussians);
    % compute likelihood of this img
    L = logL(abs(noisyImage(:)),this_img(:),Ninv);
    alllogL(i) = L;
%     if L < maxI
%     Ls = Ls + L;
    As(i) = this_A;
    Ss(i) = this_S;
%     allimgs(:,:,i) = this_img;
    if L < maxI
        count = count + 1;
        allimgs(:,:,count) = this_img;
        maxI = L;
        ind = i;
    end
%     hold on;
%     scatter3(noisyImage(:,1),noisyImage(:,2),-log(L),100,'filled')
    if mod(i,100) == 0
        disp([num2str(i),'/',num2str(num_samples)]);
    end
end
% figure(); scatter3(X,Y,Ls,100,'filled');
figure();
subplot(1,2,1); imshow(noisyImage,[]); title('noisy signal');
subplot(1,2,2); imshow(allimgs(:,:,end),[]); title('reconstruction')
toc

% yay!!! just accomplished MLE 

%%
space = Inf*ones([Srange(2)*10,Arange(2)*10]);
for i=1:num_samples
%     if alllogL(i,1) > space(Ss(i),As(i))
%         continue
%     else
    space(round(10*Ss(i)),round(10*As(i))) = alllogL(i,1);
%         space(round(Ss(i)),round(As(i))) = alllogL(i,1);
%     end
end
figure(); imagesc(space'); colorbar(); xlabel('object size sigma'); ylabel('object amplitude A')
hold on; scatter(Ss(ind)*10,As(ind)*10,100,'r')

% asymmetry in this plot - i think its cuz the model knows about the noise,
% so it automatically calls those tiny objects less likely than erroneously
% big ones

%% visualizing likelihood
figure(); scatter(Ss,alllogL);
xlabel('sigma'); ylabel('-loglikelihood'); 
title('-loglikelihood of data as function of parameter sigma');
figure(); scatter(As,alllogL);
xlabel('ampitude A'); ylabel('-loglikelihood'); 
title('-loglikelihood of data as function of parameter A');

%% posterior
post_Ss = Ss.*alllogL;
figure(); histogram(post_Ss)
% figure(); histogram(rescale(post_Ss,0,5),'Normalization','pdf');%
% another way maybe:
post_Ss2 = [];
A_tolerance = 10;
A_sub = abs(As - A);  
marginal_S = A_sub < A_tolerance;  % remining nonzero elements are of interest
marginal_S = marginal_S .* post_Ss;
marginal_S = marginal_S(marginal_S>0);
figure, histogram(marginal_S,10)
% for i=1:num_samples
%     if A_
%         continue
%     else 
%         post_Ss2 = [post_Ss2 Ss(i).*alllogL];
%     end
%         
% end