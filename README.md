# Smartcat Plugin for Serge
This plugin provides [Serge](https://serge.io/) integration with [Smartcat](https://smartcat.ai). 
On [push-ts](https://serge.io/docs/help/serge-push-ts/) sync step, Serge will tell Smartcat to scan generated translation files and update its internal translation database so that the new content becomes available for translation online. Respectively, on [pull-ts](https://serge.io/docs/help/serge-pull-ts/) sync step, Serge will tell Smartcat to synchronize all the translations back into translation files.

Serge will convert your files to the [.PO](https://www.gnu.org/software/gettext/manual/html_node/PO-Files.html) format, which is natively supported by Smartcat.

Communication between Serge and Smartcat is performed by means of the Smartcat-sync CLI utility, which can be downloaded [here](https://github.com/smartcatai/SergeSmartcatPlugin). Note that the Smartcat-sync utility must be installed on the same machine as Serge. 

Each configuration file in Serge represents a single translation project, and maps to a single specific project in Smartcat.

1.  Get files from [bin](https://github.com/smartcatai/SergeSmartcatPlugin/tree/master/bin) and [lib](https://github.com/smartcatai/SergeSmartcatPlugin/tree/master/lib) directories.
    
2.  Put the files to `<serge\_root>/bin` and `<serge\_root>/lib`, respectively.
    
3.  Create a new Serge configuration file (let's call it my\_project.serge) for your translation project so that it generates .po files under c:\\serge\\po\\my\_project (see [Configuration File Reference](https://serge.io/docs/configuration-files/reference/), jobs → ... → ts\_file\_path parameter)
    
4.  Run `serge localize my_project.serge` to make sure everything works; after this step, you get .po files in your output directory
    
5.  Go to Smartcat and add a new project. Its project\_id will be shown in the address line (format: 12345678-1234-1234-1234-123456789012). The plugin will look for its files under c:\\serge\\po\\\[project\_id\]\\folder
    
6.  Edit your Serge configuration file to add a sync/ts section (see the example below), and specify the above project\_id as the value for the project\_id parameter
    
7.  Run `serge push-ts my_project.serge` to push your translations into Smartcat for the first time, then go to Smartcat's translation UI and see if everything works as expected, i.e., if new files are added to your translation project.
    
8.  To check whether the integration works the other way as well, add or change any segment in the Smartcat document, run `serge pull-ts my_project.serge`, and see if the changed files appear in your repository.
   
Later you will run `serge sync` continuously against this configuration file, which will perform the two-way sync between Serge and Smartcat among other synchronization/localization steps. See [Localization Cycle](https://serge.io/docs/localization-cycle/) for more information.
