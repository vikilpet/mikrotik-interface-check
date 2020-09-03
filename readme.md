# The script to check if interface is working
![mikrotik interface check](https://user-images.githubusercontent.com/43970835/92127780-b7481d00-ee12-11ea-81be-7e586c67ec8a.gif)

Advantages:
- Can be used for one or more interfaces.
- Any type of interface
- Ping several addresses, relying on one is too unreliable.
- You can run it as often as you like.
- Easy setup - you only need to set a couple of variables.

# Setup
Just create script in `/system scripts` and set variables in `SETTINGS` to your liking. Variables are provided with comments and examples.

You can use this firewall rule to test the script:

    /ip firewall filter add action=drop chain=output comment=INT_CHECK_TEST \
        out-interface=ETHER1 protocol=icmp
