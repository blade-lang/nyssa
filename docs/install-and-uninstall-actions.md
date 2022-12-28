# Install and Uninstall actions

Nyssa provides an installation hook (`post_install`) and uninstallation hook (`pre_uninstall`) that allows package and library authors to customize the installation and uninstallation experience and do many things such as downloading and building extra dependencies that may be written in other programming languages.

### `post_install`

The `post_install` configuration allows package authors to specify a Blade script that should be run after the package has been extracted into its destination directory. To specify a script to run after installation, add the `post_install` option to the `nyssa.json` file.

```
...
"post_install": "<script_name>.b"
```

The _<scirpt_name>_ must be a path or filename relative to the root of the package.

### `pre_uninstall`

The `pre_uninstall` configuration is much like the `post_install` configuration, except that it runs just before a package is uninstalled. You can add it to the `nyssa.json` file in the same way as the `post_install` option.

```
...
"pre_uninstall": "<script_name>.b"
```
