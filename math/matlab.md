# 取整
```
1 = floor(1.9)
2 = ceil(1.1);
1 = round(1.1)
2 = round(1.9)
```
# load
```
data = load('./k2-p4-15.TXT');%data = load('./officalLen.txt');
fovXY= data(:, 3 : 4);
fovR = data(:, 5);
screenPredictedxy= data(:, 6 : 7);
```
# data type convertion
```
blockImg = uint8(ones(32, 32));
```
# 矩阵乘法
```
tanAngleM = [ 
 0.5 / tanHalfFov, 	0.0, 				-0.5, 0.0 ;
 0.0, 				0.5 / tanHalfFov, 	-0.5, 0.0 ;
 0.0, 				0.0, 				-1.0, 0.0 ;
 0.0, 				0.0, 				-1.0, 0.0 ;];
 
 for i = 1:n
 	texCoord(i,:) = tanAngleM * [tanAngleReal(i,1), tanAngleReal(i,2), -1, 1]';
 end
```
# plot
```
hold on
plot(tanAngle(:,1), tanAngle(:,2), '.R', tanAngleReal(:,1), tanAngleReal(:,2), '.G');
```

# 生成棋盘格子
```
imageWidth = 2560;
imageHeight = 1536;%为了跟128对齐，将1440改为1536
chessBoxWidth = 128;
chessBoxHeight = 128;
w = ones(chessBoxWidth, chessBoxHeight);
b = zeros(chessBoxWidth, chessBoxHeight);
pattern = [w, b; b, w];
ps=size(pattern);
outImg = zeros(imageHeight, imageWidth);
for y=1:ps(1):imageHeight
    for x = 1:ps(2):imageWidth
        outImg(y:y+ps(1)-1, x:x+ps(2)-1) = pattern;
    end
end

imwrite(outImg, 'chessPattern.png');
```