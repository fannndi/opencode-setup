# PSCustomObject property bug
ConvertFrom-Json returns PSCustomObject which can't set properties. Fix: convert to Hashtable first
