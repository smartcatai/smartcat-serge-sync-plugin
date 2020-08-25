# Smartcat Plugin for Serge

This is a plugin for [Serge](https://serge.io/), a continuous localization solution that drastically simplifies integration with Smartcat. With Serge, you don't have to write any custom integration code with our low-level API, so this is a preferred method of integrating your projects with Smartcat.

# :white_check_mark: Official Support

Both this plugin and Serge itself are officially supported by Smartcat. We offer managed solutions and localization engineering services [as a part of the subscription](https://www.smartcat.ai/pricing/) if you don't have in-house engineers to set this up for you.</p>

# Installation Instructions

1. Create an account at [Smartcat](https://www.smartcat.ai/).
2. Create a new project in Smartcat to synchronize your data with.
3. [Install the latest version of Serge](https://serge.io/download/?/latest)
4. Install this plugin by running:
    ```
    sudo cpan Serge::Sync::Plugin::TranslationService::Smartcat
    ```

# Next: [Getting Started](https://github.com/smartcatai/smartcat-serge-bootstrap)

# Usage

Use the template below for your Serge configuration file:

```javascript
sync
{
    ts
    {
        plugin                      Smartcat

        data
        {
            /*
            Provide the base API server URL here.
            Note that the trailing slash must be omitted.
            Options are:
            https://smartcat.ai       (Europe)
            https://us.smartcat.ai    (North America)
            https://ea.smartcat.ai    (Asia)
            You will know the server your account is on
            by just signing into your account
            and looking at the URL.
            */
            base_url                https://smartcat.ai

            /*
            Provide your account ID as it is displayed on
            your `Settings > API` page once you sign into
            your Smartcat account.
            */
            token_id                12345678-abcd-9876-5432-abcdef012345

            /*
            Go to `Settings > API` page in your account,
            and generate an API key. Key name can be anything,
            e.g. 'Serge', and the auto-generated secret part
            of the key is what needs to be added here.
            */
            token                   1_AaBbCcDdEeFfGgHhIiJjKkLlM

            /*
            Provide the project ID to synchronize data with.
            To get the ID, navigate to the target project and take
            it's ID from the URL. For example, if the URL is
            https://us.smartcat.ai/projects/
            01234567-890a-bcde-f012-34567890abcd/files?documentPage=1
            then the ID will be 01234567-890a-bcde-f012-34567890abcd
            */
            project_id              01234567-890a-bcde-f012-34567890abcd

            /*
            [OPTIONAL] Write plugin activity log to the specified file
            (enable this only for debugging, if requested by Smartcat support).
            */
            #log_file                /var/log/smartcat.log
        }
    }
}

jobs
{
    {
        /*
        You can put the translation files anywhere (and Smartcat
        plugin will determine their location from your `ts_file_path`
        job parameter), but make sure you're using a
        <directory>/%LANG%/%FILE%.po pattern, i.e. each language
        must reside in its own folder.
        */
        ts_file_path                ../ts/myproject/%LANG%/%FILE%.po

        callback_plugins
        {
            /*
            Currently Smartcat expects a flat list of .po files
            in each language directory, i.e. it doesn't support
            subdirectories in its projects.
            The code below will flatten output file paths
            by replacing `/` with a custom separator, `--`.
            */
            {
                plugin                           replace_strings
                phase                            rewrite_relative_ts_file_path

                data
                {
                    replace                      `\/` `--` g
                }
            }
        }

        # other job parameters
        # ...
    }
}
```

# Further Reading

1. [The list of language tags recognized by Smartcat](https://smartcat.ai/Home/Languages)
2. [Official Serge documentation](https://serge.io/docs/)
