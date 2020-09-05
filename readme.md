# The MikroTik script to detect whether the interface is really working
![mikrotik interface check](https://user-images.githubusercontent.com/43970835/92155775-f2f5dd80-ee38-11ea-9af6-bb4f114d0029.gif)

[На русском](readme_ru.md)

Advantages:
- Can be used for one or more interfaces.
- Any type of interface.
- Ping several addresses (relying on one is too unreliable).
- You can run it as often as you like - it can detect fail relatively fast.
- Easy setup - you only need to set a couple of variables.

# Setup
Just create script in `/system scripts` and set variables in `SETTINGS` to your liking. Variables are provided with comments and examples.

Add a task to the scheduler with short interval (even a couple of seconds is OK).

    `/system script run Check_ISP1`

You can use this firewall rule to test the script:

    /ip firewall filter add action=drop chain=output comment=INT_CHECK_TEST \
        out-interface=ETHER1 protocol=icmp
