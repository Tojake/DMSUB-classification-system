
function [] = reduceDimensionsMeans(dirSrc, extFilesSrc, dirDest, extFilesDest)
% Takes features from multiple text files and computes PCA for the means of
% all genres. After that, for each source text file, the corresponding
% scores (dimensions) are printed to an output text file.
%
% dirSrc:       absolute or relative path to directory of source text files
% extFilesSrc:  file extension of source text files (e.g. 'txt')
% dirDest:      absolute or relative path to directory of ouput text files
% extFilesDest: file extension of output text files (e.g. 'txt')

if ~isempty(dirSrc)
    if ~strcmp(dirSrc(end), '/') && ~strcmp(dirSrc(end), '\')
        dirSrc = strcat(dirSrc, '/');
    end
end
if ~isempty(dirDest)
    if ~strcmp(dirDest(end), '/') && ~strcmp(dirDest(end), '\')
        dirDest = strcat(dirDest, '/');
    end
end

% constants
precisionOutput = 6; % output precision
maxNumDims = 35;
numGenres = 5;

features = [];
lengthExtFilesSrc = length(extFilesSrc);

% read files
contentDir = dir(strcat(dirSrc, '*.', extFilesSrc));
filesSrc = {contentDir.name}';
numFiles = length(filesSrc);
numFilesGenre = numFiles / numGenres;

for f = 1:numFiles
    pathFileSrc = strcat(dirSrc, cell2mat(filesSrc(f)));
    fileId = fopen(pathFileSrc);
    featureRead = fscanf(fileId, '%f');
    fclose(fileId);
    features = [features; featureRead'];
end
features = zscore(features);

meansGenres = zeros(numGenres, size(features, 2));
for g = 1:numGenres
    idxLast = g * numFilesGenre;
    idxFirst = idxLast - numFilesGenre + 1;
    meansGenres(g, :) = mean(features(idxFirst:idxLast));
end

% PCA
coefs = pca(meansGenres, 'Rows', 'all');
featuresReduced = features * coefs;

% create output directory if not already existing
if ~exist(dirDest, 'file') && ~isempty(dirDest)
    mkdir(dirDest);
end

% write files
bar = waitbar(0, sprintf('0 / %u processed', numFiles));
for f = 1:numFiles
    fileSrc = cell2mat(filesSrc(f));
    pathFileDest = strcat(dirDest, fileSrc(1:end-lengthExtFilesSrc), extFilesDest);
    fileId = fopen(pathFileDest, 'w+');
    format = strcat('%.', int2str(precisionOutput), 'f\r\n');
    fprintf(fileId, format, featuresReduced(f, :));
    fclose(fileId);
    
    waitbar(f / numFiles, bar, sprintf('%u / %u processed', f, numFiles));
end
close(bar);

end
