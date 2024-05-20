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
% L?y các giá tr? riêng
singularValues_R = diag(Sr);
singularValues_G = diag(Sg);
singularValues_B = diag(Sb);

% Tính t?ng bình ph??ng c?a các giá tr? riêng
totalEnergy_R = sum(singularValues_R.^2);
totalEnergy_G = sum(singularValues_G.^2);
totalEnergy_B = sum(singularValues_B.^2);

% Tính ph?n tr?m n?ng l??ng tích l?y cho m?i giá tr? riêng
cumulative_energy_R = cumsum(singularValues_R.^2) / totalEnergy_R * 100;
cumulative_energy_G = cumsum(singularValues_G.^2) / totalEnergy_G * 100;
cumulative_energy_B = cumsum(singularValues_B.^2) / totalEnergy_B * 100;

% V? ?? th?
%subplot(1, 2, 2);
plot(cumulative_energy_R, 'r', 'LineWidth', 2);
hold on;
plot(cumulative_energy_G, 'g', 'LineWidth', 2);
plot(cumulative_energy_B, 'b', 'LineWidth', 2);
xlabel('Ch? s? giá tr? riêng');
ylabel('Ph?n tr?m thông tin tích l?y (%)');
title('Phân b? thông tin c?a các giá tr? riêng');
legend('Kênh ??', 'Kênh Xanh Lá', 'Kênh Xanh D??ng');
grid on;


%% Tính toán l?i tái t?o cho m?i giá tr? r

num_singular_values = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]; % L?y m?u các giá tr? r
compression_ratios = zeros(1, length(num_singular_values));
compressed_sizes = zeros(1, length(num_singular_values)); % Thêm m?ng l?u kích th??c nén

original_size = numel(A) * 8; % Kích th??c ?nh g?c (bit)

for i = 1:length(num_singular_values)
    r = num_singular_values(i);
    compressed_size_R = (numel(Ur(:, 1:r)) + numel(Sr(1:r, 1:r)) + numel(Vr(:, 1:r))) * 8; % Kích th??c ?nh nén kênh R (bit)
    compressed_size_G = (numel(Ug(:, 1:r)) + numel(Sg(1:r, 1:r)) + numel(Vg(:, 1:r))) * 8; % Kích th??c ?nh nén kênh G (bit)
    compressed_size_B = (numel(Ub(:, 1:r)) + numel(Sb(1:r, 1:r)) + numel(Vb(:, 1:r))) * 8; % Kích th??c ?nh nén kênh B (bit)
    compressed_size = compressed_size_R + compressed_size_G + compressed_size_B; % T?ng kích th??c ?nh nén cho c? 3 kênh
    compression_ratios(i) = (original_size - compressed_size) / original_size * 100; % T? l? ph?n tr?m nén
    compressed_sizes(i) = compressed_size; % L?u kích th??c nén
end

figure;
subplot(1, 2, 1);
plot(num_singular_values, compression_ratios, '-o');
xlabel('S? l??ng singular values ???c gi? l?i (r)');
ylabel('Ph?n tr?m nén ?nh(%)');
title('Phân tích nén ?nh b?ng SVD');


subplot(1, 2, 2);
plot(num_singular_values, compressed_sizes / (1024^2), '-o'); % Kích th??c nén (MB)
xlabel('S? l??ng singular value ???cc gi? l?i (r)');
ylabel('Kích th??c nén (MB)');
original_size_MB = original_size / (1024^2 * 8); % ??i kích th??c ?nh g?c sang MB
title('Kích th??c nén ?nh v?i các giá tr? r khác nhau');
