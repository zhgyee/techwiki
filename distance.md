# Introduction #

Add your content here.



##  Levenshtein distance ## 
## # reference ## #
http://blog.csdn.net/fover717/article/details/8142616
> Levenshtein distance最先是由俄国科学家Vladimir Levenshtein在1965年发明，用他的名字命名。不会拼读，可以叫它edit distance（编辑距离）。
> Levenshtein distance可以用来：
  1. Spell checking(拼写检查).
  1. Speech recognition(语句识别)
  1. DNA analysis(DNA分析)
  1. Plagiarism detection(抄袭检测)
LD用m\*n的矩阵存储距离值。算法大概过程：
```
str1或str2的长度为0返回另一个字符串的长度。
初始化(n+1)*(m+1)的矩阵d，并让第一行和列的值从0开始增长。
扫描两字符串（n*m级的），如果：str1[i] == str2[j]，用temp记录它，为0。否则temp记为1。然后在矩阵d[i][j]赋于d[i-1][j]+1 、d[i][j-1]+1、d[i-1][j-1]+temp三者的最小值。
扫描完后，返回矩阵的最后一个值即d[n][m]
最后返回的是它们的距离。怎么根据这个距离求出相似度呢？因为它们的最大距离就是两字符串长度的最大值。对字符串不是很敏感。现我把相似度计算公式定为1-它们的距离/字符串长度最大值。
```
代码实现：
```
public static float similarity(String str1, String str2) {
		
		//计算两个字符串的长度。
		int len1 = str1.length();
		int len2 = str2.length();
		//建立数组，比字符长度大一个空间
		int[][] dif = new int[len1 + 1][len2 + 1];
		//赋初值，步骤B。
		for (int a = 0; a <= len1; a++) {
			dif[a][0] = a;
		}
		for (int a = 0; a <= len2; a++) {
			dif[0][a] = a;
		}
		//计算两个字符是否一样，计算左上的值
		int temp;
		for (int i = 1; i <= len1; i++) {
			for (int j = 1; j <= len2; j++) {
				if (str1.charAt(i - 1) == str2.charAt(j - 1)) {
					temp = 0;
				} else {
					temp = 1;
				}
				//取三个值中最小的
				dif[i][j] = min(dif[i - 1][j - 1] + temp, dif[i][j - 1] + 1,
						dif[i - 1][j] + 1);
			}
		}
		return 1 - (float) dif[len1][len2] / Math.max(str1.length(), str2.length());
	}
	
	//得到最小值
	public static int min(int... is) {
		int min = Integer.MAX_VALUE;
		for (int i : is) {
			if (min > i) {
				min = i;
			}
		}
		return min;
	}
```