
# + + + SETTINGS + + +
# The name of this script in /system scripts
local strScriptName "Check_ISP1"

# Interface(s) to check.
# You can specify one or many interfaces like that:
# local vInterface ("pppoe-out1", "ether2")
local vInterface "ether1"

# The action to be taken when the interface is down
# Type %interface% instead of interface name.
# Always test in terminal first!
# You can use multiple lines. Notice ';' at
# every additional line:
# local strActionOnDown ( \
#     "/ip fi co re [find connection-type=sip and connection-mark=%interface%]" \
#     . "; /ip fi co re [find dst-address~\":1701\" and connection-mark=con_%interface%]" \
# )
local strActionOnDown ("/ip ro dis [find gateway=%interface% and static=yes]")

# The action to be taken when the interface is up.
local strActionOnUp ("/ip ro en [find gateway=%interface% and static=yes]")

# Maximum number of consistent failures to consider
# that the interface is not working:
local numFailLimit 5

# Number of successful results to consider interface is working:
local numSucLimit 10

# Array of ping targets. Use hosts that you are really need.
local arrHostsToPing ("www.google.com", "8.8.8.8", "9.9.9.9")

# How many times to ping every host from arrHostsToPing.
# Ping timeout on unreachable host is about 1 sec
# , so if we ping 3 targets with numPingCount=2 then
# maximum time it may take is 6 sec and scheduler interval
# may be more than 6 seconds in that case.
local numPingCount 3

# The ping result is successfull if the total ping number
# for all hosts is greater than that percentage:
local numSucPerc 67
# - - - SETTINGS - - - 

local funDebug do={
    if ( false ) do={ log info ("    " . $1) }
}
local arrInterfaces [toarray ""]
local numHostCount 0
local numPingSuccess 0
if ([len [/system script job find script=$strScriptName] ] > 1) do={
    error ("$strScriptName duplicate")
}
local funReplace do={
    # Test (define as 'global' in terminal):
    # put [$funReplace "inter=%int% and mark=con_%int%" "%int%" "ETHER1"]
    local s $1
    while ( [typeof [find $s $2 -1]] != "nil" ) do={
        local start [find $s $2 -1]
        set s ( \
            [pick $s 0 [$start - 1] ] \
            . $3 \
            . [ \
                pick $s \
                ($start + [len $2]) \
                [len $s] \
            ] \
        )
    }
    return $s
}
foreach h in=$arrHostsToPing do={set numHostCount ($numHostCount + 1)}
set numPingSuccess ($numHostCount * $numPingCount * $numSucPerc / 100)

if ([typeof $vInterface] = "str") do={
    set arrInterfaces ({$vInterface})
} else={
    set arrInterfaces $vInterface
}
foreach strInterface in=$arrInterfaces do={
    do {
        local strPrevStatus "UP"
        local strGlobVarStatus ("strStatus" \
            . [$funReplace $strInterface "_" ""])
        local strGlobVarFailCount ("numFailCount" \
            . [$funReplace $strInterface "_" ""])
        local strGlobVarSucCount ("numSucCount" \
            . [$funReplace $strInterface "_" ""])
        local numPingResult 0
        local numCurFailCount 0
        local numCurSucCount 0
        local strCurStatus "UP"

        if ([len [/system script environment find name=$strGlobVarStatus] ] = 0) do={
            [parse "global $strGlobVarStatus \"UP\""]
        } else={
            set strPrevStatus [/system script environment \
                get [find name=$strGlobVarStatus] value]
        }
        if ([len [/system script environment find name=$strGlobVarFailCount] ] = 0) do={
            [parse "global $strGlobVarFailCount 0"]
        } else={
            set numCurFailCount [/system script environment \
                get [find name=$strGlobVarFailCount] value]
        }
        if ([len [/system script environment find name=$strGlobVarSucCount] ] = 0) do={
            [parse "global $strGlobVarSucCount 0"]
        } else={
            set numCurSucCount [/system script environment \
                get [find name=$strGlobVarSucCount] value]
        }
        set numPingResult 0
        foreach strHost in=$arrHostsToPing do={
            local pr [ping address=$strHost count=$numPingCount \
                interface=$strInterface]
            if ($pr = 0) do={
                log info ("    $strInterface: $strHost is unreachable")
            }
            set numPingResult ($numPingResult + $pr)
        }
        if ($numPingResult < $numPingSuccess) do={
            set numCurFailCount ($numCurFailCount + 1)
            if ($numCurFailCount > $numFailLimit) do={
                set numCurFailCount $numFailLimit
            }
            if ($strCurStatus = "DOWN") do={
                set numCurSucCount 0
            }
        } else={
            if ($numCurFailCount > 0) do={
                set numCurFailCount ($numCurFailCount - 1)
            } else={
                set numCurSucCount ($numCurSucCount + 1)
            }
        }

        if ($numCurFailCount = $numFailLimit) do={
            set strCurStatus "DOWN"
            set numCurSucCount 0
        } else={
            if ($numCurFailCount = 0) do={
                if ($numCurSucCount >= $numSucLimit) do={
                    set strCurStatus "UP"
                } else={
                    set strCurStatus $strPrevStatus
                }
            } else={
                set strCurStatus $strPrevStatus
            }
        }
        /system script environment set value=$strCurStatus \
            [find name=$strGlobVarStatus]
        /system script environment set value=$numCurFailCount \
            [find name=$strGlobVarFailCount]
        /system script environment set value=$numCurSucCount \
            [find name=$strGlobVarSucCount]
        if ($strCurStatus != $strPrevStatus) do={
            if ($strCurStatus = "UP") do={
                do {
                    [parse [$funReplace $strActionOnUp "%interface%" $strInterface]]
                    log warning ("    $strInterface" \
                        . " is UP (limit: $numSucLimit)")
                } on-error={
                    log warning "    $strInterface action on UP failed"
                }
            } else={
                do {
                    [parse [$funReplace $strActionOnDown "%interface%" $strInterface]]
                    log warning ("    $strInterface" \
                        . " is DOWN (limit: $numFailLimit)")
                } on-error={
                    log warning "    $strInterface action on DOWN failed"
                }
            }
        }
    } on-error={
        info warning "    script failed"
    }
}
