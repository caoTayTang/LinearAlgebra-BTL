clear all
close all
clc

file_path = input('Please input file directory (enter for default): ','s');
if strcmp(file_path, '')
   file_path = 'C:\Users\lechi\OneDrive - y1zrr\Documents\MATLAB\bachkhoa.jpg';
end

A = double(rgb2gray((imread(file_path))));
[nx,ny] = size(A);

figure('Name','Image compression','NumberTitle','off','Position', [50, 50, nx*2, ny]); % Adjust the position and size as needed
subplot(1,3,1)

imshow(uint8(A),'InitialMagnification','fit'), axis off
title('Original');
%% SVD Approximations
[U,S,V] = svd(A,'econ');


% tuy chinh singular values de in ra
while true
user_r = input('Enter how many singular values: (enter 0 to stop) ');
if user_r == 0
    break; % exit the loop if user enters 0
end
if user_r > rank(S)
    user_r = rank(S);
end
ReducedImage = U(:,1:user_r)*S(1:user_r,1:user_r)*V(:,1:user_r)';
subplot(1,3,2);
imshow(uint8(ReducedImage)), axis off
title(['r = ', num2str(user_r,'%d'),', ',num2str(100*user_r*(nx+ny)/(nx*ny),'%2.1f'),'%']);
end


%% Chay animation r = 0 cho toi max
pause on % to enable pause function
r = 0; 
while (r < rank(S))
    ReducedImage = U(:,1:r)*S(1:r,1:r)*V(:,1:r)';
    subplot(1,3,3); 
    imshow(uint8(ReducedImage)), axis off
    title(['r = ', num2str(r,'%d'),', ',num2str(100*r*(nx+ny)/(nx*ny),'%2.1f'),'%']);
    r = r + 50;
    pause(0.01);
end


%% Singular values graph
figure('Name','Singular values','NumberTitle','off'); % Adjust the position and size as needed
semilogy(diag(S),'k','LineWidth',2), grid on
xlabel('r')
ylabel('Singular value \sigma_r')
xlim([-50 rank(S)])






