clc
clear
close all

% rgb full scale
inCard = imread('2H.png');
[rows,cols] = size(inCard);
figure;
imshow(inCard)
title('Original image');
imwrite(inCard, 'RGB_fullscale.png');

% rgb scaled down
scale = 0.55;
scaledCard = imresize(inCard, scale);
figure;
imshow(scaledCard)
title('Scaled down image');
imwrite(scaledCard, 'RGB_scaled.png');


% red and grayscale images
redCard = scaledCard(:,:,1);
[rrows, rcols] = size(redCard);
grayCard = rgb2gray(scaledCard);


% preliminary trimming
redCard = redCard(15:round(rrows/3),15:round(rcols/3));
grayCard = grayCard(15:round(rrows/3),15:round(rcols/3));
[rrows, rcols] = size(redCard);
figure;
imshow(redCard);
title('preliminary trimming redCard');
figure;
imshow(grayCard);
title('preliminary trimming grayCard');
imwrite(redCard, 'RED_prel.png');
imwrite(grayCard, 'GRAY_prel.png');

% binary card
[counts, xlabel] = imhist(grayCard);
T = otsuthresh(counts);
binaryCard = imbinarize(grayCard, T);
binaryCard = 1 - binaryCard;
[brows, bcols] = size(binaryCard);
figure;
imshow(binaryCard);
title('binaryCard');
imwrite(binaryCard, 'binaryCard.png');


% trimming - fisrt cycle
jinf = bcols;
jsup = 1;
for j = 1:bcols-1
    if sum(binaryCard(:,j)) == 0 && sum(binaryCard(:,j+1))  ~= 0
        if j+1 < jinf
            jinf = j+1;
        end
    elseif sum(binaryCard(:,j)) ~= 0 && sum(binaryCard(:,j+1))  == 0
        if j > jsup
            jsup = j;
        end
    end
end
if jsup <= jinf
    jsup = bcols;
end


binaryCard = binaryCard(:,jinf:jsup);
trimmedRedCard = redCard(:,jinf:jsup);
[trrows, trcols] = size(trimmedRedCard);
figure;
imshow(binaryCard);
title('trimming first cycle - trimmedbinaryCard');
figure;
imshow(trimmedRedCard)
title('trimming first cycle - trimmedRedCard');
imwrite(trimmedRedCard, 'trimmedRedCard.png');
imwrite(binaryCard, 'trimmedbinaryCard.png');

% color analysis
colore = 0;
exit = 0;
for m = 1:trrows
    for n = 1:trcols
        if trimmedRedCard(m,n) < 100
            colore = 1; % nero
            exit = 1;
            break;
        end
    end
    if exit == 1
        break;
    end
end


% trimming - second cycle
iinf = 1;
isup = 1;
for i = 1:brows-1
    if sum(binaryCard(i,:)) == 0 && sum(binaryCard(i+1,:))  ~= 0
        if i+1 > iinf
            iinf = i+1;
        end
    elseif sum(binaryCard(i,:))  ~= 0 &&  sum(binaryCard(i+1,:))  == 0
        if i > isup
            isup = i;
        end
    end
end
if isup <= iinf
    isup = brows;
end

trimmedCard = binaryCard(iinf:isup,:);
[trows, tcols] = size(trimmedCard);
figure;
imshow(trimmedCard);
title('trimming second cycle - trimmedCard');
imwrite(trimmedCard, 'trimmedCard.png');


% trimming - third cycle
jinf = 1;
jsup = 1;
for j = 1:tcols-1
    if sum(trimmedCard(:,j)) == 0 &&  sum(trimmedCard(:,j+1))  ~= 0
        if j+1 > jinf
            jinf = j+1;
        end
    elseif sum(trimmedCard(:,j))  ~= 0 &&  sum(trimmedCard(:,j+1))  == 0
        if j > jsup
            jsup = j;
        end
    end
end
if jsup <= jinf
    jsup = tcols;
end


% seed shape analysis
seed = trimmedCard(:,jinf:jsup);
[srows, scols] = size(seed);
figure;
imshow(seed);
title('seed');
imwrite(seed, 'seed.png');

mat1 = seed(1:round(srows/2),:);
mat2 = seed(round(srows/2):srows,:);
line1 = seed(round(srows/3),:);
line2 = seed(round(srows/3)-round(srows/7),:);

upHalf =  sum(mat1(:));
bottomHalf = sum(mat2(:));
sline1 = sum(line1(:));
sline2 = sum(line2(:));

tol = 0.2;

% seed 
if colore == 0 % red
    if (1-tol)*bottomHalf < upHalf && upHalf< (1+tol)*bottomHalf
        fprintf('The seed is diamonds\n');
    else
        fprintf('The seed is heart\n');
    end
else % black
    if sline1 > sline2
        fprintf('The seed is spades\n');
    else
        fprintf('The seed is clubs\n');
    end
end
