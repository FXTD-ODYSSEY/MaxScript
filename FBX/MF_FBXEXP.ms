
MF_FBXEXP_FILE = (GetDir #temp) + "/MF_FBXEXP.txt"
content = ""
if (doesFileExist MF_FBXEXP_FILE) then(
    temp_stream = openFile MF_FBXEXP_FILE mode:"r"
    content = readLine temp_stream
    close temp_stream
)

-- 防止窗口多开
try(DestroyDialog FBX_Export)catch()
rollout FBX_Export "MoreFun - FBX Export Tool" width:293 height:104
(
	button 'Options_BTN' "FBX Output Options" pos:[18,16] width:257 height:21 align:#left
	edittext 'Path_LE' "Output_Path" text:content pos:[18,42] width:203 height:21 align:#left
	button 'Select_BTN' "select" pos:[226,41] width:47 height:21 align:#left
	button 'Export_BTN' "FBX export" pos:[18,67] width:253 height:21 align:#left
    
	on Options_BTN pressed do
	(
		OpenFbxSetting()
	)
	on Select_BTN pressed do
	(
		path = getSavePath caption:"get Output Folder"
	    Path_LE.text = path
	    temp_stream = openFile MF_FBXEXP_FILE mode:"w+"
        format "%" path to:temp_stream
	    close temp_stream
	)
	on Export_BTN pressed do
	(   
	    path = Path_LE.text
	    flag = doesFileExist path
	    if flag != true then(
	        messageBox "current directory not exist,please select a new directory"
	        return true
	    )
	
	
	    if selection.count != 0 then(
	        sel_list = selection as array
	        deselect sel_list
	        for obj in sel_list do(
	            select obj
	            path_name = path + "/" + obj.name + ".fbx"
	            exportFile path_name #noPrompt selectedOnly:True using:FBXEXP
	        )
	    ) else (
	        file_name = getFilenameFile maxfilename
	        if file_name == '' then (
	            messageBox "current scene need to save as file"
	            return true
	        )
	        path_name = path + "/" + file_name + ".fbx"
	        exportFile path_name #noPrompt selectedOnly:False using:FBXEXP
	    )
	)
)
createDialog FBX_Export