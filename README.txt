
       ########################
       #        DFC           #
       #     Version 2.0.0    #
       # This software is GPL #
       ########################

IF YOU WERE USING VERSION 1, YOU'LL NEED TO (TEDIOUSLY) MIGRATE TO VERSION 2.
Version 2 uses a different passphrase generator (see NEW FOR VERSION 2 below).

NEW FOR VERSION 2:
 1. Added --v1 option.  This reverts to version 1.  :))
 2. Answers to the security questions are now ".strip.downcase.gsub(/\W/,'').squeeze"ed.
    It used to just be ".strip"ed.
    So, yeah... I was having trouble reproducing my answers.

NEW FOR VERSION 1:
 1. I'd misspelled yin as ying, so that's fixed.
    If you were using version 0, just move the two misspelled directories.
 2. Added "pwds" command.  It gives a list of suggested passphrases
    based on your master passphrase (with optional salts).
    If you use these as passphrases to your synch services, then
    in the event of having to reconstruct the database on a new computer,
    you'll have the passphrases to the synch services available.
 3. Added "questions" command.  From time to time you should test yourself and
    check if you can answer the security questions exactly as you did to create your dfc passphrase.
    This ensures you'll be able to recreate the database.

Please consider DFC experimental because of it's use of security questions.

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
   ~/.dfc/dark/yin
   ~/.dfc/dark/yang
   ~/.dfc/depository/yin
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
Also, "passphrase" is a reserved key.
But you can "co" and "co!" reserved keys.

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
Then, move the depository's yin and yang:
   mv ~/.dfc/depository/yin ~/Dropbox/yin
   mv ~/.dfc/depository/yang ~/Wuala/yang
And then link to these directories:
   ln -s ~/Dropbox/yin ~/.dfc/depository/yin
   ln -s ~/Wuala/yang   ~/.dfc/depository/yang
You should not synch the dark files because:
   1. There is no reason to.  Passphrase via security questions are reproducible.
   2. The passphrase is the third triad of the dispersal.
   3. The file timestamps are set to EPOCH which may break how the synch service works.

