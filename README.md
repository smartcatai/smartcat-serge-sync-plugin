# Serge + Smartcat
[Smartcat](https://www.smartcat.ai/) is an all-in-one translation platform for language service providers and any companies who want to make localization a natural part of their content lifecycle. Below, we describe how to integrate and configure Smartcat to work with [the Serge utility](Serge.io) to build an automated, continuous localization process.

## Configuring Serge to work with Smartcat
Here are the steps you need to take to make Serge work with Smartcat.

1. Create a Smartcat account.
2. Create and set up a project in Smartcat.
3. Install Serge.
4. Set up the Smartcat plugin.

### Setting up the Smartcat plugin
```
sudo cpanm Serge::Sync::Plugin::TranslationService::Smartcat
```

#### Adding the plugin
Go to Serge configuration files > **myproject.serge.tmpl** and add the Smartcat plugin to the **sync > ts** section.
```
sync {
 ts
    {
        plugin                      Smartcat
        data
        {
            base_url                https://smartcat.ai
            project_id             12345678-1234-1234-1234-1234567890123
            token_id               12345678-1234-1234-1234-1234567890123
            token                   1_qwertyuiopasdfghjklzxcvbn
            push {
                disassemble_algorithm_name       Serge.io PO
            }
            pull {
                complete_projects               NO
                complete_documents              YES
            }
            log_file                            ./log/smartcat.log
        }
    }
```

#### Parameters:
* **plugin** — plugin name. Must be “Smartcat”.
* **base_url** — Smartcat API URL. Default: https://smartcat.ai (European server). See [API documentation](https://help.smartcat.ai/hc/en-us/articles/115002475012-Getting-Started-with-SmartCAT-API) for the list of available servers. You will know the server your account is on by just signing into your account and looking at the URL.
* **project_id** — unique Smartcat [project ID](https://help.smartcat.ai/hc/en-us/articles/115002522912-What-is-Smartcat-project-ID).
* **token, token_id** — [credentials](https://help.smartcat.ai/hc/en-us/articles/115002475012-Getting-Started-with-SmartCAT-API) used by Serge to access the Smartcat API. 
* **disassemble_algorithm_name** — name of the algorithm to disassemble the Serge files. Must be “Serge.io PO”.
* **complete_projects** — condition to pull new translations. Whether or not the plugin will pull translations from Smartcat only when all documents in the project are **Completed**. “No” by default. 
* **complete_documents** — condition to pull new translations. Whether or not the plugin will pull translations from *each* **Completed** document in the Smartcat project. “Yes” by default.

#### Configuring Serge jobs
Go to the **jobs** section in the **myproject.serge.tmpl** file and configure the **ts_file_path** parameter. It describes the location to generate .po files.
```
ts_file_path                ./po/%project_id%/%LANG%/%FILE%.po
```
Parameters:
* project_id — unique [project ID](https://help.smartcat.ai/hc/en-us/articles/115002522912-What-is-Smartcat-project-ID) from Smartcat.

Note that the %LOCALE% macro is used to generate locale-specific folders under the /po/project_id/ directory. The value for %LOCALE% is set up in the **destination_languages** parameter. It must correspond to the Smartcat project languages and language codes from the [list](https://help.smartcat.ai/hc/en-us/articles/360004895371-Supported-languages-and-language-codes).
```
destination_languages       ru zh-Hans ko de ja
```
Once you set up the **jobs** section in your configuration file, you can run the Serge localization pass once to see if the .po files are generated properly, and the folder and file structure matches the expectations.
```
serge localize myproject.local.serge
```

### Example of myproject.serge.tmpl
A configured **myproject.serge.tmpl** is presented below. You can use it as a template for your integration.
```
sync {
 ts
    {
        plugin                      Smartcat

        data
        {
            project_id              %project_id%
            token_id                %token_id%
            token                   %token%

            push {
                disassemble_algorithm_name       Serge.io PO
            }
            pull {
                complete_projects                NO
                complete_documents               YES
            }
        }
    }

    vcs {
        plugin                      git

        data {
            local_path              ./branches
            add_unversioned         YES
            name                    L10N Robot
            email                   l10n-robot@example.com
            remote_path {
                master             git@gitlab.loc:common/myproject.git#master
/* FBCGEN_BRANCH_REMOTES
                $FBCGEN_DIR_PADDED  git@gitlab.loc:common/myproject.git#$FBCGEN_BRANCH
*/
            }

        }
    }
}

jobs {
    :develop {
        id                          job.master
        name                        myproject
        source_language             en
        destination_languages       ru zh-Hans ko de ja
        optimizations               NO
        source_dir                  ./branches/master/client/src/translations
        source_match                `en-US.js`
        debug                       NO
        parser {
            plugin                  parse_js
        }
        leave_untranslated_blank    YES
        db_source                   DBI:SQLite:dbname=./myproject.db3
        db_namespace                myproject
        ts_file_path                ./po/%project_id%/%LANG%/%FILE%.po
        output_file_path            ./branches/master/client/src/translations/%CULTURE%.%EXT%
        output_bom                  NO
        output_lang_rewrite {
               zh-Hans zh
        }

        callback_plugins {
            :feature_branch {
                plugin              feature_branch

                data {
                    master_job      job.base-translate
                }
            }
        }
    }

/* FBCGEN_BRANCH_JOBS
    :$FBCGEN_DIR {
        @inherit                    .#jobs/:develop
        id                          job.$FBCGEN_DIR
                                      $FBCGEN_EXTRA_INCLUDE
        source_path_prefix          $FBCGEN_BRANCH.
        source_dir                  ./branches/$FBCGEN_DIR/client/src/translations/
        output_file_path            ./branches/$FBCGEN_DIR/client/src/translations/%CULTURE%.%EXT%
    }
*/
}
```
