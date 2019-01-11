Create WordPress Site
===

This sets up a site ready to go with [Trellis](https://roots.io/trellis) and [Bedrock](https://roots.io/bedrock) to jumpstart WordPress development. It is tested on MacOS, YMMV in other operating systems.

Simplest way to use:

```
sudo mv create-wp-site.sh /usr/local/bin/create-wp-site
sudo chmod +x /usr/local/bin/create-wp-site
```

then run `create-wp-site` and follow prompts

Future Enhancements
---
- Automate generating passwords for `vault.yml` files (ansible-vault encrypted config files)
- Automate setting domains in `group_vars`
- Automate adding github keys for specific users
- Automate setting / generating salts in `vault.yml` files
- Tie into different infrastructure platforms to provision production and staging boxes automatically