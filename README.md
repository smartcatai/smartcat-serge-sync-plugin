&nbsp;

&nbsp;

### This repository is deprecated. Smartcat now has a dedicated workflow, APIs and CLI to work with software localization projects. Check out our [Software Localization Projects in Smartcat](https://developers.smartcat.com/software-localization/) guide.

&nbsp;

&nbsp;

---

Smartcat plugin is now shipped with Serge. Please continue to [Serge + Smartcat Bootstrap Project](https://github.com/smartcatai/smartcat-serge-bootstrap) repo for the installation instructions and a Getting Started guide.

The older version of the README can be found [here.](README_old.md)

## Migrating from this plugin to V2:

### V1:

```javascript
sync
{
    ts
    {
        plugin                      Smartcat

        data
        {
            token_id                12345678-abcd-9876-5432-abcdef012345

            log_file                /var/log/smartcat.log
        }
    }
}
```

### V2:

```javascript
sync
{
    ts
    {
                                    /* plugin name has changed */
        plugin                      smartcat_v2

        data
        {
            /* `token_id` parameter was renamed to `account_id` */
            account_id              12345678-abcd-9876-5432-abcdef012345

            /* `log_file` parameter is no longer supported */
            /*log_file                /var/log/smartcat.log*/
        }
    }
}
```
