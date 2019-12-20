macroScript OP
category: "OP FBX Export"
tooltip: "MoreFun - FBX Export Tool"
(
    global MF_FBXEXP_FILE = (GetDir #temp) + "/MF_FBXEXP.txt"

fn readFileAsString filePath = (
    if (doesFileExist filePath) then(
        temp_stream = openFile filePath mode:"r"
        seek temp_stream #eof
        maxlen=filepos temp_stream
        seek temp_stream  0
        fileString = readChars temp_stream maxlen errorAtEOF:false
        close temp_stream
        return fileString
    )else(
        return ""
    )
)

fn readFileAsArray filePath = (
    fileString = readFileAsString filePath
    return filterString fileString "\n"
)

fn editFileLine filePath lineNum Data = (
    fileArray = readFileAsArray filePath
    fileString = ""
    for i = 1 to fileArray.count do(
        if i == lineNum then(
            fileString = append fileString Data+"\n"
        )else(
            fileString = append fileString fileArray[i]+"\n"
        )
    )
    temp_stream = openFile filePath mode:"w+"
    format "%" fileString to:temp_stream
    close temp_stream
)

fn readFileLine filePath lineNum = (
    fileArray = readFileAsArray filePath
    if lineNum > 0 and lineNum <= fileArray.count then(
        return fileArray[lineNum]
    )else(
        messageBox "readFileLine Exceed boundary"
    )
)

fn ResetFBXSetting =
(
    -- <Include> <Geometry>
    FbxExporterSetParam "SmoothingGroups"       false					-- default:false
    FbxExporterSetParam "NormalsPerPoly"        false					-- default:false
    FbxExporterSetParam "TangentSpaceExport"    false					-- default:false
    FbxExporterSetParam "SmoothMeshExport"      true					-- default:true
    FbxExporterSetParam "Preserveinstances"     false					-- default:false
    FbxExporterSetParam "SelectionSet"          ""						-- default:""
    FbxExporterSetParam "SelectionSetExport"    false					-- default:false
    FbxExporterSetParam "GeomAsBone"            true					-- default:true
    FbxExporterSetParam "Triangulate"           false					-- default:false
    -- <Include> <Animation>
    FbxExporterSetParam "Animation"	            false					-- default:true
    FbxExporterSetParam "Cameras"               false					-- default:true
    FbxExporterSetParam "Lights"                false					-- default:true
    -- <Advanced Options> <Units>
    FbxExporterSetParam "ScaleFactor"           1						-- default:1
    FbxExporterSetParam "ConvertUnit"           #in						-- default:#in			enum:{ #mm , #cm , #dm , #m , #km , #in , #ft , #mi , #yd }
    -- <Advanced Options> <Axis Conversion>
    FbxExporterSetParam "UpAxis"                #y						-- enum:{ #Y , #Z }
    FbxExporterSetParam "AxisConversionMethod"  #none					-- default:#none		enum:{ #none , #animation , #Fbx_Root }
    -- <Advanced Options> <UI>
    FbxExporterSetParam "ShowWarnings"          false					-- default:true
    FbxExporterSetParam "GenerateLog"           false		  	 		-- default:true
    -- <Advanced Options> <FBX File Format>
    FbxExporterSetParam "ASCII"	                false					-- default:false
    FbxExporterSetParam "FileVersion"           #FBX201400				-- default:#FBX201400	enum:{ #FBX201400, #FBX201300, #FBX201200 , #FBX201100 , #FBX201000 , #FBX200900 , #FBX200611 }
)

fn LoadFBXSetting = (

    item = readFileAsArray MF_FBXEXP_FILE

    FbxExporterSetParam "SmoothingGroups"        (execute(item[2])) 
    FbxExporterSetParam "NormalsPerPoly"         (execute(item[3])) 
    FbxExporterSetParam "SmoothMeshExport"       (execute(item[4])) 
    FbxExporterSetParam "Preserveinstances"      (execute(item[5])) 
    FbxExporterSetParam "TangentSpaceExport"     (execute(item[6])) 
    FbxExporterSetParam "SelectionSetExport"     (execute(item[7])) 
    FbxExporterSetParam "Triangulate"            (execute(item[8])) 
    if (item[9]) == "1" then(
        FbxExporterSetParam "UpAxis" #y
    ) else (
        FbxExporterSetParam "UpAxis" #z
    )
    if (item[10]) == "1" then(
        FbxExporterSetParam "ASCII" false
    ) else (
        FbxExporterSetParam "ASCII" true
    )

    item = item[11]
    if (item ==  "1") then(
        FbxExporterSetParam "FileVersion" #FBX201600			
    ) else if (item ==  "2") then(
        FbxExporterSetParam "FileVersion" #FBX201400			
    ) else if (item ==  "3") then(
        FbxExporterSetParam "FileVersion" #FBX201300			
    ) else if (item ==  "4") then(
        FbxExporterSetParam "FileVersion" #FBX201200			
    ) else if (item ==  "5") then(
        FbxExporterSetParam "FileVersion" #FBX201100			
    ) else if (item ==  "6") then(
        FbxExporterSetParam "FileVersion" #FBX201000			
    ) else if (item ==  "7") then(
        FbxExporterSetParam "FileVersion" #FBX200900			
    ) else if (item ==  "8") then(
        FbxExporterSetParam "FileVersion" #FBX200611			
    )else(
        FbxExporterSetParam "FileVersion" #FBX201400			
    )

)

fn OpenMF_FBX_Setting =
(	
    
    rollout rGeometry "Geometry" category:1
    (
        checkbox 'SmoothingGroups' "Smoothing Groups" pos:[3,6] width:150 height:26 align:#left checked:true 
        checkbox 'NormalsPerPoly' "Split per-vertex Normals" pos:[3,29] width:150 height:26 align:#left
        checkbox 'SmoothMeshExport' "TurboSmooth" pos:[3,75] width:150 height:26 align:#left
        checkbox 'Preserveinstances' "Preserve Instance" pos:[3,98] width:150 height:26 align:#left
        checkbox 'TangentSpaceExport' "Tangents and Binormals" pos:[3,52] width:150 height:26 align:#left
        checkbox 'SelectionSetExport' "Selection sets" pos:[3,121] width:150 height:26 align:#left
        checkbox 'Triangulate' "Triangulate" pos:[3,144] width:150 height:26 align:#left
        
        on rGeometry open do(
            item = readFileAsArray MF_FBXEXP_FILE
            SmoothingGroups.checked    = execute(item[2]) 
            NormalsPerPoly.checked     = execute(item[3]) 
            SmoothMeshExport.checked   = execute(item[4]) 
            Preserveinstances.checked  = execute(item[5]) 
            TangentSpaceExport.checked = execute(item[6]) 
            SelectionSetExport.checked = execute(item[7]) 
            Triangulate.checked        = execute(item[8]) 
        )

        on SmoothingGroups changed state do
        (
            FbxExporterSetParam "SmoothingGroups" state
            editFileLine MF_FBXEXP_FILE 2 (state as string)
        )
        on NormalsPerPoly changed state do
        (
            FbxExporterSetParam "NormalsPerPoly" state
            editFileLine MF_FBXEXP_FILE 3 (state as string)
        )
        on SmoothMeshExport changed state do
        (
            FbxExporterSetParam "SmoothMeshExport" state
            editFileLine MF_FBXEXP_FILE 4 (state as string)
        )
        on Preserveinstances changed state do
        (
            FbxExporterSetParam "Preserveinstances" state
            editFileLine MF_FBXEXP_FILE 5 (state as string)
        )
        on TangentSpaceExport changed state do
        (
            FbxExporterSetParam "TangentSpaceExport" state
            editFileLine MF_FBXEXP_FILE 6 (state as string)
        )
        on SelectionSetExport changed state do
        (
            FbxExporterSetParam "SelectionSetExport" state
            editFileLine MF_FBXEXP_FILE 7 (state as string)
        )
        on Triangulate changed state do
        (
            FbxExporterSetParam "Triangulate" state
            editFileLine MF_FBXEXP_FILE 8 (state as string)
        )
    )


    rollout rAdvanced "Advanced" category:2
    (
    
        local versions = #("FBX 2016/2017", "FBX 2014/2015", "FBX 2013", "FBX 2012", "FBX 2011", "FBX 2010", "FBX 2009", "FBX 2006")

        dropdownList 'UpAxis' "" pos:[109,8] width:124 height:22 items:#("y", "z") align:#left
        label 'lbl1' "Up Axis" pos:[5,14] width:40 height:19 align:#left

        dropdownList 'FBXType' "" pos:[109,35] width:124 height:22 items:#("Binary", "ASCII") selection:1 align:#left
        label 'lbl3' "FBX Type" pos:[5,41] width:85 height:19 align:#left
        dropdownList 'FBXVersion' "" pos:[109,62] width:124 height:22 items:#("FBX 2016/2017", "FBX 2014/2015", "FBX 2013", "FBX 2012", "FBX 2011", "FBX 2010", "FBX 2009", "FBX 2006") selection:1 align:#left
        label 'lbl4' "FBX Version" pos:[5,68] width:92 height:19 align:#left

        on rAdvanced open do(
            item = readFileAsArray MF_FBXEXP_FILE
            UpAxis.selection     = execute (item[9]) 
            FBXType.selection    = execute (item[10])
            FBXVersion.selection = execute (item[11])
        )
        
        on UpAxis selected sel do
        (
            item = UpAxis.items[sel]
            if (item ==  "y") then(
                FbxExporterSetParam "UpAxis" #y
            ) else (
                FbxExporterSetParam "UpAxis" #z
            )
            editFileLine MF_FBXEXP_FILE 9 (sel as string)
        )
        on FBXType selected sel do
        (
            item = FBXType.items[sel]
            if (item ==  "Binary") then(
                FbxExporterSetParam "ASCII" false
            ) else (
                FbxExporterSetParam "ASCII" true
            )
            num = sel as string
            editFileLine MF_FBXEXP_FILE 10 num
        )
        on FBXVersion selected sel do
        (
            item = FBXVersion.items[sel]
            if (item ==  "FBX 2016/2017") then(
                FbxExporterSetParam "FileVersion" #FBX201600			
            ) else if (item ==  "FBX 2014/2015") then(
                FbxExporterSetParam "FileVersion" #FBX201400			
            ) else if (item ==  "FBX 2013") then(
                FbxExporterSetParam "FileVersion" #FBX201300			
            ) else if (item ==  "FBX 2012") then(
                FbxExporterSetParam "FileVersion" #FBX201200			
            ) else if (item ==  "FBX 2011") then(
                FbxExporterSetParam "FileVersion" #FBX201100			
            ) else if (item ==  "FBX 2010") then(
                FbxExporterSetParam "FileVersion" #FBX201000			
            ) else if (item ==  "FBX 2009") then(
                FbxExporterSetParam "FileVersion" #FBX200900			
            ) else if (item ==  "FBX 2006") then(
                FbxExporterSetParam "FileVersion" #FBX200611			
            )else(
                FbxExporterSetParam "FileVersion" #FBX201400			
            )
            editFileLine MF_FBXEXP_FILE 11 (sel as string)
        )
    )
    
    global MF_FBX_Setting
    try(closeRolloutFloater MF_FBX_Setting)catch()
    MF_FBX_Setting = newRolloutFloater "FBX Setting" 250 320
    addRollout rGeometry MF_FBX_Setting
    addRollout rAdvanced MF_FBX_Setting
    
)


-- 防止窗口多开
try(DestroyDialog MF_FBX_Export)catch()
rollout MF_FBX_Export "MoreFun - FBX Export Tool" width:293 height:104
(
    button 'Options_BTN' "FBX Output Options" pos:[18,16] width:257 height:21 align:#left
    edittext 'Path_LE' "Output_Path" pos:[18,42] width:203 height:21 align:#left
    button 'Select_BTN' "select" pos:[226,41] width:47 height:21 align:#left
    button 'Export_BTN' "FBX export" pos:[18,67] width:253 height:21 align:#left
    

    on MF_FBX_Export open do (
        path = ""
        if (doesFileExist MF_FBXEXP_FILE) then(
            temp_stream = openFile MF_FBXEXP_FILE mode:"r"
            path = readLine temp_stream
            close temp_stream
        )else(
            temp_stream = openFile MF_FBXEXP_FILE mode:"w+"
            fileString = "
true
false
false
true
false
false
false
1
1
1"
            format "%" fileString to:temp_stream
            close temp_stream
        )
        Path_LE.text = path
    )

    on Options_BTN pressed do
    (
        -- OpenFbxSetting()
        OpenMF_FBX_Setting()
    )
    on Select_BTN pressed do
    (
        path = getSavePath caption:"get Output Folder"
        Path_LE.text = path
        editFileLine MF_FBXEXP_FILE 1 path
    )
    on Export_BTN pressed do
    (   
        path = Path_LE.text
        flag = doesFileExist path
        if flag != true then(
            messageBox "current directory not exist,please select a new directory"
            return true
        )

        -- reset FBX setting
        ResetFBXSetting()

        -- load FBX setting
        LoadFBXSetting()

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
createDialog MF_FBX_Export style:#(#style_minimizebox,#style_titlebar, #style_border, #style_sysmenu)

)

mainMenuBar = menuMan.getMainMenuBar()
ori_OP_menu = menuMan.findMenu("OP")
if (not ori_OP_menu == undefined) do
(
	menuMan.unRegisterMenu ori_OP_menu
)
subMenu = menuMan.createMenu "OP"
FBXExportItem = menuMan.createActionItem "OP" "OP FBX Export"
subMenu.addItem FBXExportItem -1
subMenuItem = menuMan.createSubMenuItem "MoreFun - FBX Export Tool" subMenu
subMenuIndex = mainMenuBar.numItems() - 1
mainMenuBar.addItem subMenuItem subMenuIndex
menuMan.updateMenuBar()
  

