%% Read image to A
close all
clc

file_path = 'C:\Users\lechi\OneDrive - y1zrr\Documents\MATLAB\LinearAlgebra-BTL\cat.jpg';
A = im2double((imread(file_path)));

%% Split 3 color Channels 
R = A(:, :, 1);
G = A(:, :, 2);
B = A(:, :, 3);

%% Performing SVD on 3 channels
[Ur, Sr, Vr] = svd(R,'econ');
[Ug, Sg, Vg] = svd(G,'econ');
[Ub, Sb, Vb] = svd(B,'econ');

%% Truncate some value to compress image
Re_images = [];
r = [5 20 100];
for i = 1:length(r) %truncation value in this array
    Re_R = Ur(:,1:r(i))*Sr(1:r(i),1:r(i))*Vr(:,1:r(i))';
    Re_G = Ug(:,1:r(i))*Sg(1:r(i),1:r(i))*Vg(:,1:r(i))';
    Re_B = Ub(:,1:r(i))*Sb(1:r(i),1:r(i))*Vb(:,1:r(i))';
    image = cat(3,Re_R, Re_G, Re_B);
    Re_images = cat(4, Re_images, image); % add the image to the Re_images array
end
%% Plot new reconstructed image
figure('Position',[50 50 800 800])
subplot(2,2,1)
imshow(A); title ('Original Image') 

for i = 1:size(Re_images, 4)
    subplot(2,2,i+1)
    imshow(Re_images(:,:,:,i)); 
    title (['Truncated Image, r = ', num2str(r(i))]); 
end