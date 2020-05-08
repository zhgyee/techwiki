# APK目录结构

File/Directory |	Description
--------|------------------------
*.exe	| Executable file of the game
*_Data	| Data folder containing the game resources
level0-levelN	| Files containing game scenes data, each scene has its own file
sharedassets0-sharedassetsN	| Game assets are split into sharedassets and .resS files
resources.assets	| Assets found in the project resources folders and their dependencies are stored in this file
Managed	Folder | containing unity DLLs
Assembly-CSharp.dll	| DLL file containing compiled C# files
Assembly-UnityScript.dll	| DLL file containing compiled UnityScript files

# APK中提取模型和贴图

如果你想解Unity5的游戏包，请使用 UnityAssetsExplorer 1.5 以上版本。

1. 使用AssetStudio打开level，然后分别导出object和asset
2. 其中FBX是模型，贴图都在texture2d目录下
3. 使用3dmax可以还原模型和贴图