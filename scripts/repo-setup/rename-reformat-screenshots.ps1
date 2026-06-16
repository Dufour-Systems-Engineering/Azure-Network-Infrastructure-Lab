$renames = @{

"Screenshot 2026-06-13 065324.png" = "02-nfs-exports-file.png"
"Screenshot 2026-06-13 065332.png" = "03-exportfs-active-exports.png"
"Screenshot 2026-06-13 065550.png" = "01-nfs-directory-permissions.png"
"Screenshot 2026-06-13 065707.png" = "04-client-mounted-export.png"
"Screenshot 2026-06-13 070044.png" = "05-client-write-permission-validation.png"
}

$renames.GetEnumerator() | ForEach-Object {
Rename-Item -Path $_.Key -NewName $_.Value
}