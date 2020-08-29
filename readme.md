# The script to check if interface is working

Advantages:
- Can be used for one or more interfaces.
- Ping several addresses, relying on one is too unreliable.
- You can run it as often as you like.

You can use this rule to test the script

    /ip firewall filter add action=drop chain=output comment=INT_CHECK_TEST \
        out-interface=ETHER1 protocol=icmp


