# Rotate a secret in vault and app-interface

When a user has a secret they need rotated but they can't access
vault, they usually transmit it to the IC and it's the IC's
responsibility to perform the update. 

To safely transmit the secret, the user should run the
`hack/secret-share.py` script with the IC's login as its argument and
the secret as stdin. They will receive a base64-encoded string that is
safe to copy and paste in slack or email. For instance:

``` python
$ LANG=C ./hack/secret-share.py data/teams/app-sre/users/lmunozme.yml
# Type secret here, end with control-D
Use this key anyway? (y/N) y
hQIMAyEUMX6a82ZBARAAvLPMcyTnQtiYdYduU07fIY6YlWbALThYaE0377ZbJ0MpGs/1XmjLG06ZiF+AVxuVuSwogUswiDY10MwtKzWrHOv1ofYwQWzre3eOZDvPSdg0s8v5luzRjS2ga2eEZccqTD08oerwuB/Ty8y64x8uBl6RyCJVMyJBEisHmnP1deLYhYNP58dHQhB8f8l/jy4C0Liy6Ik3apTQlKRWKOkocSpf/FSRsSUCdHVLI+lwhGOfrqULFu+f5w1CQVabvqUnHXNmR0fzRlI4h/XDphz0Tcpme2HUcEUIO6/eRpTe+//fEHux0PcgDpk45ak3KYqUa1zNboPTZId6WwBjUiAaMRnVV92nldJi1fUSootYPf3mIRyYUNcFttbCqi6grfb6jrSLfEojzKcMN3Hg8eBfVywHd7+mp+DncUv6h2SRHBROSaPQp4MuC8H+5+Ra/h+0oiEHr/vcWsGvtQoy89klXm6KolZ+UpHOibMT4UwCWnY1Um5hPdrjgAvf74STSmo6pnZA6Z663sxH0wyObuA22EBJKlXEw31yCNRLgfZmJ0IHrNWQ4paQjKkf+lLBbhCgA0MWkKD4gnD/huvFDjw0DG13m0hDWyOW/2/tZZCnUWeBjvGkKWxLb07dF5pFFgAW1bmKR5Tbf5eTWvv7gRD+JHi+YxY3b5lD+X5cBND5b7/SSgFpDaqY5fbPYdrglNzGml2JQemLuuinu1kIOdD48tb3zs5XVoi56li3irLykBM0Ov8a6i3+BCaUQfrtcPyNq6M0i4mGK8eBaP12
```
