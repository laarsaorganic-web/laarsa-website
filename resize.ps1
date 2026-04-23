Add-Type -AssemblyName System.Drawing

$assetsPath = "c:\Users\Minu\Downloads\website with anti\assets"
$images = Get-ChildItem -Path $assetsPath -Filter "*.png" -Recurse

foreach ($imgFile in $images) {
    try {
        $img = [System.Drawing.Image]::FromFile($imgFile.FullName)
        
        # Only resize if width > 800
        if ($img.Width -gt 800) {
            Write-Host "Resizing $($imgFile.Name)..."
            $ratio = 800.0 / $img.Width
            $newWidth = 800
            $newHeight = [math]::Round($img.Height * $ratio)
            
            $newImg = New-Object System.Drawing.Bitmap($newWidth, $newHeight)
            $graph = [System.Drawing.Graphics]::FromImage($newImg)
            $graph.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            
            $graph.DrawImage($img, 0, 0, $newWidth, $newHeight)
            $graph.Dispose()
            $img.Dispose()
            
            # Save to temporary file first to avoid locking
            $tempPath = "$($imgFile.FullName).tmp.png"
            $newImg.Save($tempPath, [System.Drawing.Imaging.ImageFormat]::Png)
            $newImg.Dispose()
            
            # Replace original
            Remove-Item $imgFile.FullName -Force
            Rename-Item -Path $tempPath -NewName $imgFile.Name
            
            Write-Host "Done resizing $($imgFile.Name)"
        } else {
            $img.Dispose()
        }
    } catch {
        Write-Host "Error processing $($imgFile.Name): $_"
    }
}
Write-Host "All images processed."
