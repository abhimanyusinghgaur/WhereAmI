function [] = faceDetect( dim, IMG )
clc;
%% Read Main subject frames from video.
fprintf('Initializing training of Main class.\n');

fprintf('Extracting features...  ');
tic;
n1=305;%set n1 value
dim=60;%set Dimension
temp=0;
for a=1:n1
    s = strcat('C:\Users\om\Desktop\database\positive\a (', int2str(a), ').jpg');
    I = imresize(imread(s),[512 NaN]);
    %I=imread(s);
    faceDetector = vision.CascadeObjectDetector();
    bbox = step(faceDetector, I);
    fprintf('Total %d faces found. Beginning comparison..  \n', size(bbox,1));
    for b=1:size(bbox,1);
        fprintf('Face %d -> ', b);
        X = imcrop(I,bbox(b,:));
        temp=temp+1;
        I1 = imresize(X,[dim dim]);
        J = rgb2gray(I1);
        T(temp,:) = reshape(haar_2d(J),1,dim*dim); %Reduce time this way. But how!??
    end
end

fprintf('\nTotal Faces = %d\n',temp);
toc;
n1=temp;
%% Read Negative Class. Covering all faces.
fprintf('Initializing training on our Negative Class.\n');
fprintf('Extracting features...  ');
tic;
n2=654;
dim=60;
temp=n1;
for a=1:n2;
    s = strcat('C:\Users\om\Desktop\dataset\negative\n (', int2str(a),').jpg');
    %I = imresize(imread(s),[512 NaN]);
    I=imread(s);
    faceDetector = vision.CascadeObjectDetector();
    bbox = step(faceDetector, I);
    fprintf('Total %d faces found. Beginning comparison..  \n', size(bbox,1));
    for b=1:size(bbox,1);
        fprintf('Face %d -> ', b);
        X = imcrop(I,bbox(b,:));
        temp=temp+1;
        I1 = imresize(X,[dim dim]);
        J = rgb2gray(I1);
        k=reshape(haar_2d(J),1,dim*dim);
        T(temp,:) = reshape(haar_2d(J),1,dim*dim); %Reduce time this way. But how!
    end
end
n2=temp-n1;
fprintf('n2 is %d',n2);
toc;
%% Train SVM
fprintf('%d %d \n',n1,n2);
fprintf('Training:   ');
tic;
T = double(T);
Y = zeros(n1+n2,1);
Y(1:n1) = ones(n1,1);
SVMSTRUCT = svmtrain(T,Y);
toc;
fprintf('Training complete.\n\n');
%% Read Test Images

fprintf('Reading test images... \n');
s = strcat('C:\Users\om\Desktop\test\13', '.jpg');%what is use of this IMG? And how to call this IMG and dim
I = imresize(imread(s),[512 NaN]);
faceDetector = vision.CascadeObjectDetector();
bbox = step(faceDetector, I);
Iout = I;
fprintf('Total %d faces found. Beginning comparison..  \n', size(bbox,1));
for a=1:size(bbox,1)
    fprintf('Face %d -> ', a);
    X = imcrop(I,bbox(a,:));
    TI = imresize(X,[dim dim]);
    TJ = rgb2gray(TI);
    TV = reshape(haar_2d(TJ),1,dim*dim);
    TV = double(TV);
    GROUP = svmclassify(SVMSTRUCT,TV);
    fprintf('Match found!  ');
    pos = bbox(a,:);
    pos(2) = pos(2) - 20;
    pos(1) = pos(1) + pos(3)/8;
    if GROUP == 0
        name = 'Other';
    else
        name = 'Abhinav';
    end
    fprintf('Person: %s. \n', name);
    Iout = insertShape(Iout,'rectangle',bbox(a,:),'Color','yellow');
    Iout = insertText(Iout,pos(1:2),name);
end
figure, imshow(Iout);
fprintf('\n\n');

end

