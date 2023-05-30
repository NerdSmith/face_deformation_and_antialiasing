clear;
datasetDir = './dataset';
outputDir = fullfile(datasetDir, 'modified');

subDirs = dir(datasetDir);
subDirs = subDirs([subDirs.isdir]);
subDirs = subDirs(~ismember({subDirs.name}, {'.', '..'}));

imageFiles = {};
for i = 1:length(subDirs)
    subDirPath = fullfile(datasetDir, subDirs(i).name);
    files = dir(fullfile(subDirPath, '*.pgm'));
    imageFiles = [imageFiles; fullfile(subDirPath, {files.name})];
end

numImages = length(imageFiles);

% firstImage = imread(imageFiles{1});

mkdir(outputDir);

filteredImages = cell(numImages, 1);
deformedImages = cell(numImages, 1);
for i = 1:numImages
    image = imread(imageFiles{i});

    A = 10; % Амплитуда
    omega_x = 0.01; % Частота по оси x
    omega_y = 0.001; % Частота по оси y
    psi = 0; % Фазовый сдвиг
    [x, y] = meshgrid(1:size(image, 2), 1:size(image, 1));
    deformed_x = x + A * sin(omega_x * x + omega_y * y + psi);
    deformed_y = y + A * sin(omega_x * x + omega_y * y + psi);
    
    deformed_x = max(1, min(size(image, 2), deformed_x));
    deformed_y = max(1, min(size(image, 1), deformed_y));
    
    deformedImages{i} = interp2(double(image), deformed_x, deformed_y);
    deformedImages{i} = uint8(deformedImages{i});
    
    filteredImage = imgaussfilt(deformedImages{i});
%     filteredImage = imguidedfilter(deformedImages{i});
    filteredImages{i} = filteredImage;

%     [parentFolder, ~, ~] = fileparts(imageFiles{i});
%     [~, folderName, ~] = fileparts(parentFolder);
% 
%     outputFileName = fullfile(outputDir, [folderName, '.pgm']);
%     imwrite(filteredImage, outputFileName);
end


qualityScores = zeros(numImages, 1);
for i = 1:numImages
    refImage = deformedImages{i};
    score = psnr(filteredImages{i}, refImage);
    qualityScores(i) = score;
end

figure;
subplot(1, 4, 1);
imshow(imread(imageFiles{17}));
title('Исходное изображение');

subplot(1, 4, 2);
imshow(deformedImages{17});
title('Деформированное изображение');

subplot(1, 4, 3);
imshow(filteredImages{17});
title('Улучшенное изображение');

subplot(1, 4, 4);
plot(1:numImages, qualityScores);
xlabel('Изображение');
ylabel('Качество (PSNR/SSIM)');
title('Качество изображений');

