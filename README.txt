
       ########################
       #        DFC           #
       #     Version 0.0.2    #
       # This software is GPL #
       ########################

First, please consider DFC experimental because of it's use of security questions.
DFC is a command line utility that uses SymetricGPG::Shreds to encrypt and shred files.
See:
   SymmetricGPG   https://sites.google.com/site/carlosjhr64/rubygems/symmetricgpg
   Shredder       https://sites.google.com/site/carlosjhr64/rubygems/shredder
It creates a database that is accessible by keys.
It's meant to be used in conjunction with two folder synchronizing depositories, like DropBox and Wuala.
Encrypted files are shredded and dispersed among the two depositories so that neither has the entire file.

When run for the very first time,
DFC will create your passphrase according to your answers to a set of security questions.
Then it will create the following directories:
   ~/.dfc/dark/ying
   ~/.dfc/dark/yang
   ~/.dfc/depository/ying
   ~/.dfc/depository/yang

Help output:
   >>> dfc --help
   Usage: dfc [ci,ci!,co,co!,shred,shred!,rmkey] key <filename>
           ci      creates a new key with the file's content
           ci!     overwrites an existing key with the file's content
           co      creates a new file with the key's content
           co!     overwrites a file with the key's content
           shred   creates a new key with the file's content and then deletes the file
           shred!  overwrites a key with the file's content and then deletes the file
           rmkey   deletes key
           log     read the depository's log
           log ci! backup the log file
    Options:
           --dark  use the dark directory
           -h      this help
           --help
           -v      the version
           --version

Note that because of "log ci!", "log" is a reserved key.
There is no configuration.  See the full documentation at:
   https://sites.google.com/site/carlosjhr64/rubygems/dfc

The shreds are stored in ~/.dfc.  There are two directories in ~/.dfc, dark and depository.
The dark directory holds shreds you don't want in the depository, such as
the shreds for the passphrase data.  To get your depository shreds backed up,
you need to either create a link to the folder that's being synchronized or
make the synch service synchronize the shreds directory.
DFC is meant to be used with two separate synchronization services.
Consider Dropbox and Wuala for the following example.
Dropbox creates a directory ~/Dropbox for the user which is the synchronized folder.
Wuala allows the user to set which folder to synchronize.
For this example, let there be a ~/Wuala directory.
Then, move the depository's ying and yang:
   mv ~/.dfc/depository/ying ~/Dropbox/ying
   mv ~/.dfc/depository/yang ~/Wuala/yang
And then link to these directories:
   ln -s ~/Dropbox/ying ~/.dfc/depository/ying
   ln -s ~/Wuala/yang   ~/.dfc/depository/yang
You should not synch the dark files because:
   1. There is no reason to.  Passphrase via security questions are reproducible.
   2. The passphrase is the third triad of the dispersal.
   3. The file timestamps are set to EPOCH which may break how the synch service works.

