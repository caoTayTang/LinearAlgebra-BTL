%% Read image to A
close all
clc

file_path = '.\cat.jpg';
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


%% ?? t?p trung data
% L?y c�c gi� tr? ri�ng
singularValues_R = diag(Sr);
singularValues_G = diag(Sg);
singularValues_B = diag(Sb);

% T�nh t?ng b�nh ph??ng c?a c�c gi� tr? ri�ng
totalEnergy_R = sum(singularValues_R.^2);
totalEnergy_G = sum(singularValues_G.^2);
totalEnergy_B = sum(singularValues_B.^2);

% T�nh ph?n tr?m n?ng l??ng t�ch l?y cho m?i gi� tr? ri�ng
cumulative_energy_R = cumsum(singularValues_R.^2) / totalEnergy_R * 100;
cumulative_energy_G = cumsum(singularValues_G.^2) / totalEnergy_G * 100;
cumulative_energy_B = cumsum(singularValues_B.^2) / totalEnergy_B * 100;

% V? ?? th?
%subplot(1, 2, 2);
plot(cumulative_energy_R, 'r', 'LineWidth', 2);
hold on;
plot(cumulative_energy_G, 'g', 'LineWidth', 2);
plot(cumulative_energy_B, 'b', 'LineWidth', 2);
xlabel('Ch? s? gi� tr? ri�ng');
ylabel('Ph?n tr?m th�ng tin t�ch l?y (%)');
title('Ph�n b? th�ng tin c?a c�c gi� tr? ri�ng');
legend('K�nh ??', 'K�nh Xanh L�', 'K�nh Xanh D??ng');
grid on;


%% T�nh to�n l?i t�i t?o cho m?i gi� tr? r

num_singular_values = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]; % L?y m?u c�c gi� tr? r
compression_ratios = zeros(1, length(num_singular_values));
compressed_sizes = zeros(1, length(num_singular_values)); % Th�m m?ng l?u k�ch th??c n�n

original_size = numel(A) * 8; % K�ch th??c ?nh g?c (bit)

for i = 1:length(num_singular_values)
    r = num_singular_values(i);
    compressed_size_R = (numel(Ur(:, 1:r)) + numel(Sr(1:r, 1:r)) + numel(Vr(:, 1:r))) * 8; % K�ch th??c ?nh n�n k�nh R (bit)
    compressed_size_G = (numel(Ug(:, 1:r)) + numel(Sg(1:r, 1:r)) + numel(Vg(:, 1:r))) * 8; % K�ch th??c ?nh n�n k�nh G (bit)
    compressed_size_B = (numel(Ub(:, 1:r)) + numel(Sb(1:r, 1:r)) + numel(Vb(:, 1:r))) * 8; % K�ch th??c ?nh n�n k�nh B (bit)
    compressed_size = compressed_size_R + compressed_size_G + compressed_size_B; % T?ng k�ch th??c ?nh n�n cho c? 3 k�nh
    compression_ratios(i) = (original_size - compressed_size) / original_size * 100; % T? l? ph?n tr?m n�n
    compressed_sizes(i) = compressed_size; % L?u k�ch th??c n�n
end

figure;
subplot(1, 2, 1);
plot(num_singular_values, compression_ratios, '-o');
xlabel('S? l??ng singular values ???c gi? l?i (r)');
ylabel('Ph?n tr?m n�n ?nh(%)');
title('Ph�n t�ch n�n ?nh b?ng SVD');


subplot(1, 2, 2);
plot(num_singular_values, compressed_sizes / (1024^2), '-o'); % K�ch th??c n�n (MB)
xlabel('S? l??ng singular value ???cc gi? l?i (r)');
ylabel('K�ch th??c n�n (MB)');
original_size_MB = original_size / (1024^2 * 8); % ??i k�ch th??c ?nh g?c sang MB
title('K�ch th??c n�n ?nh v?i c�c gi� tr? r kh�c nhau');
