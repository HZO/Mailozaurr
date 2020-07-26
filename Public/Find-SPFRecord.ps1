function Find-SPFRecord {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ValueFromPipeline, Position = 0)][string[]]$DomainName,
        [System.Net.IPAddress] $DnsServer,
        [switch] $AsHashTable,
        [switch] $AsObject
    )
    process {
        foreach ($Domain in $DomainName) {
            $Splat = @{
                Name        = $Domain
                Type        = "txt"
                ErrorAction = "Stop"
            }
            if ($DnsServer) {
                $Splat['Server'] = $DnsServer
            }
            try {
                $DNSRecord = Resolve-DnsQuery @Splat | Where-Object Text -Match "spf1"
                if (-not $AsObject) {
                    $MailRecord = [ordered] @{
                        Name       = $Domain
                        Count      = $DNSRecord.Count
                        TimeToLive = $DnsRecord.TimeToLive -join '; '
                        SPF        = $DnsRecord.Text -join '; '
                    }
                } else {
                    $MailRecord = [ordered] @{
                        Name       = $Domain
                        Count      = $DNSRecord.Count
                        TimeToLive = $DnsRecord.TimeToLive
                        SPF        = $DnsRecord.Text
                    }
                }
            } catch {
                $MailRecord = [ordered] @{
                    Name       = $Domain
                    Count      = 0
                    TimeToLive = ''
                    SPF        = ''
                }
                Write-Warning "Find-SPFRecord - $_"
            }
            if ($AsHashTable) {
                $MailRecord
            } else {
                [PSCustomObject] $MailRecord
            }
        }
    }
}