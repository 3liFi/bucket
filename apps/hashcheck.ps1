param (
    [string]$F,
    [string]$E,
    [string]$A
)

function Get-HashWithAlgo {
    param (
        [string]$FilePath,
        [string]$Algorithm
    )
    
    try {
        switch ($Algorithm) {
            "MD5" { return (Get-FileHash -Path $FilePath -Algorithm MD5).Hash }
            "SHA256" { return (Get-FileHash -Path $FilePath -Algorithm SHA256).Hash }
            "SHA512" { return (Get-FileHash -Path $FilePath -Algorithm SHA512).Hash }
            default { throw "Unsupported algorithm: $Algorithm" }
        }
    } catch {
        throw "Error calculating hash: $($_.Exception.Message)"
    }
}

function TryCommonAlgorithms {
    param (
        [string]$FilePath,
        [string]$ExpectedHash
    )

    $commonAlgorithms = @("MD5", "SHA256", "SHA512")

    foreach ($alg in $commonAlgorithms) {
        try {
            $computedHash = Get-HashWithAlgo -FilePath $FilePath -Algorithm $alg
            if ($computedHash -eq $E) {
                return $alg
            }
        } catch {
            Write-Host "Error with algorithm $alg : $($_.Exception.Message)"
        }
    }

    return $null
}

if (-not (Test-Path -Path $F)) {
    Write-Host "Error: File not found: $F"
    exit 1
}

if ($A) {
    try {
        $computedHash = Get-HashWithAlgo -FilePath $F -Algorithm $A
        if ($computedHash -eq $E) {
            Write-Host "Match found using $A."
            exit 0
        } else {
            Write-Host "No match found using $A."
            exit 1
        }
    } catch {
        Write-Host $_.Exception.Message
        exit 1
    }
} else {
    $matchingAlgorithm = TryCommonAlgorithms -FilePath $F -ExpectedHash $E
    if ($matchingAlgorithm) {
        Write-Host "Match found using $matchingAlgorithm."
        exit 0
    } else {
        Write-Host "No match found using common algorithms (MD5, SHA256, SHA512)."
        exit 1
    }
}
