<#
  EXPとIMPのログファイルにエラーの情報分析関数

  ReportExpErrorとReportImpError、ShowExpErrorとShowImpErrorの構成はほぼ同様ですが、
  バージョン差分(例:EXPは9i、IMPは11g)を吸収するため別々としています。
#>
function ConvertEncoding {
    param (
        [string]$sourcePath,
        [string]$sourceEncoding = [System.Text.Encoding]::Default.HeaderName,
        [string]$destPath,
        [string]$destEncoding = [System.Text.Encoding]::Default.HeaderName
    )
    if (Test-Path -Path $sourcePath -PathType Leaf) {
        if (Test-Path -Path $destPath) {
            Write-Host "指定した出力ファイルは既に存在します。$destPath"
        }else {
            $content = [System.IO.File]::ReadAllLines($sourcePath,[System.Text.Encoding]::GetEncoding($sourceEncoding))
            [System.IO.File]::WriteAllLines($destPath,$content,[System.Text.Encoding]::GetEncoding($destEncoding))
        }
    }
    elseif (Test-Path -Path $sourcePath -PathType Container){
        if (Test-Path -Path $destPath -PathType Container) {
            Get-ChildItem -Path $sourcePath | ForEach-Object {
                $outputFile =　Join-Path $destPath $_.Name
                if (Test-Path -Path $outputFile ) {
                    Write-Host "指定した出力フォルダにファイルは既に存在します。$outputFile"
                }else {
                    $content = [System.IO.File]::ReadAllLines($_.FullName,[System.Text.Encoding]::GetEncoding($sourceEncoding))
                    [System.IO.File]::WriteAllLines($outputFile,$content,[System.Text.Encoding]::GetEncoding($destEncoding))
                    Write-Host "ファイル作成しました。$outputFile"
                }
            }
        }
        else {
            Write-Host "指定した出力フォルダは存在ません。$destPath"
        }
    }
    else {
        Write-Host "指定した入力ファイルは見つかりません。$sourcePath"
    }
}
# ConvertEncoding -sourcePath C:\Users\linxu\Desktop\work\作業\20190805本番機info\info\objects_CDBC01.csv -sourceEncoding euc-jp -destPath C:\Users\linxu\Desktop\work\作業\20190805本番機info\info_sjis\objects_CDBC01.csv -destEncoding shift-jis
# ConvertEncoding -sourcePath C:\Users\linxu\Desktop\work\作業\20190805本番機info\info\ -sourceEncoding euc-jp -destPath C:\Users\linxu\Desktop\work\作業\20190805本番機info\info_sjis\ -destEncoding shift-jis

<#  #>
function ReportExpError {
    param (
        [string]$LogDir,
        [string]$Filter = "*.log",
        [string]$Encoding = [System.Text.Encoding]::Default.HeaderName
    )
    $errorDic = @{}
    Get-ChildItem -Path $LogDir -Filter $Filter | ForEach-Object {
        $content = [System.IO.File]::ReadAllLines($_.FullName,[System.Text.Encoding]::GetEncoding($Encoding))
        foreach ($line in $content) {
            if ($line.StartsWith("EXP-")) {
                $errorCode = $line.Substring(0,9)
                if ($errorDic.ContainsKey($errorCode)) {
                    $errorDic[$errorCode] = $errorDic[$errorCode] + 1
                } else {
                    $errorDic.Add($errorCode,1)
                }
            }
        }
    }
    return $errorDic
}
# ReportExpError -LogDir C:\Users\linxu\Desktop\work\作業\20190805本番機info\log -Filter exp_CDBC01_*.log -Encoding euc-jp

function ShowExpError {
    param (
        [string]$LogDir,
        [string]$Filter = "*.log",
        [string]$Encoding = [System.Text.Encoding]::Default.HeaderName,
        [string[]]$IncludeError = @(),
        [string[]]$ExceptError = @()
    )
    $result = ""
    Get-ChildItem -Path $LogDir -Filter $Filter | ForEach-Object {
        # $content = Get-Content -Encoding '51932' $_.Name # PowerShell > 6.2
        $content = [System.IO.File]::ReadAllLines($_.FullName,[System.Text.Encoding]::GetEncoding($Encoding))
        $lines = $content | Where-Object { ($_ -match 'EXP-') } 
        foreach ($line in $lines) {
            
            $containsKey = $false
            foreach($key in $ExceptError) {
                if ($line.contains($key)) {
                    $containsKey = $true
                    break
                }
            }
            if($containsKey) {
                continue
            }
            Write-Host "$($_.Name),$($line)"
            $result += "$($_.Name),$($line)`n"
        }
    }
    return $result
}
# . .\00_check_db_export.ps1
# ShowExpError -LogDir C:\Users\linxu\Desktop\work\作業\20190805本番機info\log -ExceptError EXP-00091 | Out-File -Encoding default all_export_errors.csv

function ReportImpError {
    param (
        [string]$LogDir,
        [string]$Filter = "*.log",
        [string]$Encoding = [System.Text.Encoding]::Default.HeaderName
    )
    $errorDic = @{}
    Get-ChildItem -Path $LogDir -Filter $Filter | ForEach-Object {
        $content = [System.IO.File]::ReadAllLines($_.FullName,[System.Text.Encoding]::GetEncoding($Encoding))
        foreach ($line in $content) {
            if ($line.StartsWith("IMP-")) {
                $errorCode = $line.Substring(0,9)
                if ($errorDic.ContainsKey($errorCode)) {
                    $errorDic[$errorCode] = $errorDic[$errorCode] + 1
                } else {
                    $errorDic.Add($errorCode,1)
                }
            }
        }
    }
    return $errorDic
}
# ReportImpError -LogDir C:\Users\linxu\Desktop\work\作業\database_scripts\import\log -Filter imp_CDBC01_*.log

function ShowImpError {
    param (
        [string]$LogDir,
        [string]$Filter = "*.log",
        [string]$Encoding = [System.Text.Encoding]::Default.HeaderName,
        [string[]]$IncludeError = @(),
        [string[]]$ExceptError = @()
    )
    $result = ""
    Get-ChildItem -Path $LogDir -Filter $Filter | ForEach-Object {
        # $content = Get-Content -Encoding '51932' $_.Name # PowerShell > 6.2
        $content = [System.IO.File]::ReadAllLines($_.FullName,[System.Text.Encoding]::GetEncoding($Encoding))
        $lines = $content | Where-Object { ($_ -match 'IMP-') } 
        foreach ($line in $lines) {
            

            if ($IncludeError.Count -ge 0) {
                $containsKey = $false
                foreach($key in $IncludeError) {
                    if ($line.contains($key)) {
                        $containsKey = $true
                        break
                    }
                }
                if(-not $containsKey) {
                    continue
                }
            }
            elseif ($ExceptError -ge 0) {
                $containsKey = $false
                foreach($key in $ExceptError) {
                    if ($line.contains($key)) {
                        $containsKey = $true
                        break
                    }
                }
                if($containsKey) {
                    continue
                }
            }

            Write-Host "$($_.Name),$($line)"
            $result += "$($_.Name),$($line)`n"
        }
    }
    return $result
}
# ShowImpError -LogDir C:\Users\linxu\Desktop\work\作業\database_scripts\import\log -Encoding shift-jis -IncludeError IMP-00058,IMP-00041 -Filter imp_CDBC01_*.log